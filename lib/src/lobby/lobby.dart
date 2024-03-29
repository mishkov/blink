import 'dart:developer';

import 'package:blink/src/bid/bid_service.dart';
import 'package:blink/src/local_camera/local_camera_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../battle/battle_screen.dart';
import '../home/home_model_view.dart';
import '../home/signaling.dart';

// TODO: Make this widget stateless
class Lobby extends StatefulWidget {
  static const routeName = '/lobby';

  const Lobby({
    Key? key,
  }) : super(key: key);

  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  final _remoteRenderer = RTCVideoRenderer();
  late final Signaling _signaling;
  String _roomId = '';

  @override
  void initState() {
    super.initState();
    _signaling =
        Signaling(BidService().bidInBlk, BidService().bidTimeInSeconds);

    // TODO: Move all of this initializations to `LobbyModelView`
    _signaling.setLocalMediaStream(LocalCameraService().video);

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
    // TODO: Move this code to `LobbyViewModel.close()` method
    if (_roomId.isNotEmpty) {
      _signaling.closeRoom(_roomId);
    }

    super.dispose();
  }

  // TODO: Move this to `LobbyViewModel`
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
    // TODO: rewrite this to Navigator.popAndPushNamed()
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return BattleScreen(
            // TODO: Remove LocalCameraService().video to hell and move it to
            // modelview of this screen
            localVideo: LocalCameraService().video,
            remoteVideo: _remoteRenderer,
            // TODO: Like in few lines above you have to remove this code from
            // here and put it to the modelview of this screen
            eyesOpenStream: LocalCameraService().eyesOpenStream!,
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
            const Expanded(
              child: PleaseWaitMessage(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: LeaveQueueButton(
                onPressed: () {
                  // TODO: Move this code to LobbyModelView.close() method
                  _signaling.hangUp();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PleaseWaitMessage extends StatelessWidget {
  const PleaseWaitMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: WaitingPersonImage(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 64.0),
            child: Text(
              AppLocalizations.of(context)!.requestToWaitForEnemy,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaveQueueButton extends StatelessWidget {
  final void Function()? onPressed;

  const LeaveQueueButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.red),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 24,
        ),
        child: Text(
          AppLocalizations.of(context)!.leaveQueueButton,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class WaitingPersonImage extends StatelessWidget {
  const WaitingPersonImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: const Image(
        image: AssetImage('assets/images/squid_game_waiting.jpg'),
      ),
    );
  }
}
