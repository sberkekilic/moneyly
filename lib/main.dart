
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyly/blocs/settings/settings_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization/localization.dart';
import 'routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  int? retrieveSavedThemeModeIndex = await retrieveSavedThemeMode();
  ThemeMode savedThemeMode = (retrieveSavedThemeModeIndex == 1) ? ThemeMode.light : ThemeMode.dark;

  String initialLocation = await getInitialLocation();
  runApp(
      MyApp(
          savedThemeMode : savedThemeMode,
          initialLocation: initialLocation
      )
  );
}

class MyApp extends StatefulWidget {
  final ThemeMode savedThemeMode;
  final String initialLocation;

  const MyApp({Key? key, required this.savedThemeMode, required this.initialLocation}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ValueNotifier<ThemeMode> _themeNotifier;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ValueNotifier(widget.savedThemeMode);
    _router = createRouter(widget.initialLocation, _toggleTheme);
  }

  void _toggleTheme() async {
    final newThemeMode = _themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _themeNotifier.value = newThemeMode;
    print('Theme toggled to: ${newThemeMode == ThemeMode.light ? "Light" : "Dark"}');
    await saveThemeMode(newThemeMode == ThemeMode.light ? 1 : 2);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, _) {
        return ScreenUtilInit(
          designSize: const Size(360, 780),
          child: MaterialApp.router(
            title: 'Isar Starter Project',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLanguages
                .map((e) => Locale(e, ""))
                .toList(),
            theme: ThemeData.light(),
            themeMode: themeMode,
            darkTheme: ThemeData.dark(),
            routerConfig: _router,
          ),
        );
      },
    );
  }
}

Future<String> getInitialLocation() async {
  final prefs = await SharedPreferences.getInstance();
  final actualDesiredKeys = ['selected_option', 'incomeMap', 'invoices'];

  // Log the keys and values
  print('Checking initial location:');

  for (var key in actualDesiredKeys) {
    final value = prefs.get(key);
    print('$key: $value');  // Print each key and its value

    if (value == null) {
      print("Key $key not found. Navigating to '/'");
      return '/page6';  // Default route if any key is missing
    }

    // Special handling for the 'invoices' key
    if (key == 'invoices') {
      try {
        List<dynamic> invoices = json.decode(value.toString());
        print("Decoded invoices: $invoices");

        if (invoices.length < 3) {
          print("Fewer than 3 invoices found. Navigating to '/'");
          return '/';  // Default route if there are fewer than 3 invoices
        }
      } catch (e) {
        print("Error decoding 'invoices': $e");
        return '/';  // Default route on error
      }
    }
  }

  print("All keys found. Navigating to '/page6'");
  return '/page6';  // Desired initial location when all conditions are met
}