import 'package:flutter/material.dart';
import 'package:moneyly/form-data-provider.dart';
import 'package:moneyly/pages/abonelikler.dart';
import 'package:moneyly/pages/diger-giderler.dart';
import 'package:moneyly/pages/faturalar.dart';
import 'package:moneyly/pages/gelir-ekle.dart';
import 'package:moneyly/pages/page5.dart';
import 'package:provider/provider.dart';

import 'pages/selection.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => IncomeSelections()),
          ChangeNotifierProvider(create: (context) => FormDataProvider()),
        ],
        child: MyApp()
    )
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        'gelir-ekle': (context) => AddIncome(),
        'abonelikler': (context) => Subscriptions(),
        'faturalar': (context) => Bills(),
        'diger-giderler': (context) => OtherExpenses(),
        'page5': (context) => Page5()
      },
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xfff0f0f1),
      ),
    );
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
