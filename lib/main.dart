
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/settings/settings-cubit.dart';
import 'blocs/settings/settings-state.dart';
import 'localization/localization.dart';
import 'routes/routes.dart';
import 'themes/themes.dart';

Future<String> getInitialLocation() async {
  final prefs = await SharedPreferences.getInstance();
  final actualDesiredKeys = ['selected_option', 'incomeMap', 'invoices'];

  for (var key in actualDesiredKeys) {
    final value = prefs.get(key);

    if (value == null) {
      return '/'; // Default route if key is not present
    }

    // Special handling for the 'invoices' key
    if (key == 'invoices') {
      try {
        List<dynamic> invoices = json.decode(value.toString());
        if (invoices.length < 3) {
          return '/'; // Default route if there are fewer than 3 invoices
        }
      } catch (e) {
        print("Error decoding 'invoices': $e"); // Log the error
        return '/'; // Default route on error
      }
    }
  }

  return '/page6'; // Desired initial location when all conditions are met
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialLocation = await getInitialLocation(); //LOAD DATA AND LOAD CORRECT PAGE
  runApp(MyApp(initialLocation: initialLocation,));
}

class MyApp extends StatelessWidget {
  final String initialLocation;

  const MyApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(SettingsState()),
      child: BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
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
            locale: Locale(state.language, ""),
            themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: Themes.lightTheme,
            darkTheme: Themes.darkTheme,
            routerConfig: createRouter(initialLocation),
          ),
        );
      }),
    );
  }
}
