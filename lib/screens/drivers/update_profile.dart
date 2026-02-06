import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/driver_model.dart';
import 'package:online_traffic_offense_management_system/urls/urls.dart';

class UpdateProfileScreen extends StatefulWidget {
  final DriverModel driver;
  final String token;

  const UpdateProfileScreen({
    super.key,
    required this.driver,
    required this.token
  });

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController nidController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
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

  Future<void> _updateProfile() async {
    // Validate inputs
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty) {
      _showSnackBar("Please fill all required fields", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare the data to send
      Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'nid': nidController.text.trim(),
      };


      // Make the API call - আপনার ব্যাকএন্ডে POST method ব্যবহার করা হয়েছে
      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/update-profile/${widget.driver.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      );

      // Parse response
      var responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        var userData = responseData['data'];

        // Create updated driver model from API response
        DriverModel updatedDriver = DriverModel(
          id: userData['id'],
          name: userData['name'] ?? nameController.text.trim(),
          email: userData['email'] ?? emailController.text.trim(),
          phone: userData['phone']?.toString(),
          nid: userData['nid']?.toString(),
          role: userData['role'] ?? widget.driver.role,
        );

        if (mounted) {
          _showSnackBar(responseData['message'] ?? "Profile updated successfully", Colors.green);

          // Navigate back with the updated driver data
          Navigator.pop(context, updatedDriver);
        }
      } else {
        // Handle error response
        String errorMessage = responseData['message'] ?? "Failed to update profile";
        if (responseData['errors'] != null) {
          // Handle validation errors
          var errors = responseData['errors'];
          errorMessage = errors.values.first.first.toString();
        }

        if (mounted) {
          _showSnackBar(errorMessage, Colors.red);
        }
      }
    } catch (e) {
      // Handle network errors
      print('Network Error Details: $e'); // কনসোলে প্রিন্ট করুন
      print('Error type: ${e.runtimeType}');
      String errorMessage = "Network Error";
      if (e.toString().contains('SocketException')) {
        errorMessage = "Could not connect to server. Check your internet connection.";
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = "Connection timeout. Server is not responding.";
      } else if (e.toString().contains('HttpException')) {
        errorMessage = "HTTP error occurred.";
      }
      if (mounted) {
        _showSnackBar("Network Error: ${e.toString()}", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Name Field
            const Text("Name *", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Enter your full name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),

            // Email Field
            const Text("Email *", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: "Enter your email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Phone Field
            const Text("Phone", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                hintText: "Enter your phone number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // NID Field
            const Text("NID", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: nidController,
              decoration: const InputDecoration(
                hintText: "Enter your NID number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),


            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _updateProfile,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}