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
        create: (context) => LoginModelView(),
        child: Builder(
          builder: (context) {
            return BlocListener<LoginModelView, LoginState>(
              listenWhen: (previousState, currentState) {
                return currentState.isSuccess;
              },
              listener: (context, state) {
                if (state.isSuccess) {
                  Navigator.popAndPushNamed(context, HomeView.routeName);
                  context.read<LoginModelView>().close();
                }
              },
              child: SizedBox.expand(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<LoginModelView>().login();
                        },
                        child: Text(AppLocalizations.of(context)!
                            .loginWithGoogleButton),
                      ),
                    ),
                    Positioned(
                      child: BlocBuilder<LoginModelView, LoginState>(
                        buildWhen: (previousState, currentState) {
                          return !currentState.isSuccess;
                        },
                        builder: (context, state) {
                          if (state.inProgress) {
                            return Container(
                              color: const Color(0x30000000),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (state.errorHappened) {
                            return Container(
                              color: const Color(0x70000000),
                              child: AlertDialog(
                                title: Text(AppLocalizations.of(context)!
                                    .errorDialogTitle),
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(state.errorMessage),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                        AppLocalizations.of(context)!.tryAgain),
                                    onPressed: () {
                                      // TODO: check behavior. Maybe you have to add navigator.pop here
                                      context.read<LoginModelView>().login();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                        AppLocalizations.of(context)!.okButton),
                                    onPressed: () {
                                      context
                                          .read<LoginModelView>()
                                          .emit(LoginState.initial());
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
