import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/blocs/settings/selected-index-cubit.dart';
import 'package:moneyly/blocs/settings/settings-cubit.dart';
import 'package:moneyly/blocs/settings/settings-page.dart';
import 'package:moneyly/blocs/settings/settings-state.dart';
import 'package:moneyly/form-data-provider.dart';
import 'package:moneyly/localization.dart';
import 'package:moneyly/pages/abonelikler.dart';
import 'package:moneyly/pages/diger-giderler.dart';
import 'package:moneyly/pages/faturalar.dart';
import 'package:moneyly/pages/gelir-ekle.dart';
import 'package:moneyly/pages/home-page.dart';
import 'package:moneyly/pages/income-page.dart';
import 'package:moneyly/pages/investment-page.dart';
import 'package:moneyly/pages/outcome-page.dart';
import 'package:moneyly/pages/page5.dart';
import 'package:moneyly/pages/wishes-page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'deneme.dart';
import 'pages/page6.dart';
import 'pages/selection.dart';
import 'themes/themes.dart';

void main() {
  final PageController pageController = PageController();
  final SelectedIndexCubit _selectedIndexCubit = SelectedIndexCubit(pageController);
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'tr_TR';
  initializeDateFormatting('tr_TR', null).then((_) {
    runApp(
        MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => SettingsCubit(SettingsState()),
              ),
              BlocProvider(
                create: (context) => _selectedIndexCubit,
              ),
              ChangeNotifierProvider(create: (context) => IncomeSelections()),
              ChangeNotifierProvider(create: (context) => FormDataProvider()),
              ChangeNotifierProvider(create: (context) => FormDataProvider2()),
            ],
            child: MyApp(pageController: pageController)
        )
    );
  });
}

class MyApp extends StatelessWidget {
  final PageController pageController;
  MyApp({required this.pageController});

  @override
  Widget build(BuildContext context) {
    List<String> actualDesiredKeys = [
      'selected_option', 'incomeMap', 'invoices'
    ];
    return BlocProvider(
      create: (context) => SettingsCubit(SettingsState()),
      child: BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
        SystemChrome.setSystemUIOverlayStyle(
          state.darkMode
              ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark
          )
          : SystemUiOverlayStyle.dark.copyWith(
           statusBarColor: Colors.transparent,
           statusBarIconBrightness: Brightness.dark,
           statusBarBrightness: Brightness.light
        )
        );
        return FutureBuilder<bool>(
          future: checkIfAllKeysHaveValues(actualDesiredKeys),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final allKeysHaveValues = snapshot.data ?? false;
              final initialRoute = allKeysHaveValues ? 'page6' : '/';
              return ScreenUtilInit(
                designSize: const Size(360, 640),
                builder: (context, child) => MaterialApp(
                  locale: Locale(state.language, ""),
                  localizationsDelegates: [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate
                  ],
                  supportedLocales: AppLocalizations.supportedLanguages
                  .map((lang) => Locale(lang, ''))
                  .toList(),
                  initialRoute: initialRoute,
                  routes: {
                    '/': (context) => MyHomePage(),
                    'gelir-ekle': (context) => AddIncome(),
                    'abonelikler': (context) => Subscriptions(),
                    'faturalar': (context) => Bills(),
                    'diger-giderler': (context) => OtherExpenses(),
                    'page5': (context) => Page5(),
                    'page6': (context) => Page6(pageController: pageController,),
                    'ana-sayfa': (context) => HomePage(),
                    'income-page': (context) => IncomePage(pageController: pageController,),
                    'outcome-page': (context) => OutcomePage(),
                    'investment-page': (context) => InvestmentPage(),
                    'wishes-page': (context) => WishesPage(),
                    'settings' : (context) => SettingsScreen()
                  },
                  debugShowCheckedModeBanner: false,
                  title: 'Moneyly',
                  themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
                  theme: Themes.lightTheme,
                  darkTheme: Themes.darkTheme,
                ),
              );
            } else {
              // You can show a loading indicator here if needed.
              return CircularProgressIndicator();
            }
          },
        );
      }),
    );
  }

  Future<bool> checkIfAllKeysHaveValues(List<String> desiredKeys) async {
    final prefs = await SharedPreferences.getInstance();

    for (var key in desiredKeys) {
      final value = prefs.get(key);

      if (value == null) {
        return false; // If any key is empty, return false
      }

      if (key == 'invoices') {
        // Check if 'invoices' has at least 3 instances
        try {
          List<dynamic> invoices = json.decode(value.toString());
          if (invoices.length < 3) {
            return false; // If 'invoices' has less than 3 instances, return false
          }
        } catch (e) {
          return false; // If there's an error decoding 'invoices', return false
        }
      }
    }

    return true; // All keys have values
  }

}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hoş Geldiniz!',
              style: TextStyle(fontSize: 32),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'gelir-ekle');
                },
                child: Text("İlerle")
            )
          ],
        ),
      ),
    );
  }
}
