import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  Future<Map<String, dynamic>> readAll() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();

    var language = storage.getString('language');
    var darkMode = storage.getBool('darkMode');

    return {
      "language": language,
      "darkMode": darkMode,
    };
  }

  readAppSettings() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();

    var language = storage.getString('language');
    var darkMode = storage.getBool('darkMode');

    return {
      "language": language,
      "darkMode": darkMode,
    };
  }

  writeAppSettings({required String language, required bool darkMode}) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    storage.setString('language', language);
    storage.setBool('darkMode', darkMode);
  }


  readBalances() async {}
  writeBalances() async{}
}