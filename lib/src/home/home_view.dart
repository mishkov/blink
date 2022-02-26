import 'dart:async';

import 'package:blink/src/drawer/app_drawer.dart';
import 'package:blink/src/home/home_model_view.dart';
import 'package:blink/src/lobby/lobby.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../device_info/device_info_bloc.dart';

class HomeView extends StatelessWidget {
  static const routeName = '/home';

  const HomeView({Key? key}) : super(key: key);

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
                    child: BitInput(
                      bid: homeState.bidInDollars.toString(),
                      onChanged: (newBid) {
                        modelView.bidInDollars = int.tryParse(newBid);
                      },
                    ),
                  ),
                  Expanded(
                    child: homeState.localVideo != null
                        ? BlocBuilder<DeviceInfoBloc, DeviceInfo>(
                            builder: (_, state) {
                            return RotatedBox(
                              quarterTurns: state.isEmulator ?? false ? 1 : 0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: RTCVideoView(
                                  homeState.localVideo!,
                                  mirror: true,
                                  objectFit: RTCVideoViewObjectFit
                                      .RTCVideoViewObjectFitCover,
                                ),
                              ),
                            );
                          })
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

class BitInput extends StatelessWidget {
  final String bid;
  final void Function(String) onChanged;
  const BitInput({
    required this.bid,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: bid,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.bidInputTitle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
