import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:blink/src/local_camera/local_camera_service.dart';

class BattleWithBotModelView extends Cubit<BattleWithBotState> {
  final AppLocalizations _localizations;
  Timer? _eyesOfEnemyIsOpenTimer;
  bool _didUserBlink = false;
  StreamSubscription? _eyesOpenStreamSubscription;
  int _countdown = 10;

  BattleWithBotModelView({required localizations})
      : _localizations = localizations,
        super(BattleWithBotState(
          video: LocalCameraService().video,
          countdownLabel: localizations.requestToWait,
          showCountdown: true,
          isLose: false,
          isWin: false,
        )) {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, _decreaseCountdown);
  }

  void _decreaseCountdown(Timer timer) {
    if (_countdown > 0) {
      emit(state.copyWith(
        countdownLabel: _countdown.toString(),
      ));
    } else if (_countdown == 0) {
      emit(state.copyWith(
        countdownLabel: _localizations.doNotBlinkLabel,
      ));
    } else {
      emit(state.copyWith(showCountdown: false));
      onBattleStart();
      timer.cancel();
    }

    _countdown--;
  }

  void onBattleStart() {
    _eyesOfEnemyIsOpenTimer = Timer(
      _randomTimeOfOpenEyes,
      _onEnemyBlinks,
    );

    _eyesOpenStreamSubscription = LocalCameraService().eyesOpenStream?.listen(
      (event) {
        if (event is bool) {
          final isEyesOpen = event;
          if (!isEyesOpen) {
            _didUserBlink = true;
            _eyesOpenStreamSubscription?.cancel();
            _eyesOfEnemyIsOpenTimer?.cancel();

            emit(state.copyWith(isLose: true));
          }
        }
      },
    );
  }

  Duration get _randomTimeOfOpenEyes => Duration(seconds: _randomInt(35, 90));

  int _randomInt(int from, int to) {
    return from + math.Random().nextInt(to - from);
  }

  void _onEnemyBlinks() {
    if (!_didUserBlink) {
      emit(state.copyWith(isWin: true));
      _eyesOpenStreamSubscription?.cancel();
    }
  }
}

class BattleWithBotState {
  final RTCVideoRenderer video;
  final String countdownLabel;
  final bool showCountdown;
  final bool isWin;
  final bool isLose;

  BattleWithBotState({
    required this.video,
    required this.countdownLabel,
    required this.showCountdown,
    required this.isWin,
    required this.isLose,
  });

  BattleWithBotState copyWith({
    RTCVideoRenderer? video,
    String? countdownLabel,
    bool? showCountdown,
    bool? isWin,
    bool? isLose,
  }) {
    return BattleWithBotState(
      video: video ?? this.video,
      countdownLabel: countdownLabel ?? this.countdownLabel,
      showCountdown: showCountdown ?? this.showCountdown,
      isWin: isWin ?? this.isWin,
      isLose: isLose ?? this.isLose,
    );
  }
}
