import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'pages/gelir-ekle.dart';
import 'pages/selection.dart';
import 'routes/routes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => IncomeSelections(),
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(
            0xfff0f0f1),
      ),
      routerConfig: routes,
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
                  GoRouter.of(context).replace("/gelir-ekle");
                },
                child: Text("İlerle")
            )
          ],
        ),
      ),
    );
  }
}
