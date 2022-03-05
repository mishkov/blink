import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:blink/src/local_camera/local_camera_service.dart';

import '../user/user_service.dart';

class BattleWithBotModelView extends Cubit<BattleWithBotState> {
  final AppLocalizations _localizations;
  Timer? _eyesOfEnemyIsOpenTimer;
  bool _didUserBlink = false;
  StreamSubscription? _eyesOpenStreamSubscription;
  int _countdown = 10;
  final _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;

  BattleWithBotModelView({required localizations})
      : _localizations = localizations,
        super(BattleWithBotState(
          video: LocalCameraService().video,
          countdownLabel: localizations.requestToWait,
          showCountdown: true,
          isLose: false,
          isWin: false,
          stopwatchLabel: '',
          showStopwatch: false,
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
      _onBattleStart();
      timer.cancel();
    }

    _countdown--;
  }

  void _onBattleStart() {
    _eyesOfEnemyIsOpenTimer = Timer(
      _randomTimeOfOpenEyes,
      _onEnemyBlinks,
    );

    const updateFrequency = Duration(milliseconds: 100);
    _stopwatch.start();
    emit(state.copyWith(
      showStopwatch: true,
      stopwatchLabel: _stopwatchLabel,
    ));
    _stopwatchTimer = Timer.periodic(updateFrequency, _updateStopwatch);

    _eyesOpenStreamSubscription = LocalCameraService().eyesOpenStream?.listen(
      (event) {
        if (event is bool) {
          final isEyesOpen = event;
          if (!isEyesOpen) {
            _onUserBlinks();
          }
        }
      },
    );
  }

  Duration get _randomTimeOfOpenEyes => Duration(seconds: _randomInt(35, 90));

  int _randomInt(int from, int to) {
    return from + math.Random().nextInt(to - from);
  }

  String get _stopwatchLabel =>
      '${_stopwatch.elapsed.inMinutes % 60}:${_stopwatch.elapsed.inSeconds % 60}:${(_stopwatch.elapsed.inMilliseconds % 1000) ~/ 100}';

  void _onEnemyBlinks() {
    if (!_didUserBlink) {
      emit(state.copyWith(isWin: true));
      _eyesOpenStreamSubscription?.cancel();
      _stopwatchTimer?.cancel();
      _stopwatch.stop();
      _checkHighestTime();
      UserService().increaseWins();
    }
  }

  void _onUserBlinks() {
    _didUserBlink = true;
    _eyesOpenStreamSubscription?.cancel();
    _eyesOfEnemyIsOpenTimer?.cancel();
    _stopwatchTimer?.cancel();
    _stopwatch.stop();
    _checkHighestTime();
    UserService().increaseDefeats();

    emit(state.copyWith(isLose: true));
  }

  void _updateStopwatch(Timer timer) {
    emit(state.copyWith(stopwatchLabel: _stopwatchLabel));
  }

  Future<void> _checkHighestTime() async {
    final userService = UserService();
    final highestTime = userService.user?.highestTime;
    if (highestTime != null) {
      if (highestTime < _stopwatch.elapsedMilliseconds) {
        await userService.updateHighestTime(_stopwatch.elapsedMilliseconds);
      }
    }
  }
}

class BattleWithBotState {
  final RTCVideoRenderer video;
  final String countdownLabel;
  final bool showCountdown;
  final bool isWin;
  final bool isLose;
  final String stopwatchLabel;
  final bool showStopwatch;

  BattleWithBotState({
    required this.video,
    required this.countdownLabel,
    required this.showCountdown,
    required this.isWin,
    required this.isLose,
    required this.stopwatchLabel,
    required this.showStopwatch,
  });

  BattleWithBotState copyWith({
    RTCVideoRenderer? video,
    String? countdownLabel,
    bool? showCountdown,
    bool? isWin,
    bool? isLose,
    String? stopwatchLabel,
    bool? showStopwatch,
  }) {
    return BattleWithBotState(
      video: video ?? this.video,
      countdownLabel: countdownLabel ?? this.countdownLabel,
      showCountdown: showCountdown ?? this.showCountdown,
      isWin: isWin ?? this.isWin,
      isLose: isLose ?? this.isLose,
      stopwatchLabel: stopwatchLabel ?? this.stopwatchLabel,
      showStopwatch: showStopwatch ?? this.showStopwatch,
    );
  }
}
