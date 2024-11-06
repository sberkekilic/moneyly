
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(SettingsState()),
      child: FutureBuilder<String>(
        future: getInitialLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // You can return a loading screen here if needed
            return const Center(child: CircularProgressIndicator());
          }
          final initialLocation = snapshot.data ?? '/';  // Default to '/' if null

          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
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
            },
          );
        },
      ),
    );
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
        return '/';  // Default route if any key is missing
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

}


