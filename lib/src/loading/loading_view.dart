import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  static const routeName = '/loading';

  final String message;

  const LoadingScreen({
    Key? key,
    this.message = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Padding(
                padding: EdgeInsets.all(30.0),
                child: Center(
                    child: Text(
                  "Logo",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                )),
              ),
            ),
            message.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(message),
                  ),
          ],
        ),
      ),
    );
  }
}
