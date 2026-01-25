import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
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
  int currentIndex = 0;

  final List<String> pages = [
    "Home",
    "My Offenses",
    "Payments",
    "History",
    "Notifications",
    "Profile",
    "Settings",
  ];

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
            drawerItem(Icons.history, "History", 3),
            drawerItem(Icons.notifications, "Notifications", 4),
            drawerItem(Icons.person, "Profile", 5),
            drawerItem(Icons.settings, "Settings", 6),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),

      /// 🔥 BODY (AUTO CHANGE)
      body: getPage(),

      /// 🔹 Bottom Navigation (LIMITED)
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

  /// 🔹 DRAWER ITEM
  Widget drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: currentIndex == index,
      onTap: () {
        setState(() {
          currentIndex = index;
        });
        Navigator.pop(context); // close drawer
      },
    );
  }

  /// 🔹 PAGE SWITCH
  Widget getPage() {
    switch (currentIndex) {
      case 0:
        return homePage();
      case 1:
        return const MyOffenseScreen();
      case 2:
        return centerText("Payments");
      case 3:
        return centerText("History");
      case 4:
        return centerText("Notifications");
      case 5:
        return centerText("Profile");
      case 6:
        return centerText("Settings");
      default:
        return homePage();
    }
  }

  /// 🔹 PAGES
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

  Widget centerText(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 22),
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
