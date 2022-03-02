import 'package:flutter_webrtc/flutter_webrtc.dart';

class SignalingService {
  MediaStream? _localStream;
  final _remoteRenderer = RTCVideoRenderer();

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun.l.google.com:19302',
        ]
      }
    ]
  };

  static final _instance = SignalingService._internal();

  factory SignalingService() => _instance;

  SignalingService._internal();

  set localStream(MediaStream? stream) => _localStream = stream;

  Future<void> initRemoteRenderer() async {
    await _remoteRenderer.initialize();
    _remoteRenderer.srcObject = await createLocalMediaStream('key');
  }

  Future<void> dispose() async {}
}
