import 'package:blink/src/signaling/signaling_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class LobbyModelView extends Cubit<LobbyState> {
  LobbyModelView({MediaStream? localStream}) : super(LobbyState()) {
    SignalingService().localStream = localStream;
  }

  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }
}

class LobbyState {}
