import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../home/home_view.dart';

class SelectModeScreen extends StatelessWidget {
  static const routeName = '/select_mode';

  const SelectModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Refactor widgets
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: const Image(
                                image: AssetImage(
                                  'assets/images/squid_game_player.jpg',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                AppLocalizations.of(context)!.realManMode,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 40),
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement navigation to the battle
                                  // with real man screen
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color.fromARGB(255, 255, 212, 155)),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
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
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: const Image(
                                image: AssetImage(
                                  'assets/images/robot_doll.jpeg',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child:
                                  Text(AppLocalizations.of(context)!.botMode),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 40),
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement navigation to the battle
                                  // with bot screen
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color.fromARGB(255, 206, 73, 69)),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
