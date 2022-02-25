import 'package:flutter_bloc/flutter_bloc.dart';

import '../user/user_service.dart';

class LoginModelView extends Cubit<LoginState> {
  LoginModelView() : super(LoginState.initial());

  Future<void> login() async {
    try {
      emit(LoginState.inProgress());

      await UserService().loginWithGoogle();

      emit(LoginState.success());
    } on SignInAbortedException {
      emit(LoginState.initial());
    } on NoSignedInUserExceptino catch (e) {
      emit(LoginState.error(errorMessage: e.message));
    } catch (e) {
      emit(LoginState.error(errorMessage: 'Unknown error'));
    }
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
