import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyly/blocs/settings/selected-index-cubit.dart';
import 'package:moneyly/blocs/settings/settings-page.dart';
import 'package:moneyly/pages/add-expense/abonelikler.dart';
import 'package:moneyly/pages/add-expense/diger-giderler.dart';
import 'package:moneyly/pages/add-expense/faturalar.dart';
import 'package:moneyly/pages/add-expense/gelir-ekle.dart';
import 'package:moneyly/pages/in-app/home-page.dart';
import 'package:moneyly/pages/in-app/income-page.dart';
import 'package:moneyly/pages/in-app/investment-page.dart';
import 'package:moneyly/pages/in-app/outcome-page.dart';
import 'package:moneyly/pages/page6.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/form-bloc.dart';
import '../blocs/income-selections.dart';

GoRouter createRouter(String initialLocation) {
  return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider<IncomeSelectionsBloc>(
              create: (_) => IncomeSelectionsBloc(),
              child: AddIncome(),
            )
        ),
        GoRoute(
            path: '/subs',
            builder: (context, state) => BlocProvider<FormBloc>(
              create: (_) => FormBloc(),
              child: Subscriptions(),
            )
        ),
        GoRoute(
            path: '/bills',
            builder: (context, state) => BlocProvider<FormBloc>(
              create: (_) => FormBloc(),
              child: Bills(),
            )
        ),
        GoRoute(
            path: '/other',
            builder: (context, state) => BlocProvider<FormBloc>(
              create: (_) => FormBloc(),
              child: OtherExpenses(),
            )
        ),
        GoRoute(
            path: '/page6',
            builder: (context, state) => BlocProvider(
              create: (context) => SelectedIndexCubit(),
              child: Page6(),
            )
        ),
        GoRoute(
            path: '/home',
            builder: (context, state) => HomePage()
        ),
        GoRoute(
            path: '/income',
            builder: (context, state) => IncomePage()
        ),
        GoRoute(
            path: '/outcome',
            builder: (context, state) => OutcomePage()
        ),
        GoRoute(
            path: '/investment',
            builder: (context, state) => InvestmentPage()
        ),
        GoRoute(
            path: '/settings',
            builder: (context, state) => SettingsScreen()
        ),
      ]
  );
}