// lib/screens/drivers/driver_profile_screen.dart
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
    debugPrint('🔄 Loading driver profile...');
    setState(() {
      driverFuture = DriverService.fetchDriverProfile(widget.token)
          .then((driver) {
        debugPrint('✅ Driver loaded successfully:');
        debugPrint('  - Name: ${driver.name}');
        debugPrint('  - Email: ${driver.email}');
        debugPrint('  - Phone: ${driver.phone}');
        debugPrint('  - License: ${driver.license}');
        debugPrint('  - Role: ${driver.role}');

        _currentDriver = driver;
        return driver;
      })
          .catchError((error) {
        debugPrint('❌ Error loading driver: $error');
        return error;
      });
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

    if (updatedDriver != null && updatedDriver is DriverModel) {
      setState(() {
        _currentDriver = updatedDriver;
        driverFuture = Future.value(updatedDriver);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      _loadDriverProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDriverProfile,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDriverProfile();
        },
        color: Colors.green,
        child: FutureBuilder<DriverModel>(
          future: driverFuture,
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 16),
                    Text("Loading profile..."),
                  ],
                ),
              );
            }

            // Error state
            if (snapshot.hasError) {
              debugPrint('❌ Snapshot error: ${snapshot.error}');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // No data state
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text("No data available"),
              );
            }

            final driver = snapshot.data!;

            debugPrint('🎨 Rendering UI for: ${driver.name}');

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
                          Text(
                            driver.displayRole, // Use displayRole instead of hardcoded text
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildInfoTile(Icons.email, "Email", driver.email),
                          const Divider(),
                          _buildInfoTile(Icons.phone, "Phone", driver.phone ?? "Not provided"),
                          const Divider(),
                          _buildInfoTile(Icons.badge, "NID", driver.nid ?? "Not provided"),
                          const Divider(),
                          // Show license if available (for both user and driver roles)
                          if (driver.license != null && driver.license!.isNotEmpty)
                            _buildInfoTile(Icons.drive_eta, "License", driver.license!),



                          const SizedBox(height: 20),

                          // Update Profile Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _navigateToUpdateProfile(driver),
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              "Update Profile",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 22),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // For backward compatibility
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
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
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
    // Make sure you have this asset in pubspec.yaml
    return const AssetImage("asset/unknown.png");
  }
}