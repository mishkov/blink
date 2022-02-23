import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

class Signaling {
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun.l.google.com:19302',
        ]
      }
    ]
  };

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  String? _roomId;
  StreamStateCallback? onAddRemoteStream;
  void Function()? onWin;
  void Function()? onLose;
  void Function()? onDraw;
  void Function(DateTime battleStartTime)? onReadyToPlay;
  bool isReadyToPlay = false;
  bool _didPlayerBlink = false;
  DateTime? _blinkTime;
  bool _isBattleEnd = false;
  Function? _onEnemyReadyToReceive;

  RTCDataChannel? _dataChannel;

  Future<bool> isThereEmptyRoom() async {
    final db = FirebaseFirestore.instance;
    final querySnapshot = await db
        .collection('rooms')
        .where('isPeerCreated', isEqualTo: false)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<String> getFirstFreeRoomId() async {
    final db = FirebaseFirestore.instance;
    final querySnapshot = await db
        .collection('rooms')
        .where('isPeerCreated', isEqualTo: false)
        .get();
    return querySnapshot.docs.first.id;
  }

  Future<void> closeRoom(String roomId) async {
    final db = FirebaseFirestore.instance;
    final roomRef = db.collection('rooms').doc(roomId);
    final closedRoom = {'isPeerCreated': true};
    final roomSnapshot = await roomRef.get();
    if (roomSnapshot.exists) {
      roomRef.update(closedRoom);
    }
  }

  Future<void> openDataChannel() async {
    final dataChannelDict = RTCDataChannelInit();

    _dataChannel =
        await _peerConnection!.createDataChannel('eyesOpen', dataChannelDict);
    _dataChannel!.onMessage = messageHandler;
  }

  void waitForDataChannel() {
    _peerConnection!.onDataChannel = _onDataChannel;
  }

  void _onDataChannel(RTCDataChannel dataChannel) {
    _dataChannel = dataChannel;
    final Map<String, dynamic> readyToReceivePackage = {
      'status': '5',
    };
    _dataChannel!
        .send(RTCDataChannelMessage(jsonEncode(readyToReceivePackage)));
    _dataChannel!.onMessage = messageHandler;
  }

  void messageHandler(RTCDataChannelMessage message) {
    if (_isBattleEnd) return;

    if (message.type == MessageType.text) {
      final json = jsonDecode(message.text);
      switch (int.parse(json['status'])) {
        case 0:
          final enemyBlinkTime = DateTime.parse(json['time']);
          if (_didPlayerBlink) {
            if (_blinkTime!.isAfter(enemyBlinkTime)) {
              // enemy is loser
              final Map<String, dynamic> json = {
                'status': '1',
              };
              _dataChannel?.send(RTCDataChannelMessage(jsonEncode(json)));
              if (onWin != null) {
                onWin!();
              }
              _isBattleEnd = true;
            } else if (_blinkTime!.isAtSameMomentAs(enemyBlinkTime)) {
              // Draw!!!!
              final Map<String, dynamic> json = {
                'status': '2',
              };
              _dataChannel?.send(RTCDataChannelMessage(jsonEncode(json)));
              if (onDraw != null) {
                onDraw!();
              }
              _isBattleEnd = true;
            } else {
              // enemy is winner
              final Map<String, dynamic> json = {
                'status': '3',
              };
              _dataChannel?.send(RTCDataChannelMessage(jsonEncode(json)));
              if (onLose != null) {
                onLose!();
              }
              _isBattleEnd = true;
            }
          } else {
            // enemy is loser
            final Map<String, dynamic> json = {
              'status': '1',
            };
            _dataChannel?.send(RTCDataChannelMessage(jsonEncode(json)));
            if (onWin != null) {
              onWin!();
            }
            _isBattleEnd = true;
          }
          break;
        case 1:
          if (onLose != null) {
            onLose!();
          }
          _isBattleEnd = true;
          break;
        case 2:
          if (onDraw != null) {
            onDraw!();
          }
          _isBattleEnd = true;
          break;
        case 3:
          if (onWin != null) {
            onWin!();
          }
          _isBattleEnd = true;
          break;
        case 4:
          isReadyToPlay = true;
          if (onReadyToPlay != null) {
            final battleStart = DateTime.parse(json['time']);
            onReadyToPlay!(battleStart);
          }
          break;
        case 5:
          if (_onEnemyReadyToReceive != null) {
            _onEnemyReadyToReceive!();
          }
          break;
      }
    }
  }

  void sendBlinkTime() {
    if (_didPlayerBlink) return;
    _didPlayerBlink = true;
    _blinkTime = DateTime.now();

    final Map<String, dynamic> json = {
      'status': '0',
      'time': _blinkTime!.toIso8601String(),
    };
    _dataChannel?.send(RTCDataChannelMessage(jsonEncode(json)));
  }

  Future<String> createRoom() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc();

    _peerConnection = await createPeerConnection(_configuration);

    await openDataChannel();
    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        closeRoom(_roomId!);
        isReadyToPlay = true;
        if (onReadyToPlay != null) {
          _onEnemyReadyToReceive = () {
            final battleStart = DateTime.now().add(const Duration(seconds: 10));
            final battleStartPackage = {
              'status': '4',
              'time': battleStart.toIso8601String(),
            };
            if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
              _dataChannel
                  ?.send(RTCDataChannelMessage(jsonEncode(battleStartPackage)));
              onReadyToPlay!(battleStart);
            } else {
              _dataChannel?.onDataChannelState = (state) {
                if (state == RTCDataChannelState.RTCDataChannelOpen) {
                  _dataChannel?.send(
                      RTCDataChannelMessage(jsonEncode(battleStartPackage)));
                  onReadyToPlay!(battleStart);
                }
              };
            }
          };
        }
      }
    };

    _localStream?.getTracks().forEach((track) {
      _peerConnection
          ?.addTrack(track, _localStream!)
          .catchError((error, stackTrace) {
        log(error, stackTrace: stackTrace);
      });
    });

    // Code for collecting ICE candidates below
    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      callerCandidatesCollection.add(candidate.toMap());
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    Map<String, dynamic> roomWithOffer = {
      'offer': offer.toMap(),
      'isPeerCreated': false,
    };

    await roomRef.set(roomWithOffer);
    var roomId = roomRef.id;
    // Created a Room

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      event.streams[0].getTracks().forEach((track) {
        _remoteStream?.addTrack(track).catchError((error, stackTrace) {
          log(error, stackTrace: stackTrace);
        });
      });

      if (onAddRemoteStream != null && _remoteStream != null) {
        onAddRemoteStream!(_remoteStream!);
      }
    };

    // Listening for remote session description below
    roomRef.snapshots().listen((snapshot) async {
      // if (snapshot.data() == null) {
      //   log('Data on updated room is null', stackTrace: StackTrace.current);
      //   return;
      // }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      /// It is strange that no await keyword in origin code
      if (await _peerConnection?.getRemoteDescription() == null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        await _peerConnection?.setRemoteDescription(answer);
      }
    }, onError: (error, stackTrace) {
      log(error, stackTrace: stackTrace);
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          _peerConnection!
              .addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          )
              .catchError((error, stackTrace) {
            log(error, stackTrace: stackTrace);
          });
        }
      }
    }, onError: (error, stackTrace) {
      log(error, stackTrace: stackTrace);
    });
    // Listen for remote ICE candidates above

    _roomId = roomId;
    return roomId;
  }

  Future<void> joinRoom(String roomId) async {
    _roomId = roomId;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      _peerConnection = await createPeerConnection(_configuration);

      _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          closeRoom(_roomId!);
        }
      };
      waitForDataChannel();

      _localStream!.getTracks().forEach((track) {
        _peerConnection
            ?.addTrack(track, _localStream!)
            .catchError((error, stackTrace) {
          log(error, stackTrace: stackTrace);
        });
      });

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        calleeCandidatesCollection.add(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      _peerConnection?.onTrack = (RTCTrackEvent event) {
        event.streams[0].getTracks().forEach((track) {
          _remoteStream?.addTrack(track).catchError((error, stackTrace) {
            log(error, stackTrace: stackTrace);
          });
        });

        if (onAddRemoteStream != null && _remoteStream != null) {
          onAddRemoteStream!(_remoteStream!);
        }
      };

      // Code for creating SDP answer below
      var data = roomSnapshot.data() as Map<String, dynamic>;
      var offer = data['offer'];
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await _peerConnection!.createAnswer();

      await _peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await roomRef.update(roomWithAnswer);
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        for (var document in snapshot.docChanges) {
          var data = document.doc.data() as Map<String, dynamic>;
          _peerConnection!
              .addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          )
              .catchError((error, stackTrace) {
            log(error, stackTrace: stackTrace);
          });
        }
      }, onError: (error, stackTrace) {
        log(error, stackTrace: stackTrace);
      });
    }
  }

  void setLocalMediaStream(RTCVideoRenderer localVideo) {
    _localStream = localVideo.srcObject;
  }

  Future<void> initRemoteMediaStream(
    RTCVideoRenderer remoteVideo,
  ) async {
    remoteVideo.srcObject = await createLocalMediaStream('key');
    _remoteStream = remoteVideo.srcObject;
  }

  Future<void> hangUp() async {
    if (_remoteStream != null) {
      _remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (_peerConnection != null) _peerConnection!.close();

    if (_roomId != null) {
      var db = FirebaseFirestore.instance;
      var roomRef = db.collection('rooms').doc(_roomId);
      var calleeCandidates = await roomRef.collection('calleeCandidates').get();
      for (var document in calleeCandidates.docs) {
        document.reference.delete();
      }

      var callerCandidates = await roomRef.collection('callerCandidates').get();
      for (var document in callerCandidates.docs) {
        document.reference.delete();
      }

      await roomRef.delete();
    }

    _remoteStream?.dispose();
  }
}
