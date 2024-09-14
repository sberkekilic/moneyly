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
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'tr_TR';
  initializeDateFormatting('tr_TR', null).then((_) {
    runApp(
        MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => SettingsCubit(SettingsState())),
              BlocProvider(create: (context) => SelectedIndexCubit(pageController)),
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
    List<String> actualDesiredKeys = ['selected_option', 'incomeMap', 'invoices'];
    return BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
      SystemChrome.setSystemUIOverlayStyle(
        state.darkMode
            ? SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        )
            : SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );

      return FutureBuilder<bool>(
        future: checkIfAllKeysHaveValues(actualDesiredKeys),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final allKeysHaveValues = snapshot.data ?? false;
            final initialRoute = allKeysHaveValues ? 'page6' : 'gelir-ekle';
            return ScreenUtilInit(
              designSize: const Size(360, 640),
              builder: (context, child) => MaterialApp(
                locale: Locale(state.language, ""),
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLanguages
                    .map((lang) => Locale(lang, ''))
                    .toList(),
                initialRoute: initialRoute,
                routes: {
                  'gelir-ekle': (context) => AddIncome(),
                  'abonelikler': (context) => Subscriptions(),
                  'faturalar': (context) => Bills(),
                  'diger-giderler': (context) => OtherExpenses(),
                  'page5': (context) => Page5(),
                  'page6': (context) => Page6(pageController: pageController),
                  'ana-sayfa': (context) => HomePage(),
                  'income-page': (context) => IncomePage(pageController: pageController),
                  'outcome-page': (context) => OutcomePage(),
                  'investment-page': (context) => InvestmentPage(),
                  'wishes-page': (context) => WishesPage(),
                  'settings': (context) => SettingsScreen(),
                },
                debugShowCheckedModeBanner: false,
                title: 'Moneyly',
                themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
                theme: Themes.lightTheme,
                darkTheme: Themes.darkTheme,
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    });
  }

  Future<bool> checkIfAllKeysHaveValues(List<String> desiredKeys) async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in desiredKeys) {
      final value = prefs.get(key);
      if (value == null) {
        return false;
      }
      if (key == 'invoices') {
        try {
          List<dynamic> invoices = json.decode(value.toString());
          if (invoices.length < 3) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }
    }
    return true;
  }
}
