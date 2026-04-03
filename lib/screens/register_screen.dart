import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:online_traffic_offense_management_system/urls/urls.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final nidController = TextEditingController();
  final licenseController = TextEditingController();

  String selectedRole = 'user';
  bool isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            buildField(
              controller: nameController,
              hint: "Full Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            buildField(
              controller: emailController,
              hint: "Email",
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: isPasswordHidden,
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            buildField(
              controller: phoneController,
              hint: "Phone Number",
              icon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            buildField(
              controller: nidController,
              hint: "NID Number",
              icon: Icons.badge_outlined,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // License field - only visible when role is 'user'
            if (selectedRole == 'user') ...[
              buildField(
                controller: licenseController,
                hint: "License Number",
                icon: Icons.badge_outlined,
                keyboard: TextInputType.number,
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),

            /// ROLE SELECT
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Role",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: roleButton("User", "user")),
                const SizedBox(width: 12),
                Expanded(child: roleButton("Officer", "officer")),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: register,
                child: const Text(
                  "Register",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                TextButton(onPressed: (){
                  Navigator.pushReplacementNamed(context, '/login');
                }, child: Text("Login"))
              ],
            )
          ],
        ),
      ),
    );
  }


  Widget buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }


  Widget roleButton(String title, String value) {
    final isSelected = selectedRole == value;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedRole = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(title),
    );
  }

  Future<void> register() async {
    // Validate required fields
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty ||
        nidController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    // Validate license field only for user role
    if (selectedRole == 'user' && licenseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("License number is required for users")),
      );
      return;
    }

    final url = Uri.parse("${Urls.baseUrl}/register");

    // Prepare request body
    Map<String, dynamic> requestBody = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text,
      "phone": phoneController.text.trim(),
      "nid": nidController.text.trim(),
      "role": selectedRole,
    };

    // Only add license field if role is user
    if (selectedRole == 'user') {
      requestBody["license"] = licenseController.text.trim();
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Registered successfully")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Registration failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      print(e);
    }
  }

}