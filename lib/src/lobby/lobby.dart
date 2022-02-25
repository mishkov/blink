import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../battle/battle_screen.dart';
import '../home/home_model_view.dart';
import '../home/signaling.dart';

class Lobby extends StatefulWidget {
  static const routeName = '/lobby';

  const Lobby({
    Key? key,
    required this.homeModelView,
    required this.localVideo,
    required this.eyesOpenStream,
  }) : super(key: key);

  final HomeModelView homeModelView;
  final RTCVideoRenderer localVideo;
  final Stream<dynamic>? eyesOpenStream;

  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  final _remoteRenderer = RTCVideoRenderer();
  final _signaling = Signaling();
  String _roomId = '';

  @override
  void initState() {
    super.initState();

    _signaling.setLocalMediaStream(widget.localVideo);

    _remoteRenderer.initialize().then((_) {
      _signaling.initRemoteMediaStream(_remoteRenderer);
    });

    _signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    initRoom().catchError((error, stackTrace) {
      log(error, stackTrace: stackTrace);
    });
  }

  @override
  void dispose() {
    if (_roomId.isNotEmpty) {
      _signaling.closeRoom(_roomId);
    }

    super.dispose();
  }

  Future<void> initRoom() async {
    if (await _signaling.isThereEmptyRoom()) {
      _roomId = await _signaling.getFirstFreeRoomId();
      await _signaling.joinRoom(
        _roomId,
      );
    } else {
      _roomId = await _signaling.createRoom();
    }

    _signaling.onReadyToPlay = goToBattleScreen;
  }

  void goToBattleScreen(DateTime battleStartTime) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return BattleScreen(
            localVideo: widget.localVideo,
            remoteVideo: _remoteRenderer,
            eyesOpenStream: widget.eyesOpenStream!,
            signaling: _signaling,
            battleStartTime: battleStartTime,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: const Image(
                          image: AssetImage(
                              'assets/images/squid_game_waiting.jpg'),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 64.0),
                      child: Text(
                        'Please wait for another player...',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: ElevatedButton(
                onPressed: () {
                  _signaling.hangUp();
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 24,
                  ),
                  child: Text(
                    'Leave queue',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
