import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../user/user_service.dart';

class LoginModelView extends Cubit<LoginState> {
  final AppLocalizations appLocalizations;
  LoginModelView({required this.appLocalizations})
      : super(LoginState.initial());

  Future<void> login() async {
    try {
      emit(LoginState.inProgress());

      await UserService().loginWithGoogle();

      emit(LoginState.success());
    } on SignInAbortedException {
      emit(LoginState.initial());
    } on NoSignedInUserExceptino {
      emit(
        LoginState.error(errorMessage: appLocalizations.noSignedInUserError),
      );
    } on InvaliCredentialException {
      emit(
        LoginState.error(errorMessage: appLocalizations.invalidCredentialError),
      );
    } catch (e) {
      emit(LoginState.error(errorMessage: appLocalizations.unknownError));
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
