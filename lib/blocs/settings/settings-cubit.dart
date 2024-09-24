import 'package:bloc/bloc.dart';

import '../../storage/storage.dart';
import 'settings-state.dart';

class SettingsCubit extends Cubit<SettingsState>{
  SettingsCubit(super.initialState);

  changeLanguage(String lang) async {
    final newState = SettingsState(
      language: lang,
      darkMode: state.darkMode,
      userInfo: state.userInfo,
      userLoggedIn: state.userLoggedIn,
    );

    emit(newState);

    final storage = AppStorage();

    await storage.writeAppSettings(
        language: lang,
        darkMode: state.darkMode
    );
  }

  changeDarkMode(bool darkMode) async {
    final newState = SettingsState(
      language: state.language,
      darkMode: darkMode,
      userInfo: state.userInfo,
      userLoggedIn: state.userLoggedIn,
    );

    emit(newState);

    final storage = AppStorage();

    await storage.writeAppSettings(
        language: state.language,
        darkMode: darkMode
    );
  }

  userLogin(List<String> userInfo) async {
    final newState = SettingsState(
      language: state.language,
      darkMode: state.darkMode,
      userInfo: userInfo,
      userLoggedIn: true,
    );

    emit(newState);

    final storage = AppStorage();

    await storage.writeUserData(
        userInfo: userInfo,
        isLoggedIn: true
    );
  }
  userLogout() async {
    final newState = SettingsState(
      language: state.language,
      darkMode: state.darkMode,
      userInfo: [],
      userLoggedIn: false,
    );

    emit(newState);

    // write userInfo to storage

    final storage = AppStorage();

    await storage.writeUserData(isLoggedIn: false, userInfo: []);
  }

  userUpdate(List<String> userInfo) async {
    final newState = SettingsState(
      language: state.language,
      darkMode: state.darkMode,
      userInfo: userInfo,
      userLoggedIn: true,
    );

    emit(newState);

    // write userInfo to storage

    final storage = AppStorage();

    await storage.writeUserData(isLoggedIn: true, userInfo: userInfo);
  }
}