import 'dart:async';

import 'package:blink/src/draw/draw_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../bid/bid_service.dart';
import '../home/signaling.dart';
import '../lose/lose_screen.dart';
import '../user/user_service.dart';
import '../win/win_screen.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({
    Key? key,
    required this.localVideo,
    required this.remoteVideo,
    required this.eyesOpenStream,
    required this.signaling,
    required this.battleStartTime,
  }) : super(key: key);

  final RTCVideoRenderer localVideo;
  final RTCVideoRenderer remoteVideo;
  final Stream<dynamic> eyesOpenStream;
  final Signaling signaling;
  final DateTime battleStartTime;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> standLabelAnimation;
  late AnimationController standLabelController;
  TickerFuture? standLabelFutureTicker;
  int? downcount;
  bool hideDowncount = false;
  final _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;
  String stopwatchLabel = '';
  final _bidService = BidService();

  String standLabel = '';
  Timer? _bidTimeTimer;

  bool _isEmulator = false;

  StreamSubscription? eyesOpenStreamSubscriptoin;

  @override
  void initState() {
    super.initState();

    final countDownStartTime = DateTime.now();

    if (widget.battleStartTime.microsecondsSinceEpoch >
        countDownStartTime.microsecondsSinceEpoch) {
      final countDownDurationInMicroseconds =
          widget.battleStartTime.microsecondsSinceEpoch -
              countDownStartTime.microsecondsSinceEpoch;
      const frameDuration = Duration(seconds: 1);

      downcount =
          (countDownDurationInMicroseconds / frameDuration.inMicroseconds)
              .round();

      initTimer(downcount!, widget.battleStartTime, countDownStartTime);
    } else {
      // TODO: to be clear add startin of eyesopenstream here
      downcount = 0;
      Timer(const Duration(seconds: 1), () {
        setState(() {
          hideDowncount = true;
        });
      });
    }

    standLabelController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    standLabelAnimation =
        Tween<double>(begin: 0, end: 40).animate(standLabelController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });

    widget.signaling.onEnemyDidStand = () {
      setState(() {
        standLabel = 'Enemy did stand';
      });

      if (!standLabelController.isAnimating &&
          !standLabelController.isCompleted) {
        standLabelFutureTicker = standLabelController.forward();
        standLabelFutureTicker!.then((_) {
          return Future.delayed(const Duration(seconds: 2));
        }).then((_) {
          setState(() {
            standLabel = '';
          });
        });
      } else {
        standLabelFutureTicker!.then((_) {
          standLabelFutureTicker = standLabelController.forward();
          standLabelFutureTicker!.then((_) {
            return Future.delayed(const Duration(seconds: 2));
          }).then((_) {
            setState(() {
              standLabel = '';
            });
          });
        });
      }
    };
    widget.signaling.onEnemyDidNotStand = () {
      setState(() {
        standLabel = 'Enemy did not stand';
      });

      if (!standLabelController.isAnimating &&
          !standLabelController.isCompleted) {
        standLabelFutureTicker = standLabelController.forward();
        standLabelFutureTicker!.then((_) {
          return Future.delayed(const Duration(seconds: 2));
        }).then((_) {
          setState(() {
            standLabel = '';
          });
        });
      } else {
        standLabelFutureTicker!.then((_) {
          standLabelFutureTicker = standLabelController.forward();
          standLabelFutureTicker!.then((_) {
            return Future.delayed(const Duration(seconds: 2));
          }).then((_) {
            setState(() {
              standLabel = '';
            });
          });
        });
      }
    };
    widget.signaling.onWin = () {
      standLabelFutureTicker!.then((_) {
        return Future.delayed(const Duration(seconds: 3));
      }).then((_) {
        goToWinScreen();
      });

      _stopwatchTimer?.cancel();
      _stopwatch.stop();
      _checkHighestTime();
      UserService().increaseBalance(BidService().bidInBlk);
      UserService().increaseWins();
    };
    widget.signaling.onLose = () {
      standLabelFutureTicker!.then((_) {
        return Future.delayed(const Duration(seconds: 3));
      }).then((_) {
        goToLoseScreen();
      });
      _stopwatchTimer?.cancel();
      _stopwatch.stop();
      _checkHighestTime();
      UserService().decreaseBalance(BidService().bidInBlk);
      UserService().increaseDefeats();
    };
    widget.signaling.onDraw = () {
      standLabelFutureTicker!.then((_) {
        return Future.delayed(const Duration(seconds: 3));
      }).then((_) {
        goToDrawScreen();
      });
      _stopwatchTimer?.cancel();
      _stopwatch.stop();
      _checkHighestTime();
    };

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    deviceInfo.androidInfo.then((deviceInfo) {
      setState(() {
        _isEmulator = !deviceInfo.isPhysicalDevice!;
      });
    });
  }

  @override
  void dispose() {
    eyesOpenStreamSubscriptoin?.cancel();
    standLabelController.dispose();
    _bidTimeTimer?.cancel();

    widget.remoteVideo.dispose();

    super.dispose();
  }

  void goToLoseScreen() {
    widget.signaling.hangUp();
    Navigator.popAndPushNamed(context, LoseScreen.routeName);
  }

  void goToWinScreen() {
    widget.signaling.hangUp();
    Navigator.popAndPushNamed(context, WinScreen.routeName);
  }

  void goToDrawScreen() {
    widget.signaling.hangUp();
    Navigator.popAndPushNamed(context, DrawScreen.routeName);
  }

  Duration timerDuration(int count, DateTime end) {
    if (count == 0) return const Duration(seconds: 1);
    final remainingTime = end.difference(DateTime.now());
    final durationInMicroseconds = remainingTime.inMicroseconds ~/ count;
    return Duration(microseconds: durationInMicroseconds);
  }

  void initTimer(int count, DateTime end, DateTime start) {
    Timer(timerDuration(count, end), () {
      setState(() {
        if (downcount != null) {
          downcount = downcount! - 1;
        }
      });
      count--;
      if (count >= 0) {
        initTimer(count, end, start);
      } else {
        eyesOpenStreamSubscriptoin = widget.eyesOpenStream.listen((data) {
          if (!widget.signaling.isReadyToPlay) return;

          if (data is bool) {
            final isUserLoser = !data;
            if (isUserLoser && widget.signaling.didUserStand == null) {
              eyesOpenStreamSubscriptoin?.cancel();
              _stopwatchTimer?.cancel();
              _stopwatch.stop();
              if (_bidService.bidTimeInSeconds <=
                  _stopwatch.elapsed.inSeconds) {
                widget.signaling.sendUserDidStandSingal();
                setState(() {
                  standLabel = 'You did stand';
                });
              } else {
                widget.signaling.sendUserDidNotStandSingal();
                setState(() {
                  standLabel = 'You did not stand';
                });
              }

              _bidTimeTimer?.cancel();
              if (!standLabelController.isAnimating &&
                  !standLabelController.isCompleted) {
                standLabelFutureTicker = standLabelController.forward();
                standLabelFutureTicker!.then((_) {
                  return Future.delayed(const Duration(seconds: 2));
                }).then((_) {
                  setState(() {
                    standLabel = '';
                  });
                });
              } else {
                standLabelFutureTicker!.then((_) {
                  standLabelFutureTicker = standLabelController.forward();
                  standLabelFutureTicker!.then((_) {
                    return Future.delayed(const Duration(seconds: 2));
                  }).then((_) {
                    setState(() {
                      standLabel = '';
                    });
                  });
                });
              }
            }
          }
        }, onError: (error, stackTrace) {
          if (widget.signaling.didUserStand != null) return;
          eyesOpenStreamSubscriptoin?.cancel();
          _stopwatchTimer?.cancel();
          _stopwatch.stop();
          if (_bidService.bidTimeInSeconds <= _stopwatch.elapsed.inSeconds) {
            widget.signaling.sendUserDidStandSingal();
            setState(() {
              standLabel = 'You did stand';
            });
          } else {
            widget.signaling.sendUserDidNotStandSingal();
            setState(() {
              standLabel = 'You did not stand';
            });
          }
          _bidTimeTimer?.cancel();

          if (!standLabelController.isAnimating &&
              !standLabelController.isCompleted) {
            standLabelFutureTicker = standLabelController.forward();
            standLabelFutureTicker!.then((_) {
              return Future.delayed(const Duration(seconds: 2));
            }).then((_) {
              setState(() {
                standLabel = '';
              });
            });
          } else {
            standLabelFutureTicker!.then((_) {
              standLabelFutureTicker = standLabelController.forward();
              standLabelFutureTicker!.then((_) {
                return Future.delayed(const Duration(seconds: 2));
              }).then((_) {
                setState(() {
                  standLabel = '';
                });
              });
            });
          }
        });
        const updateFrequency = Duration(milliseconds: 100);
        _stopwatch.start();
        setState(() {
          stopwatchLabel = _stopwatchLabel;
        });
        _stopwatchTimer = Timer.periodic(updateFrequency, _updateStopwatch);

        setState(() {
          hideDowncount = true;
        });

        _bidTimeTimer =
            Timer(Duration(seconds: _bidService.bidTimeInSeconds), () {
          _stopwatchTimer?.cancel();
          _stopwatch.stop();
          eyesOpenStreamSubscriptoin?.cancel();
          setState(() {
            standLabel = 'You did stand';
          });

          if (!standLabelController.isAnimating &&
              !standLabelController.isCompleted) {
            standLabelFutureTicker = standLabelController.forward();
            standLabelFutureTicker!.then((_) {
              return Future.delayed(const Duration(seconds: 2));
            }).then((_) {
              setState(() {
                standLabel = '';
              });
            });
          } else {
            standLabelFutureTicker!.then((_) {
              standLabelFutureTicker = standLabelController.forward();
              standLabelFutureTicker!.then((_) {
                return Future.delayed(const Duration(seconds: 2));
              }).then((_) {
                setState(() {
                  standLabel = '';
                });
              });
            });
          }

          widget.signaling.sendUserDidStandSingal();
        });
      }
    });
  }

  String get _stopwatchLabel =>
      '${_stopwatch.elapsed.inMinutes % 60}:${_stopwatch.elapsed.inSeconds % 60}:${(_stopwatch.elapsed.inMilliseconds % 1000) ~/ 100}';

  void _updateStopwatch(Timer timer) {
    setState(() {
      stopwatchLabel = _stopwatchLabel;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            child: RotatedBox(
              quarterTurns: _isEmulator ? 3 : 0,
              child: RTCVideoView(
                widget.remoteVideo,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
          Positioned(
            top: 8 + MediaQuery.of(context).viewPadding.top,
            left: 8,
            child: SizedBox(
              width: 100,
              height: 140,
              child: RotatedBox(
                quarterTurns: _isEmulator ? 3 : 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: RTCVideoView(
                      widget.localVideo,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: Padding(
              padding: const EdgeInsets.only(top: 400),
              child: ArcText(
                radius: 400,
                text: standLabel,
                textStyle: TextStyle(
                  fontSize: standLabelAnimation.value,
                  color: Colors.blue,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                    ),
                  ],
                ),
                startAngleAlignment: StartAngleAlignment.center,
              ),
            ),
          ),
          Positioned(
            child: Countdown(
                text: downcount != 0
                    ? (downcount == -1 ? '' : downcount).toString()
                    : 'NOT BLINK!!!'),
          ),
          Positioned(
            bottom: 100,
            child: StopWatchLabel(text: stopwatchLabel),
          ),
        ],
      ),
    );
  }
}

class StopWatchLabel extends StatelessWidget {
  const StopWatchLabel({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 50,
        color: Colors.blue,
        shadows: [
          Shadow(
            color: Colors.black38,
          ),
        ],
      ),
    );
  }
}

class Countdown extends StatelessWidget {
  final String text;

  const Countdown({this.text = '', Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 50,
        color: Colors.blue,
        shadows: [
          Shadow(
            color: Colors.black38,
          ),
        ],
      ),
    );
  }
}
