import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const SettingsPage({Key? key, required this.onThemeToggle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text("Dark Theme"),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (_) => onThemeToggle(),
          ),
        ],
      ),
    );
  }
}