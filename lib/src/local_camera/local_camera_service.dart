import 'package:flutter_webrtc/flutter_webrtc.dart';

class LocalCameraService {
  final _localRenderer = RTCVideoRenderer();
  Stream<dynamic>? _eyesOpenStream;

  static final _instance = LocalCameraService._internal();

  factory LocalCameraService() => _instance;

  LocalCameraService._internal();

  RTCVideoRenderer get video => _localRenderer;

  Stream<dynamic>? get eyesOpenStream => _eyesOpenStream;

  Future<void> initLocalRenderer() async {
    await _localRenderer.initialize();
    final mediaConstraints = {
      "audio": false,
      "video": {
        "width": 480,
        "height": 360,
      }
    };
    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localRenderer.srcObject = stream;
  }

  /// Dispose `RTCVideoRenderer`
  ///
  /// Stops the eyesOpenStream if it was started.
  Future<void> disposeLocalRenderer() async {
    if (_eyesOpenStream != null) {
      final video = _localRenderer.srcObject!.getVideoTracks().first;

      await video.stopEyesOpenStream();
    }

    await _localRenderer.dispose();
  }

  /// Init eyesOpenStream for local video
  ///
  /// Must be called after `initLocalRenderer` otherwise
  /// `NoSourceObjectException` will be thrown. `NoVideoTrackException` will be
  /// thrown if `RTCVideoRenderer` has no video tracks. On the other hand if there
  /// is too many video tracks `TooManyVideoTracksException` will be thrown.
  Future<Stream<dynamic>> initEyesOpenStream() async {
    if (_localRenderer.srcObject != null) {
      final videoTracks = _localRenderer.srcObject!.getVideoTracks();
      final onlyOneVideo = videoTracks.length == 1;
      if (onlyOneVideo) {
        _eyesOpenStream = await videoTracks.first.startEyesOpenStream();
        return _eyesOpenStream!;
      } else if (videoTracks.length > 1) {
        throw TooManyVideoTracksException(
          message:
              "You can't play the game because there is too many video track",
        );
      } else {
        throw NoVideoTrackException(
          message: "You can't play the game because there is no video track",
        );
      }
    } else {
      throw NoSourceObjectException(
        message:
            'RTCVideoRenderer.srcObjecdt is null. Call initLocalRenderer before calling initEyesOpenStream',
      );
    }
  }

  /// Stops the eyesOpenStream if it was started.
  Future<void> disposeEyesOpenStream() async {
    if (_localRenderer.srcObject != null) {
      final video = _localRenderer.srcObject!.getVideoTracks().first;

      await video.stopEyesOpenStream();
    }
  }
}

class NoSourceObjectException implements Exception {
  final String message;

  NoSourceObjectException({this.message = ''});

  @override
  String toString() => 'NoSourceObjectException: $message';
}

class NoVideoTrackException implements Exception {
  final String message;

  NoVideoTrackException({this.message = ''});

  @override
  String toString() => 'NoVideoTrackException: $message';
}

class TooManyVideoTracksException implements Exception {
  final String message;

  TooManyVideoTracksException({this.message = ''});

  @override
  String toString() => 'TooManyVideoTracksException: $message';
}
