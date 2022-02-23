import 'package:blink/src/user/user_bloc.dart';
import 'package:blink/src/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_bloc.dart';

class LoginView extends StatelessWidget {
  static const routeName = '/login';

  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
        return Center(
          child: ElevatedButton(
            onPressed: () {
              context.read<UserBloc>().loginWithGoogle();
            },
            child: const Text('Login with Google'),
          ),
        );
      }
          // listener: (context, state) {
          //   if (state is UserInLogin && state.inProgress) {
          //     showDialog<void>(
          //       context: context,
          //       barrierDismissible: false,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: const Text('Login'),
          //           content: Center(
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: const [
          //                 CircularProgressIndicator(),
          //                 Text('Please wait for login...'),
          //               ],
          //             ),
          //           ),
          //         );
          //       },
          //     );
          //   } else if (state is ErrorUserState) {
          //     showDialog<void>(
          //       context: context,
          //       barrierDismissible: true,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: const Text('Error'),
          //           content: Center(
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 const Icon(
          //                   Icons.error_outline,
          //                   color: Colors.red,
          //                 ),
          //                 Text(state.message),
          //               ],
          //             ),
          //           ),
          //           actions: [
          //             TextButton(
          //               child: const Text('Try again'),
          //               onPressed: () {
          //                 Navigator.of(context).pop();
          //                 context.read<UserBloc>().loginWithGoogle();
          //               },
          //             ),
          //             TextButton(
          //               child: const Text('OK'),
          //               onPressed: () {
          //                 Navigator.of(context).pop();
          //               },
          //             ),
          //           ],
          //         );
          //       },
          //     );
          //   } else if (state is ReadyUserState) {
          //     Navigator.popAndPushNamed(context, HomeView.routeName);
          //   } else {
          //     showDialog<void>(
          //       context: context,
          //       barrierDismissible: false,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: const Text('Error'),
          //           content: Center(
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: const [
          //                 Icon(
          //                   Icons.error_outline,
          //                   color: Colors.red,
          //                 ),
          //                 Text('Unkkown error happend'),
          //               ],
          //             ),
          //           ),
          //           actions: [
          //             TextButton(
          //               child: const Text('OK'),
          //               onPressed: () {
          //                 Navigator.of(context).pop();
          //               },
          //             ),
          //           ],
          //         );
          //       },
          //     );
          //   }
          // },
          ),
    );
  }
}
