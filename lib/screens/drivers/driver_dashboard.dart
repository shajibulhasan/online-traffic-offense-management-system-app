import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';

class DriverDashboardScreen extends StatelessWidget {
  final String userName;
  final String email;
  final String role;

  const DriverDashboardScreen({
    super.key,
    required this.userName,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text(role),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  userName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            drawerItem(context, Icons.dashboard, "Dashboard"),
            drawerItem(context, Icons.person, "Profile"),
            drawerItem(context, Icons.warning, 'My Offenses'),


            const Spacer(),

            drawerItem(context, Icons.logout, "Logout", logout: true),
          ],
        ),
      ),

      body: const Center(
        child: Text(
          "Dashboard Content Here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget drawerItem(
      BuildContext context,
      IconData icon,
      String title, {
        bool logout = false,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () async {
        Navigator.pop(context);

        if (logout) {
          await AuthService.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        }
      },
    );
  }
}
