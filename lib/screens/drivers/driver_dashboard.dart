import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'driver_profile.dart';
import 'my_offense_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String email;
  final String role;

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.email,
    required this.role,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0; // ONLY 0–3 (BottomNav safe)
  String? token;

  final List<String> pages = [
    "Home",
    "My Offenses",
    "Payments",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  /// 🔐 LOAD TOKEN
  Future<void> loadToken() async {
    final t = await AuthService.getToken();
    setState(() {
      token = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      /// 🔥 DRAWER
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.userName),
              accountEmail: Text(widget.email),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  widget.userName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            drawerItem(Icons.home, "Home", 0),
            drawerItem(Icons.gavel, "My Offenses", 1),
            drawerItem(Icons.payment, "Payments", 2),
            drawerItem(Icons.person, "Profile", 3),

            const Divider(),

            /// 🔹 EXTRA PAGES (NO INDEX CHANGE)
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("History"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => simplePage("History"),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => simplePage("Notifications"),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => simplePage("Settings"),
                  ),
                );
              },
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),

      /// 🔥 BODY
      body: getPage(),

      /// 🔹 Bottom Navigation (SAFE)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: "Offenses"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  /// 🔹 DRAWER ITEM (BOTTOM NAV SYNC)
  Widget drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: currentIndex == index,
      onTap: () {
        setState(() => currentIndex = index);
        Navigator.pop(context);
      },
    );
  }

  /// 🔹 PAGE SWITCH (ONLY 0–3)
  Widget getPage() {
    switch (currentIndex) {
      case 0:
        return homePage();
      case 1:
        return const MyOffenseScreen();
      case 2:
        return simplePage("Payments");
      case 3:
        if (token == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return DriverProfileScreen(token: token!);
      default:
        return homePage();
    }
  }

  /// 🔹 HOME PAGE
  Widget homePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, ${widget.userName} 👋",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Chip(
            label: Text(
              widget.role.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.indigo,
          ),
        ],
      ),
    );
  }

  /// 🔹 SIMPLE PAGE
  Widget simplePage(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  /// 🔹 LOGOUT
  Future<void> logout() async {
    await AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}
