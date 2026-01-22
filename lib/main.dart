import 'package:flutter/material.dart';
import 'package:online_traffic_offense_management_system/screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Traffic Offense Management System',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: AppBarThemeData(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,

        )

      ),
     home: const SplashScreen(),

    routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
