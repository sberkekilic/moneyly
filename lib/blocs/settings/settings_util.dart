import 'package:shared_preferences/shared_preferences.dart';

Future<int?> retrieveSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('savedThemeModeIndex') ?? 1; // Default to Light
}

Future<void> saveThemeMode(int themeModeIndex) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('savedThemeModeIndex', themeModeIndex);
}
