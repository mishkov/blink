import 'package:blink/src/device_info/device_info_bloc.dart';
import 'package:blink/src/home/signaling.dart';
import 'package:blink/src/lobby/lobby.dart';
import 'package:blink/src/select_mode/select_mode_screen.dart';
import 'package:blink/src/win/win_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:blink/src/home/home_view.dart';
import 'package:blink/src/login/login_view.dart';

import 'lose/lose_screen.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class BlinkApp extends StatelessWidget {
  const BlinkApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return BlocProvider<DeviceInfoBloc>(
      create: (_) => DeviceInfoBloc(),
      child: AnimatedBuilder(
        animation: settingsController,
        builder: (BuildContext context, Widget? child) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          return MaterialApp(
            // Providing a restorationScopeId allows the Navigator built by the
            // MaterialApp to restore the navigation stack when a user leaves and
            // returns to the app after it has been killed while running in the
            // background.
            restorationScopeId: 'app',

            // Provide the generated AppLocalizations to the MaterialApp. This
            // allows descendant Widgets to display the correct translations
            // depending on the user's locale.
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English, no country code
              Locale('ru', ''),
            ],

            // Use AppLocalizations to configure the correct application title
            // depending on the user's locale.
            //
            // The appTitle is defined in .arb files found in the localization
            // directory.
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,

            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,

            // Define a function to handle named routes in order to support
            // Flutter web url navigation and deep linking.
            onGenerateRoute: (RouteSettings routeSettings) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  return Builder(
                    builder: (_) {
                      final args =
                          routeSettings.arguments as Map<String, dynamic>?;
                      switch (routeSettings.name) {
                        case SettingsView.routeName:
                          return SettingsView(controller: settingsController);
                        case LoginView.routeName:
                          return const LoginView();
                        case SelectModeScreen.routeName:
                          return const SelectModeScreen();
                        case Lobby.routeName:
                          return const Lobby();
                        case LoseScreen.routeName:
                          final signaling = args!['signaling'];
                          return LoseScreen(
                            signaling: signaling,
                          );
                        case WinScreen.routeName:
                          return WinScreen(
                            signaling: (routeSettings.arguments
                                as Map)['signaling'] as Signaling,
                          );
                        case HomeView.routeName:
                        default:
                          if (FirebaseAuth.instance.currentUser == null) {
                            return const LoginView();
                          } else {
                            return const HomeView();
                          }
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
