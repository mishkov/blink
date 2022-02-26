import 'dart:async';
import 'dart:math';

import 'package:blink/src/drawer/app_drawer.dart';
import 'package:blink/src/home/home_model_view.dart';
import 'package:blink/src/lobby/lobby.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HomeView extends StatefulWidget {
  static const routeName = '/home';

  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Need to rotate local image on android emulator
  bool isEmulator = false;

  @override
  void initState() {
    super.initState();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    deviceInfo.androidInfo.then((deviceInfo) {
      return isEmulator = !deviceInfo.isPhysicalDevice!;
    });
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
              final modelView = context.read<HomeModelView>();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 8,
                    ),
                    child: TextFormField(
                      initialValue: homeState.bidInDollars.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (newBid) {
                        modelView.bidInDollars = int.tryParse(newBid);
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.bidInputTitle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: homeState.localVideo != null
                        ? RotatedBox(
                            quarterTurns: isEmulator ? 1 : 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: RTCVideoView(
                                homeState.localVideo!,
                                mirror: true,
                                objectFit: RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                              ),
                            ),
                          )
                        : Center(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .cameraIsLoadingNotification,
                                  ),
                                ),
                                const CircularProgressIndicator(),
                              ],
                            ),
                          ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Chip(
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      label: StreamBuilder(
                        stream: homeState.eyesOpenStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final isEyesOpen = snapshot.data as bool;
                            return Text(isEyesOpen
                                ? AppLocalizations.of(context)!.eyesIsOpenStatus
                                : AppLocalizations.of(context)!
                                    .eyesIsClosedStatus);
                          } else {
                            return Text(AppLocalizations.of(context)!
                                .requestToPutFaceToCamera);
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: PlayButton(
                      cubit: modelView,
                      localVideo: homeState.localVideo,
                      eyesOpenStream: homeState.eyesOpenStream,
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

class PlayButton extends StatelessWidget {
  final HomeModelView cubit;
  final RTCVideoRenderer? localVideo;
  final Stream? eyesOpenStream;

  const PlayButton(
      {required this.cubit,
      required this.localVideo,
      required this.eyesOpenStream,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: localVideo != null && eyesOpenStream != null
          ? () {
              final args = {
                'homeModelView': cubit,
                'localVideo': localVideo,
                'eyesOpenStream': eyesOpenStream,
              };
              Navigator.pushNamed(context, Lobby.routeName, arguments: args);
            }
          : null,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 32,
        ),
        child: Text(
          AppLocalizations.of(context)!.playButton,
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
