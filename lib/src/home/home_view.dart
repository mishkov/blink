import 'dart:async';
import 'dart:developer';

import 'package:blink/src/drawer/app_drawer.dart';
import 'package:blink/src/home/home_model_view.dart';
import 'package:blink/src/home/signaling.dart';
import 'package:blink/src/lobby/lobby.dart';
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
  // Need to rotate local image on android emulator
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
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider(
          create: (_) => HomeModelView(),
          child: BlocBuilder<HomeModelView, HomeState>(
            builder: (context, homeState) {
              final cubit = context.read<HomeModelView>();

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
                              return Lobby(
                                homeModelView: cubit,
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
