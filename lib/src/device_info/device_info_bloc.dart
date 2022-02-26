import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceInfoBloc extends Cubit<DeviceInfo> {
  DeviceInfoBloc() : super(DeviceInfo()) {
    _init();
  }

  Future<void> _init() async {
    DeviceInfoPlugin deviceInfoService = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoService.androidInfo;
    final isEmulator = !deviceInfo.isPhysicalDevice!;
    emit(state.copyWith(isEmulator: isEmulator));
  }
}

class DeviceInfo {
  final bool? isEmulator;

  DeviceInfo({this.isEmulator});

  DeviceInfo copyWith({bool? isEmulator}) {
    return DeviceInfo(isEmulator: isEmulator ?? this.isEmulator);
  }
}
