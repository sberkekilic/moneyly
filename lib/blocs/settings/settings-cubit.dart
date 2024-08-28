import 'package:bloc/bloc.dart';
import 'package:moneyly/blocs/settings/settings-state.dart';
import 'package:moneyly/storage.dart';

class SettingsCubit extends Cubit<SettingsState>{

  SettingsCubit(super.initialState);

  changeLanguage(String lang) async {
    final newState = SettingsState(
      darkMode: state.darkMode,
      language: lang
    );

    emit(newState);

    final storage = AppStorage();
    await storage.writeAppSettings(language: lang, darkMode: state.darkMode);
  }

  changeDarkMode(bool darkMode) async {
    final newState = SettingsState(
      language: state.language,
      darkMode: darkMode
    );

    emit(newState);

    final storage = AppStorage();
    await storage.writeAppSettings(language: state.language, darkMode: darkMode);
  }

}