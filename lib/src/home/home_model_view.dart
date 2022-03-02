import 'package:blink/src/local_camera/local_camera_service.dart';
import 'package:blink/src/user/user_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class HomeModelView extends Cubit<HomeState> {
  final _videoService = LocalCameraService();
  int _bidInDollars = 1;

  HomeModelView()
      : super(
          HomeState(
            bidInDollars: 1,
            eyesOpenStream: LocalCameraService().eyesOpenStream,
            localVideo: LocalCameraService().video,
          ),
        ) {
    _init();
  }

  set bidInDollars(int? bid) {
    if (bid == null) {
      // TODO: create special exception for this case
      throw Exception('wrong bid format');
    }
    if (bid.isNegative) {
      // TODO: create special exception for this case
      throw Exception('bid can not be negative');
    }
    _bidInDollars = bid;
  }

  int get bidInDollars => _bidInDollars;

  Future<void> _init() async {
    await _videoService.initLocalRenderer();
    await _videoService.initEyesOpenStream();

    emit(HomeState(
      bidInDollars: _bidInDollars,
      eyesOpenStream: _videoService.eyesOpenStream,
      localVideo: _videoService.video,
    ));

    await UserService().initUserFields();
  }

  @override
  Future<void> close() async {
    await _videoService.disposeLocalRenderer();
    super.close();
  }
}

class HomeState {
  Stream<dynamic>? eyesOpenStream;
  RTCVideoRenderer? localVideo;
  bool errorHappened;
  String? errorMessage;
  int? bidInDollars;

  HomeState({
    this.bidInDollars,
    this.eyesOpenStream,
    this.localVideo,
    this.errorHappened = false,
    this.errorMessage,
  });
}
