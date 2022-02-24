import 'dart:async';
import 'dart:developer';

import 'package:blink/src/home/bloc.dart';
import 'package:blink/src/home/signaling.dart';
import 'package:blink/src/settings/settings_view.dart';
import 'package:blink/src/user/user_bloc.dart';
import 'package:blink/src/login/login_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';

class HomeView extends StatefulWidget {
  static const routeName = '/home';

  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isEmulator = false;
  RTCVideoRenderer localVideo = RTCVideoRenderer();
  Stream? eyesOpenStream;

  @override
  void initState() {
    super.initState();

    localVideo.initialize().then((_) async {
      await openUserMedia();
      setState(() {});
    }).then((_) async {
      eyesOpenStream = await localVideo.srcObject
          ?.getVideoTracks()
          .first
          .startEyesOpenStream();
      setState(() {});
    });

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    deviceInfo.androidInfo.then((deviceInfo) {
      return isEmulator = !deviceInfo.isPhysicalDevice!;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> openUserMedia() async {
    var stream = await navigator.mediaDevices.getUserMedia(
      {
        "audio": false,
        "video": {
          "width": 480,
          "height": 360,
        }
      },
    );

    localVideo.srcObject = stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      drawer: BlocBuilder<UserBloc, UserState>(builder: (context, userState) {
        if (userState is! ReadyUserState) return const Text('Error');
        final user = userState.user;
        return Drawer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80.0, left: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: user != null
                            ? user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user == null
                                ? 'no user'
                                : user.name ?? 'no name'),
                            Text(user == null
                                ? 'no user'
                                : user.email ?? 'no email'),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('The Highest Time'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
                  child: Text(
                      user == null ? 'no user' : user.highestTime.toString()),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Balance'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
                  child:
                      Text(user == null ? 'no user' : user.balance.toString()),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Won'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
                  child: Text(user == null ? 'no user' : user.won.toString()),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Lost'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
                  child: Text(user == null ? 'no user' : user.won.toString()),
                ),
                const Divider(),
                TextButton(
                    onPressed: () {
                      Navigator.restorablePushNamed(
                          context, SettingsView.routeName);
                    },
                    child: const Text(
                      'Settings',
                      style: TextStyle(color: Colors.blue),
                    )),
                TextButton(
                  onPressed: () {
                    context.read<UserBloc>().logout();
                    Navigator.restorablePushNamed(context, LoginView.routeName);
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider(
          create: (_) => HomeCubit(),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, homeState) {
              final cubit = context.read<HomeCubit>();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 8,
                    ),
                    child: TextFormField(
                      initialValue: cubit.bidInDollars.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (newBid) {
                        cubit.bidInDollars = double.parse(newBid);
                      },
                      decoration: InputDecoration(
                        labelText: 'Bid (Not working now)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: isEmulator ? 1 : 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: RTCVideoView(
                          localVideo,
                          mirror: true,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Chip(
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      label: StreamBuilder(
                        stream: eyesOpenStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final isEyesOpen = snapshot.data as bool;
                            return Text(
                                isEyesOpen ? 'Eyes is open' : 'Eyes is close');
                          } else {
                            return const Text('Please put your face to camera');
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return BattleNavigation(
                                cubit: cubit,
                                localVideo: localVideo,
                                eyesOpenStream: eyesOpenStream,
                              );
                            },
                          ),
                        );
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.0),
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32,
                        ),
                        child: Text(
                          'Play',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
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

class BattleNavigation extends StatefulWidget {
  const BattleNavigation({
    Key? key,
    required this.cubit,
    required this.localVideo,
    required this.eyesOpenStream,
  }) : super(key: key);

  final HomeCubit cubit;
  final RTCVideoRenderer localVideo;
  final Stream<dynamic>? eyesOpenStream;

  @override
  _BattleNavigationState createState() => _BattleNavigationState();
}

class _BattleNavigationState extends State<BattleNavigation> {
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
  late Animation<double> blinkLabelAnimation;
  late AnimationController blinkLabelController;
  TickerFuture? blinkLabelFutureTicker;
  int? downcount;
  bool hideDowncount = false;

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
      downcount = 1;
      Timer(const Duration(seconds: 1), () {
        setState(() {
          hideDowncount = true;
        });
      });
    }

    blinkLabelController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    blinkLabelAnimation =
        Tween<double>(begin: 0, end: 70).animate(blinkLabelController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });

    widget.signaling.onWin = () {
      goToWinScreen();
    };
    widget.signaling.onLose = () {
      blinkLabelFutureTicker!.then((_) {
        return Future.delayed(const Duration(seconds: 1));
      }).then((_) {
        goToLoseScreen();
      });
    };
    widget.signaling.onDraw = () {
      // TODO: change to draw screen
      goToLoseScreen();
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
    blinkLabelController.dispose();

    widget.remoteVideo.dispose();

    super.dispose();
  }

  void goToLoseScreen() {
    Navigator.popAndPushNamed(context, LoseScreen.routeName,
        arguments: {'signaling': widget.signaling});
  }

  void goToWinScreen() {
    Navigator.popAndPushNamed(context, WinScreen.routeName,
        arguments: {'signaling': widget.signaling});
  }

  Duration timerDuration(int count, DateTime end) {
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
      if (count > 0) {
        initTimer(count, end, start);
      } else {
        eyesOpenStreamSubscriptoin = widget.eyesOpenStream.listen((data) {
          if (!widget.signaling.isReadyToPlay) return;

          if (data is bool) {
            final isUserLoser = !data;
            if (isUserLoser) {
              if (!blinkLabelController.isAnimating &&
                  !blinkLabelController.isCompleted) {
                blinkLabelFutureTicker = blinkLabelController.forward();
              }

              widget.signaling.sendBlinkTime();
            }
          }
        }, onError: (error, stackTrace) {
          if (!blinkLabelController.isAnimating &&
              !blinkLabelController.isCompleted) {
            blinkLabelFutureTicker = blinkLabelController.forward();
          }
          widget.signaling.sendBlinkTime();
        });

        setState(() {
          hideDowncount = true;
        });
      }
    });
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
            child: ArcText(
              radius: 200,
              text: 'BLINK!!!',
              textStyle: TextStyle(
                fontSize: blinkLabelAnimation.value,
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
          Positioned(
            child: Visibility(
              visible: !hideDowncount,
              child: Text(
                downcount != 1 ? downcount.toString() : 'NOT BLINK!!!',
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
            ),
          ),
        ],
      ),
    );
  }
}

class WinScreen extends StatefulWidget {
  static const routeName = '/winscreen';
  final Signaling signaling;

  const WinScreen({Key? key, required this.signaling}) : super(key: key);

  @override
  State<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<WinScreen> {
  @override
  void dispose() {
    widget.signaling.hangUp();
    super.dispose();
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
                              'assets/images/squid_game_winner_face.png'),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 64.0),
                      child: Text(
                        'You are winner!!!',
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
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, HomeView.routeName);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
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
                    'Home',
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

class LoseScreen extends StatefulWidget {
  static const routeName = '/losescreen';

  final Signaling signaling;

  const LoseScreen({Key? key, required this.signaling}) : super(key: key);

  @override
  State<LoseScreen> createState() => _LoseScreenState();
}

class _LoseScreenState extends State<LoseScreen> {
  @override
  void dispose() {
    widget.signaling.hangUp();
    super.dispose();
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
                              'assets/images/squid_game_loser_face.jpeg'),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 64.0),
                      child: Text(
                        'You are loser',
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
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, HomeView.routeName);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
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
                    'Home',
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
