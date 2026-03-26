import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../login_screen.dart';
import 'admin_home_screen.dart';
import 'verify_officers_screen.dart';
import 'thana_list_screen.dart';
import 'area_list_screen.dart';
import 'assigned_officers_screen.dart';
import '../../widgets/admin/profile_section.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String userName;
  final int id;
  final String email;
  final String role;

  const AdminDashboardScreen({
    super.key,
    required this.userName,
    required this.email,
    required this.role,
    required this.id,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int currentIndex = 0;
  String? token;

  final List<NavItem> navItems = [
    NavItem(icon: Icons.home, label: "Home", page: AdminHomeScreen()),
    NavItem(icon: Icons.verified_user, label: "Verify", page: const VerifyOfficersScreen()),
    NavItem(icon: Icons.location_city, label: "Thana", page: const ThanaListScreen()),
    NavItem(icon: Icons.map, label: "Area", page: const AreaListScreen()),
    NavItem(icon: Icons.assignment_ind, label: "Assigned", page: const AssignedOfficersScreen()),
    NavItem(icon: Icons.person, label: "Profile", page: null), // Profile handled separately
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(navItems[currentIndex].label),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      drawer: AdminDrawer(
        userName: widget.userName,
        email: widget.email,
        currentIndex: currentIndex,
        onItemSelected: (index) {
          setState(() => currentIndex = index);
          Navigator.pop(context);
        },
        onLogout: logout,
      ),
      body: getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget getPage() {
    if (currentIndex == 5) {
      if (token == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return ProfileSection(token: token!, userName: widget.userName);
    }
    return navItems[currentIndex].page!;
  }

  Future<void> logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final Widget? page;

  NavItem({
    required this.icon,
    required this.label,
    this.page,
  });
}

class AdminDrawer extends StatelessWidget {
  final String userName;
  final String email;
  final int currentIndex;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;

  const AdminDrawer({
    super.key,
    required this.userName,
    required this.email,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              child: Text(
                userName[0].toUpperCase(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.green),
          ),
          _drawerItem(Icons.home, "Home", 0),
          _drawerItem(Icons.verified_user, "Verify Officers", 1),
          _drawerItem(Icons.location_city, "Thana List", 2),
          _drawerItem(Icons.map, "Area List", 3),
          _drawerItem(Icons.assignment_ind, "Assigned Officers", 4),
          _drawerItem(Icons.person, "Profile", 5),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: currentIndex == index ? Colors.deepPurple : null),
      title: Text(
        title,
        style: TextStyle(
          color: currentIndex == index ? Colors.deepPurple : null,
          fontWeight: currentIndex == index ? FontWeight.bold : null,
        ),
      ),
      selected: currentIndex == index,
      onTap: () => onItemSelected(index),
    );
  }
}