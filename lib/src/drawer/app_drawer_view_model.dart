import 'package:blink/src/user/user.dart';
import 'package:blink/src/user/user_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppDrawerViewModel extends Cubit<AppDrawerState> {
  AppDrawerViewModel()
      : super(AppDrawerState(user: UserService().user ?? User())) {
    _registerListener();
  }

  void _registerListener() {
    UserService().userStream.listen((user) {
      emit(AppDrawerState(user: user));
    });
  }
}

class AppDrawerState {
  final User user;

  AppDrawerState({required this.user});
}
