import 'package:flutter_bloc/flutter_bloc.dart';

import '../user/user_bloc.dart';

class LoginModelView extends Cubit<LoginState> {
  final UserBloc userBloc;

  LoginModelView({required this.userBloc}) : super(LoginState.initial());

  Future<void> login() async {
    final subscription = userBloc.stream.listen((event) {
      if (event is UserInLogin) {
        final loggining = event;
        if (loggining.inProgress) {
          emit(LoginState.inProgress());
        }
      } else if (event is ErrorUserState) {
        final error = event;
        emit(LoginState.error(errorMessage: error.message));
      } else if (event is ReadyUserState) {
        emit(LoginState.success());
      }
    });
    await userBloc.loginWithGoogle();
    subscription.cancel();
  }
}

class LoginState {
  final bool inProgress;
  final bool errorHappened;
  final String errorMessage;
  final bool isSuccess;

  LoginState({
    required this.inProgress,
    required this.errorHappened,
    required this.errorMessage,
    required this.isSuccess,
  });

  LoginState.initial()
      : inProgress = false,
        errorHappened = false,
        errorMessage = '',
        isSuccess = false;

  LoginState.inProgress()
      : inProgress = true,
        errorHappened = false,
        errorMessage = '',
        isSuccess = false;

  LoginState.error({required this.errorMessage})
      : inProgress = false,
        errorHappened = true,
        isSuccess = false;

  LoginState.success()
      : inProgress = false,
        errorHappened = false,
        errorMessage = '',
        isSuccess = true;
}
