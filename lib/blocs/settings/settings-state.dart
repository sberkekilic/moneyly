class SettingsState {
  String language;
  bool darkMode;
  bool userLoggedIn;
  List<String> userInfo;

  SettingsState({
    this.language = "tr",
    this.darkMode = false,
    this.userLoggedIn = false,
    this.userInfo = const [],
  });
}