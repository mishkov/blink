import 'dart:async';

import 'package:blink/src/user/user.dart';
import 'package:blink/src/user/user_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppDrawerViewModel extends Cubit<AppDrawerState> {
  StreamSubscription? _userStreamSubscription;

  AppDrawerViewModel()
      : super(AppDrawerState(
          name: UserService().user?.name ?? '',
          photoUrl: UserService().user?.photoUrl ?? '',
          email: UserService().user?.email ?? '',
          highestTime: _timeFromMilliseconds(UserService().user?.highestTime),
          balance: (UserService().user?.balance ?? '').toString(),
          wins: (UserService().user?.wins ?? '').toString(),
          defeats: (UserService().user?.defeats ?? '').toString(),
        )) {
    _registerListener();
  }

  void _registerListener() {
    _userStreamSubscription = UserService().userStream.listen((user) {
      final state = AppDrawerState(
        name: user.name ?? '',
        photoUrl: user.photoUrl ?? '',
        email: user.email ?? '',
        highestTime: _timeFromMilliseconds(user.highestTime),
        balance: (user.balance ?? '').toString(),
        wins: (user.wins ?? '').toString(),
        defeats: (user.defeats ?? '').toString(),
      );
      emit(state);
    });
  }

  @override
  Future<void> close() async {
    await _userStreamSubscription?.cancel();
    return super.close();
  }

  static String _timeFromMilliseconds(int? timeInMilliseconds) {
    final time = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds ?? 0);
    final minutes = time.minute;
    final seconds = time.second;
    final milliseconds = time.millisecond ~/ 100;

    return '$minutes:$seconds:$milliseconds';
  }
}

class AppDrawerState {
  final String name;
  final String photoUrl;
  final String email;
  final String highestTime;
  final String balance;
  final String wins;
  final String defeats;

  AppDrawerState({
    required this.name,
    required this.photoUrl,
    required this.email,
    required this.highestTime,
    required this.balance,
    required this.wins,
    required this.defeats,
  });
}
