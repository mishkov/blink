import 'package:blink/src/user/user_bloc.dart';
import 'package:blink/src/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatelessWidget {
  static const routeName = '/login';

  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          Navigator.popAndPushNamed(context, HomeView.routeName);
        },
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              context.read<UserBloc>().loginWithGoogle();
            },
            child: const Text('Login with Google'),
          ),
        ),
      ),
    );
  }
}
