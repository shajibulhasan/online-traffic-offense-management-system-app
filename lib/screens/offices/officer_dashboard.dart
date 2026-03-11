import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../drivers/driver_profile.dart';
import '../login_screen.dart';
import 'add_offense.dart';
import 'offense_list.dart';
class OfficerDashboardScreen extends StatefulWidget {
  final String userName;
  final int id;
  final String email;
  final String role;
  final String thana;


  const OfficerDashboardScreen({
    super.key,
    required this.userName,
    required this.email,
    required this.role,
    required this.thana,
    required this.id,
  });

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {

  int currentIndex = 0;
  String? token;

  final List<String> pages = [
    "Home",
    "Add Offense",
    "Offense List",
    "Profile",
  ];


  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    final t = await AuthService.getToken();
    setState(() {
      token = t;
    });
  }

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(pages[currentIndex]),
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
            drawerItem(Icons.gavel, "Add Offense", 1),
            drawerItem(Icons.list, "Offense List", 2),
            drawerItem(Icons.person, "Profile", 2),



            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),

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
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: "Add Offense"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "Offense List"),
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
        return AddOffenseScreen(
          officerName: widget.userName,
          officerId: widget.id,
          officerThana: widget.thana.toString(),
          token: token!,
        );
      case 2:
        return OfficerOffenseListScreen();
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
