import 'package:flutter/material.dart';

import '../model/driver_model.dart';
class UpdateProfileScreen extends StatefulWidget {
  final DriverModel driver;
  final String token;

  const UpdateProfileScreen({super.key, required this.driver, required this.token});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController nidController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.driver.name);
    emailController = TextEditingController(text: widget.driver.email);
    phoneController = TextEditingController(text: widget.driver.phone ?? "");
    nidController = TextEditingController(text: widget.driver.nid ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    nidController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nidController,
              decoration: const InputDecoration(labelText: "NID"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
              onPressed: () {
                // TODO: Call API to update profile using widget.token
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Update API integration pending")),
                );
              },
              child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}