import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// Dashboards
import 'admin/admin_dashboard.dart';
import 'drivers/driver_dashboard.dart';
import 'offices/officer_dashboard.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'asset/otoms.png',
            fit: BoxFit.contain,
          ),
        ),
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Login to your account",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              CustomTextField(
                hint: "Email",
                icon: Icons.email_outlined,
                controller: emailController,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                hint: "Password",
                icon: Icons.lock_outline,
                controller: passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await ApiService.login(
                      emailController.text,
                      passwordController.text,
                    );

                    if (result['status'] == 200) {
                      final user = result['data']['user'];
                      final token = result['data']['token'];
                      final role = user['role'];

                      /// 🔐 Save login data
                      await AuthService.saveLoginData(
                        token,
                        user['name'],
                        user['email'],
                        role,
                      );

                      /// 🔁 Role-based navigation
                      Widget nextScreen;

                      if (role == 'admin') {
                        nextScreen = AdminDashboardScreen(
                          userName: user['name'],
                          email: user['email'],
                          role: user['role'],
                        );
                      } else if (role == 'officer') {
                        nextScreen = OfficerDashboardScreen(
                          userName: user['name'],
                          email: user['email'],
                          role: user['role'],
                        );
                      } else {
                        // default = user / driver
                        nextScreen = DashboardScreen(
                          userName: user['name'],
                          email: user['email'],
                          role: user['role'],
                        );
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => nextScreen),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['data']['message'] ?? "Login failed",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Login"),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text("Register"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
