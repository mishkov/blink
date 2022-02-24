import 'package:blink/src/user/user_bloc.dart';
import 'package:blink/src/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'login_bloc.dart';

class LoginView extends StatelessWidget {
  static const routeName = '/login';

  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginModelView(userBloc: context.read<UserBloc>()),
        child: Builder(
          builder: (context) {
            return BlocListener<LoginModelView, LoginState>(
              listener: (context, state) {
                if (state.inProgress) {
                  showProgressIndicator(context);
                } else if (state.errorHappened) {
                  showErrorMessage(context, state.errorMessage);
                } else if (state.isSuccess) {
                  Navigator.popAndPushNamed(context, HomeView.routeName);
                  context.read<LoginModelView>().close();
                }
              },
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<UserBloc>().loginWithGoogle();
                  },
                  child: const Text('Login with Google'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> showProgressIndicator(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.loginDialogTitle),
          content: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                Text(AppLocalizations.of(context)!.loginDialogMessage),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showErrorMessage(BuildContext context, String message) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.errorDialogTitle),
          content: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
                Text(message),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.tryAgain),
              onPressed: () {
                // TODO: check behavior. Maybe you have to add navigator.pop here
                context.read<LoginModelView>().login();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.okButton),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
