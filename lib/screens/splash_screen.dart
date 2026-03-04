import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'offices/officer_dashboard.dart';
import 'admin/admin_dashboard.dart';
import 'drivers/driver_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      checkLogin();
    });
  }

  Future<void> checkLogin() async {
    final loggedIn = await AuthService.isLoggedIn();
    final user = await AuthService.getUser();

    if (!mounted) return;

    if (loggedIn &&
        user['name'] != null &&
        user['email'] != null &&
        user['role'] != null) {
      final role = user['role'];

      Widget nextScreen;

      if (role == 'admin') {
        nextScreen = AdminDashboardScreen(
          userName: user['name']!,
          email: user['email']!,
          role: user['role']!,
        );
      } else if (role == 'officer') {
        nextScreen = OfficerDashboardScreen(
          userName: user['name']!,
          id: int.parse(user['id']!),
          email: user['email']!,
          role: user['role']!,
          thana: user['thana'] ?? 'Unknown',
        );
      } else {
        // default = driver/user
        nextScreen = DashboardScreen(
          userName: user['name']!,
          email: user['email']!,
          role: user['role']!,
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade700,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'asset/otoms.png',
              width: 250,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
