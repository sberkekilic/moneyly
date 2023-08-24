import 'package:go_router/go_router.dart';
import 'package:untitled/main.dart';
import 'package:untitled/pages/abonelikler.dart';
import 'package:untitled/pages/diger-giderler.dart';
import 'package:untitled/pages/faturalar.dart';
import 'package:untitled/pages/gelir-ekle.dart';

final routes = GoRouter(
  initialLocation: '/',
    routes: [
      GoRoute(
          path: '/',
        builder: (context, state) => MyHomePage(),
      ),
      GoRoute(
        path: '/gelir-ekle',
        builder: (context, state) => AddIncome(),
      ),
      GoRoute(
        path: '/abonelikler',
        builder: (context, state) => Subscriptions(),
      ),
      GoRoute(
        path: '/faturalar',
        builder: (context, state) => Bills(),
      ),
      GoRoute(
        path: '/diger-giderler',
        builder: (context, state) => OtherExpenses(),
      )
    ]
);