import 'package:flutter/material.dart';
import 'package:online_traffic_offense_management_system/screens/drivers/update_profile.dart';
import '../../services/driver_service.dart';
import '../model/driver_model.dart';

class DriverProfileScreen extends StatefulWidget {
  final String token;

  const DriverProfileScreen({super.key, required this.token});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late Future<DriverModel> driverFuture;
  DriverModel? _currentDriver;

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
  }

  void _loadDriverProfile() {
    setState(() {
      driverFuture = DriverService.fetchDriverProfile(widget.token);
    });
  }

  void _navigateToUpdateProfile(DriverModel driver) async {
    final updatedDriver = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProfileScreen(
          driver: driver,
          token: widget.token,
        ),
      ),
    );

    // যদি আপডেটেড ড্রাইভার ডাটা ফেরত আসে, তাহলে UI আপডেট করুন
    if (updatedDriver != null && updatedDriver is DriverModel) {
      setState(() {
        _currentDriver = updatedDriver;
        // FutureBuilder রিফ্রেশ করার জন্য নতুন Future সেট করুন
        driverFuture = Future.value(updatedDriver);
      });

      // Success message দেখান
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // যদি কোনো ডাটা না আসে, তাহলে রিফ্রেশ করুন
      _loadDriverProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Profile"),
        backgroundColor: Colors.green,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDriverProfile,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDriverProfile();
        },
        child: FutureBuilder<DriverModel>(
          future: driverFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDriverProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            final driver = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _getProfileImage(driver),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            driver.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Driver Profile",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _infoRow("Email", driver.email),
                          _infoRow("Phone", driver.phone ?? "Not provided"),
                          _infoRow("NID", driver.nid ?? "Not provided"),
                          if (driver.role == "driver")
                            _infoRow("License", driver.license ?? "Not provided"),
                          const SizedBox(height: 20),

                          // Update Profile Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _navigateToUpdateProfile(driver),
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              "Update Profile",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🔹 Build info row
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage(DriverModel driver) {
    if (driver.profileImage != null && driver.profileImage!.isNotEmpty) {
      return NetworkImage(driver.profileImage!);
    }
    return const AssetImage("asset/unknown.png");
  }
}