import 'dart:async';

import 'package:blink/src/bid/bid_service.dart';
import 'package:blink/src/drawer/app_drawer.dart';
import 'package:blink/src/home/home_model_view.dart';
import 'package:blink/src/lobby/lobby.dart';
import 'package:blink/src/select_mode/select_mode_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

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
                    child: BidInput(
                      bid: homeState.bidInBlk.toString(),
                      onChanged: (newBid) {
                        modelView.bidInBlk = int.tryParse(newBid);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: BidTimeInput(
                      bidTime: modelView.bidTimeInSeconds.toString(),
                      onChanged: (newBidTime) {
                        modelView.bidTimeInSeconds = int.tryParse(newBidTime);
                      },
                    ),
                  ),
                  Expanded(
                    child: homeState.localVideo != null
                        ? Mirror(video: homeState.localVideo!)
                        : const CameraIsLoadingMessage(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: EyesStatus(
                      eyesOpenStream: homeState.eyesOpenStream,
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

class CameraIsLoadingMessage extends StatelessWidget {
  const CameraIsLoadingMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              AppLocalizations.of(context)!.cameraIsLoadingNotification,
            ),
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class Mirror extends StatelessWidget {
  final RTCVideoRenderer video;

  const Mirror({
    required this.video,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceInfoBloc, DeviceInfo>(
      builder: (_, state) {
        return RotatedBox(
          quarterTurns: state.isEmulator ?? false ? 1 : 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: RTCVideoView(
              video,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        );
      },
    );
  }
}

class EyesStatus extends StatelessWidget {
  final Stream<dynamic>? eyesOpenStream;
  const EyesStatus({
    required this.eyesOpenStream,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      label: StreamBuilder(
        stream: eyesOpenStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final isEyesOpen = snapshot.data as bool;
            return Text(isEyesOpen
                ? AppLocalizations.of(context)!.eyesIsOpenStatus
                : AppLocalizations.of(context)!.eyesIsClosedStatus);
          } else {
            return Text(AppLocalizations.of(context)!.requestToPutFaceToCamera);
          }
        },
      ),
    );
  }
}

class BidInput extends StatelessWidget {
  final String bid;
  final void Function(String) onChanged;

  const BidInput({
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

class BidTimeInput extends StatelessWidget {
  final String bidTime;
  final void Function(String) onChanged;

  const BidTimeInput({
    required this.bidTime,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: bidTime,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.bidTimeInputTitle,
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
              // TODO: Remove comment below
              //
              // This code was actual in version without SelectModeScreen
              //
              // final args = {
              //   // this parameter have never been used
              //   'homeModelView': cubit,
              //   // this parameters is not used now
              //   'localVideo': localVideo,
              //   // this parameters is not used now
              //   'eyesOpenStream': eyesOpenStream,
              // };
              // Navigator.pushNamed(context, Lobby.routeName, arguments: args);

              Navigator.pushNamed(context, SelectModeScreen.routeName);
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
