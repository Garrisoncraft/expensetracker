import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/auth.dart';
import 'provider/transaction.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/dashboard.dart';
import 'screens/transaction.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';




void main() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    sqfliteFfiInit();
  } else {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Builder(
        key: const ValueKey('main_builder'),
        builder: (context) {
          return Consumer<AuthProvider>(
            key: const ValueKey('auth_consumer'),
            builder: (context, auth, child) {
              return auth.isAuthenticated
                  ? DashboardScreen(key: const ValueKey('dashboard'))
                  : LoginScreen(key: const ValueKey('login'));
            },
          );
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/transaction': (context) => const TransactionScreen(),
      },

    );
  }
}
