import 'package:blink/src/drawer/app_drawer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../login/login_view.dart';
import '../settings/settings_view.dart';
import '../user/user.dart';
import '../user/user_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocProvider<AppDrawerViewModel>(
        create: (_) => AppDrawerViewModel(),
        child: const DrawerContent(),
      ),
    );
  }
}

class DrawerContent extends StatelessWidget {
  const DrawerContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppDrawerViewModel, AppDrawerState>(
        builder: (context, state) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80.0, left: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: state.photoUrl.isNotEmpty
                      ? NetworkImage(state.photoUrl)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.name),
                      Text(state.email),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(AppLocalizations.of(context)!.highestTimeTitle),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
            child: Text(state.highestTime),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(AppLocalizations.of(context)!.balanceTitle),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
            child: Text(state.balance),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(AppLocalizations.of(context)!.numberOfEarned),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
            child: Text(state.wins),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(AppLocalizations.of(context)!.numberOfSpent),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
            child: Text(state.defeats),
          ),
          const Divider(),
          TextButton(
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
            ),
            onPressed: () {
              Navigator.pushNamed(context, SettingsView.routeName);
            },
            child: Text(
              AppLocalizations.of(context)!.settingsTitle,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
            ),
            onPressed: () {
              UserService().logout();
              Navigator.restorablePushNamed(context, LoginView.routeName);
            },
            child: Text(
              AppLocalizations.of(context)!.logoutButton,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    });
  }
}
