import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:blink/src/eyes_detection/eyes_detector.dart';

class FirebaseEyeDetector with ChangeNotifier implements EyesDetector {
  bool? _isLeftEyeOpen;
  bool? _isRightEyeOpen;

  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    const FaceDetectorOptions(
      enableClassification: true,
    ),
  );
  bool _isBusy = false;
  CameraController? _controller;
  CameraDescription? _camera;

  static final _instance = FirebaseEyeDetector._internal();

  factory FirebaseEyeDetector() => _instance;

  @override
  bool? get isLeftEyeOpen => _isLeftEyeOpen;

  @override
  bool? get isRightEyeOpen => _isRightEyeOpen;

  CameraController? get cameraController => _controller;

  FirebaseEyeDetector._internal() {
    init();
  }

  Future<void> init() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw 'No avaible camera!';
    }
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        _camera = camera;
        break;
      }
    }
    _camera ??= cameras.first;

    _controller = CameraController(
      _camera!,
      ResolutionPreset.low,
      enableAudio: false,
    );
    if (_controller?.value.isInitialized == false) {
      await _controller?.initialize();
      if (!_controller!.value.isStreamingImages) {
        _controller?.startImageStream(_processCameraImage);
      }
    }
  }

  Future<void> destroy() async {
    if (_controller?.value.isInitialized == true) {
      if (_controller?.value.isStreamingImages == true) {
        await _controller?.stopImageStream();
      }
      await _controller?.dispose();
    }
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
    if (_camera == null) {
      return;
    }
    if (_isBusy) return;
    _isBusy = true;

    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = _camera!;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    InputImageRotation imageRotation;
    if (androidInfo.isPhysicalDevice!) {
      imageRotation =
          InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.Rotation_0deg;
    } else {
      if (camera.sensorOrientation == 0) {
        imageRotation = InputImageRotationMethods.fromRawValue(270) ??
            InputImageRotation.Rotation_90deg;
      } else {
        imageRotation = InputImageRotationMethods.fromRawValue(
                camera.sensorOrientation - 90) ??
            InputImageRotation.Rotation_270deg;
      }
    }

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    _processImage(inputImage);
  }

  Future<void> _processImage(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      if (faces.isNotEmpty) {
        if (faces.first.leftEyeOpenProbability != null &&
            faces.first.rightEyeOpenProbability != null) {
          if (faces.first.rightEyeOpenProbability! > 0.6) {
            _isRightEyeOpen = true;
          } else {
            _isRightEyeOpen = false;
          }
          if (faces.first.leftEyeOpenProbability! > 0.6) {
            _isLeftEyeOpen = true;
          } else {
            _isLeftEyeOpen = false;
          }
        } else {
          _isLeftEyeOpen = null;
          _isRightEyeOpen = null;
        }
      } else {
        _isLeftEyeOpen = null;
        _isRightEyeOpen = null;
      }
      notifyListeners();
    }
    _isBusy = false;
  }
}
