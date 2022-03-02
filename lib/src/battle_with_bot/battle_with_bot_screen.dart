import 'package:blink/src/battle_with_bot/battle_with_bot_model_view.dart';
import 'package:blink/src/lose/lose_screen.dart';
import 'package:blink/src/win/win_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../device_info/device_info_bloc.dart';

class BattleWithBotScreen extends StatelessWidget {
  static const routeName = '/battle_with_bot';

  const BattleWithBotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocProvider<BattleWithBotModelView>(
        create: (context) {
          return BattleWithBotModelView(
            localizations: localizations,
          );
        },
        child: BlocListener<BattleWithBotModelView, BattleWithBotState>(
          listenWhen: (_, current) {
            return current.isLose || current.isWin;
          },
          listener: (context, state) {
            if (state.isWin) {
              Navigator.popAndPushNamed(context, WinScreen.routeName);
            } else {
              Navigator.popAndPushNamed(context, LoseScreen.routeName);
            }
          },
          child: BlocBuilder<BattleWithBotModelView, BattleWithBotState>(
            builder: (context, state) {
              return Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  const Positioned(
                    child: EnemyView(),
                  ),
                  Positioned(
                    top: 8 + MediaQuery.of(context).viewPadding.top,
                    left: 8,
                    child: LocalVideo(video: state.video),
                  ),
                  // TODO: Implement BlinkLabelBloc and wrap comment code with it
                  //
                  // Positioned(
                  //   child: ArcText(
                  //     radius: 200,
                  //     // TODO: Add localization
                  //     text: 'BLINK!!!',
                  //     textStyle: TextStyle(
                  //       fontSize: blinkLabelAnimation.value,
                  //       color: Colors.blue,
                  //       shadows: const [
                  //         Shadow(
                  //           color: Colors.black38,
                  //         ),
                  //       ],
                  //     ),
                  //     startAngleAlignment: StartAngleAlignment.center,
                  //   ),
                  // ),
                  Positioned(
                    child: Countdown(
                      visible: state.showCountdown,
                      label: state.countdownLabel,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class Countdown extends StatelessWidget {
  final bool visible;
  final String label;

  const Countdown({
    Key? key,
    required this.visible,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 70,
          color: Colors.blue,
          shadows: [
            Shadow(
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class EnemyView extends StatelessWidget {
  const EnemyView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return FittedBox(
        fit: BoxFit.fill,
        clipBehavior: Clip.hardEdge,
        child: Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 31, 30, 30),
          ),
          child: Image.asset(
            'assets/images/bot_image.png',
          ),
        ),
      );
    });
  }
}

class LocalVideo extends StatelessWidget {
  final RTCVideoRenderer video;
  const LocalVideo({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 140,
      child: BlocBuilder<DeviceInfoBloc, DeviceInfo>(
        builder: (_, state) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: RotatedBox(
                quarterTurns: state.isEmulator ?? false ? 3 : 0,
                child: RTCVideoView(
                  video,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
