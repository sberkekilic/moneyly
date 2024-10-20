import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyly/blocs/settings/settings-cubit.dart';

import 'settings-state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return SwitchListTile(
                title: Text('Dark Mode'),
                value: state.darkMode,
                activeColor: Theme.of(context).primaryColor, // Primary color for the active state
                inactiveThumbColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey,
                inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                onChanged: (value) {
                  // Update the dark mode state in the cubit
                  context.read<SettingsCubit>().changeDarkMode(value);
                },
              );
            },
          ),
          SizedBox(height: 20),
          Text('Language', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return DropdownButton<String>(
                value: state.language,
                items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'tr',
                    child: Text('Turkish'),
                  ),
                ],
                onChanged: (String? newLanguage) {
                  if (newLanguage != null) {
                    context.read<SettingsCubit>().changeLanguage(newLanguage);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
