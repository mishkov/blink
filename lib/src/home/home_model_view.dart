import 'package:blink/src/bid/bid_service.dart';
import 'package:blink/src/local_camera/local_camera_service.dart';
import 'package:blink/src/user/user_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class HomeModelView extends Cubit<HomeState> {
  final _videoService = LocalCameraService();
  final BidService _bidService = BidService();

  HomeModelView()
      : super(
          HomeState(
            bidInBlk: BidService().bidInBlk,
            eyesOpenStream: LocalCameraService().eyesOpenStream,
            localVideo: LocalCameraService().video,
          ),
        ) {
    _init();
  }

  set bidInBlk(int? bid) {
    if (bid == null) {
      // TODONOT: create special exception for this case
      //throw Exception('wrong bid format');
      // TODO: create state with error message instead of exception

    }
    bid ??= 0;
    _bidService.bidInBlk = bid;
  }

  int get bidInBlk => _bidService.bidInBlk;

  set bidTimeInSeconds(int? bidTime) {
    if (bidTime == null) {
      // TODONOT: create special exception for this case
      //throw Exception('wrong bid format');
      // TODO: create state with error message instead of exception

    }
    bidTime ??= 0;
    _bidService.bidTimeInSeconds = bidTime;
  }

  int get bidTimeInSeconds => _bidService.bidTimeInSeconds;

  Future<void> _init() async {
    await _videoService.initLocalRenderer();
    await _videoService.initEyesOpenStream();

    emit(HomeState(
      bidInBlk: _bidService.bidInBlk,
      eyesOpenStream: _videoService.eyesOpenStream,
      localVideo: _videoService.video,
    ));

    await UserService().init();
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
  int? bidInBlk;

  HomeState({
    this.bidInBlk,
    this.eyesOpenStream,
    this.localVideo,
    this.errorHappened = false,
    this.errorMessage,
  });
}
