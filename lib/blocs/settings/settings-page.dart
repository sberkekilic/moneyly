import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyly/blocs/settings/settings-cubit.dart';

class SettingsScreen extends StatefulWidget{
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{
  late final SettingsCubit settings;

  @override
  void initState() {
    settings = context.read<SettingsCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: settings.state.darkMode,
            onChanged: (value) {
              print('Before changing theme: ${Navigator.of(context).canPop()}');
              settings.changeDarkMode(value);
              print('After changing theme: ${Navigator.of(context).canPop()}');
            },
          ),
          SizedBox(height: 20),
          Text('Language', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          DropdownButton<String>(
            value: settings.state.language,
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
                if (newLanguage!=null){
                  settings.changeLanguage(newLanguage);
                }
              },
          )
        ],
      ),
    );
  }
}
