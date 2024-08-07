import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/blocs/settings/settings-cubit.dart';
import 'package:moneyly/blocs/settings/settings-state.dart';
import 'package:moneyly/form-data-provider.dart';
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

import 'deneme.dart';
import 'pages/selection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // // Initialize the Turkish locale data
  Intl.defaultLocale = 'tr_TR';
  initializeDateFormatting('tr_TR', null).then((_) {
    runApp(
        MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => IncomeSelections()),
              ChangeNotifierProvider(create: (context) => FormDataProvider()),
              ChangeNotifierProvider(create: (context) => FormDataProvider2()),
            ],
            child: MyApp()
        )
    );
  });
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> actualDesiredKeys = [
      'selected_option', 'incomeMap', 'invoices'
    ];
    return BlocProvider(
      create: (context) => SettingsCubit(SettingsState()),
      child: BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
        return FutureBuilder<bool>(
          future: checkIfAllKeysHaveValues(actualDesiredKeys),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final allKeysHaveValues = snapshot.data ?? false;
              final initialRoute = allKeysHaveValues ? 'ana-sayfa' : '/';
              return ScreenUtilInit(
                designSize: const Size(360, 640),
                builder: (context, child) => MaterialApp(
                  initialRoute: initialRoute,
                  routes: {
                    '/': (context) => MyHomePage(),
                    'gelir-ekle': (context) => AddIncome(),
                    'abonelikler': (context) => Subscriptions(),
                    'faturalar': (context) => Bills(),
                    'diger-giderler': (context) => OtherExpenses(),
                    'page5': (context) => Page5(),
                    'ana-sayfa': (context) => HomePage(),
                    'income-page': (context) => IncomePage(),
                    'outcome-page': (context) => OutcomePage(),
                    'investment-page': (context) => InvestmentPage(),
                    'wishes-page': (context) => WishesPage()
                  },
                  debugShowCheckedModeBanner: false,
                  title: 'Flutter Demo',
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    scaffoldBackgroundColor: Color(0xfff0f0f1),
                  ),
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
