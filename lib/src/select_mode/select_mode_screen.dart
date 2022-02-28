import 'package:blink/src/battle_with_bot/battle_with_bot_screen.dart';
import 'package:blink/src/lobby/lobby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectModeScreen extends StatelessWidget {
  static const routeName = '/select_mode';

  const SelectModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Mode(
                      imagePath: 'assets/images/squid_game_player.jpg',
                      desctiption: AppLocalizations.of(context)!.realManMode,
                      buttonColor: const Color.fromARGB(255, 255, 212, 155),
                      onPressed: () {
                        Navigator.popAndPushNamed(context, Lobby.routeName);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Mode(
                      imagePath: 'assets/images/robot_doll.jpeg',
                      desctiption: AppLocalizations.of(context)!.botMode,
                      buttonColor: const Color.fromARGB(255, 206, 73, 69),
                      onPressed: () {
                        Navigator.popAndPushNamed(
                            context, BattleWithBotScreen.routeName);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const HomeButton(),
          ],
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  const HomeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9.0),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 24,
          ),
          child: Text(
            AppLocalizations.of(context)!.homeButton,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class Mode extends StatelessWidget {
  final String imagePath;
  final String desctiption;
  final Color buttonColor;
  final void Function()? onPressed;

  const Mode({
    required this.imagePath,
    Key? key,
    required this.desctiption,
    required this.buttonColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image(
            image: AssetImage(
              imagePath,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            desctiption,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(buttonColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 24,
              ),
              child: Text(
                AppLocalizations.of(context)!.playButton,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
