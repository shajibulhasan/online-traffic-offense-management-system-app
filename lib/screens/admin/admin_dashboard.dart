import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../drivers/driver_profile.dart';
import '../login_screen.dart';

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

  final List<String> pages = [
    "Home",
    "Verify Officers",
    "Thana List",
    "Area List",
    "Assigned Officers",
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

  @override
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
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
            ),

            drawerItem(Icons.home, "Home", 0),
            drawerItem(Icons.verified_user, "Verify Officers", 1),
            drawerItem(Icons.location_city, "Thana List", 2),
            drawerItem(Icons.map, "Area List", 3),
            drawerItem(Icons.assignment_ind, "Assigned Officers", 4),
            drawerItem(Icons.person, "Profile", 5),

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

      /// Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: "Verify"),
          BottomNavigationBarItem(icon: Icon(Icons.location_city), label: "Thana"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Area"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind), label: "Assigned"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  /// Drawer Item
  Widget drawerItem(IconData icon, String title, int index) {
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
      onTap: () {
        setState(() => currentIndex = index);
        Navigator.pop(context);
      },
    );
  }

  /// Page Switch
  Widget getPage() {
    switch (currentIndex) {
      case 0:
        return homePage();
      case 1:
        return verifyOfficersPage();
      case 2:
        return thanaListPage();
      case 3:
        return areaListPage();
      case 4:
        return assignedOfficersPage();
      case 5:
        if (token == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return DriverProfileScreen(token: token!);
      default:
        return homePage();
    }
  }

  /// Home Page (Fixed Version)
  Widget homePage() {
    return SingleChildScrollView(
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
            backgroundColor: Colors.green.shade700,
          ),
          const SizedBox(height: 30),

          // Admin Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                icon: Icons.pending_actions,
                title: "Pending Verifications",
                value: "12",
                color: Colors.orange,
              ),
              _buildStatCard(
                icon: Icons.location_city,
                title: "Total Thana",
                value: "8",
                color: Colors.blue,
              ),
              _buildStatCard(
                icon: Icons.map,
                title: "Total Areas",
                value: "25",
                color: Colors.green,
              ),
              _buildStatCard(
                icon: Icons.person,
                title: "Total Officers",
                value: "45",
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Recent Activities
          const Text(
            "Recent Activities",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person_add, color: Colors.green.shade800),
            ),
            title: const Text("New officer registration"),
            subtitle: const Text("Officer Rashid requested verification"),
            trailing: const Text("2 min ago", style: TextStyle(fontSize: 12)),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.location_on, color: Colors.blue.shade800),
            ),
            title: const Text("New area added"),
            subtitle: const Text("Mirpur DOHS added to Dhaka North"),
            trailing: const Text("1 hour ago", style: TextStyle(fontSize: 12)),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.assignment_turned_in, color: Colors.orange.shade800),
            ),
            title: const Text("Officer assigned"),
            subtitle: const Text("Officer Karim assigned to Gulshan area"),
            trailing: const Text("3 hours ago", style: TextStyle(fontSize: 12)),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Stat Card Widget
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Verify Officers Page
  Widget verifyOfficersPage() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Verify Officers"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Pending", icon: Icon(Icons.pending)),
              Tab(text: "Verified", icon: Icon(Icons.verified)),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Officers List
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Text("${index + 1}"),
                    ),
                    title: Text("Officer ${index + 1}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Email: officer@example.com"),
                        Text("Thana: Mirpur"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () {
                            _showVerificationDialog(true);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            _showVerificationDialog(false);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Verified Officers List
            const Center(
              child: Text("Verified officers will appear here"),
            ),
          ],
        ),
      ),
    );
  }

  /// Verification Dialog
  void _showVerificationDialog(bool isApprove) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? "Approve Officer" : "Reject Officer"),
        content: Text(isApprove
            ? "Are you sure you want to approve this officer?"
            : "Are you sure you want to reject this officer?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isApprove
                      ? "Officer approved successfully"
                      : "Officer rejected"),
                  backgroundColor: isApprove ? Colors.green : Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: isApprove ? Colors.green : Colors.red,
            ),
            child: Text(isApprove ? "Approve" : "Reject"),
          ),
        ],
      ),
    );
  }

  /// Thana List Page
  Widget thanaListPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thana List"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEditDialog('thana');
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text("${index + 1}"),
              ),
              title: Text("Thana ${index + 1}"),
              subtitle: Text("${index + 3} areas, ${index + 5} officers"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showAddEditDialog('thana', isEdit: true);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteDialog('thana');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Area List Page
  Widget areaListPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Area List"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEditDialog('area');
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text("${index + 1}"),
              ),
              title: Text("Area ${index + 1}"),
              subtitle: const Text("Thana: Mirpur"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showAddEditDialog('area', isEdit: true);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteDialog('area');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Assigned Officers Page
  Widget assignedOfficersPage() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Assigned Officers"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: "By Thana", icon: Icon(Icons.location_city)),
              Tab(text: "By Area", icon: Icon(Icons.map)),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // By Thana
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    title: Text("Thana ${index + 1}"),
                    subtitle: Text("${index + 3} officers assigned"),
                    children: [
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text("Officer ${index + 1}"),
                        subtitle: const Text("Area: Mirpur DOHS"),
                      ),
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text("Officer ${index + 2}"),
                        subtitle: const Text("Area: Kafrul"),
                      ),
                    ],
                  ),
                );
              },
            ),
            // By Area
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Text("${index + 1}"),
                    ),
                    title: Text("Area ${index + 1}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Thana: Mirpur"),
                        Text("Assigned Officer: Officer Rashid"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      onPressed: () {
                        _showAssignOfficerDialog();
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Add/Edit Dialog
  void _showAddEditDialog(String type, {bool isEdit = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit $type" : "Add New $type"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "${type[0].toUpperCase()}${type.substring(1)} Name",
                border: const OutlineInputBorder(),
              ),
            ),
            if (type == 'area') const SizedBox(height: 16),
            if (type == 'area')
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: "Select Thana",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Mirpur", child: Text("Mirpur")),
                  DropdownMenuItem(value: "Gulshan", child: Text("Gulshan")),
                ],
                onChanged: (value) {},
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? "$type updated" : "$type added"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text(isEdit ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }

  /// Delete Dialog
  void _showDeleteDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete $type"),
        content: Text("Are you sure you want to delete this $type?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$type deleted"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// Assign Officer Dialog
  void _showAssignOfficerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assign Officer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: "Select Officer",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Officer 1", child: Text("Officer Rashid")),
                DropdownMenuItem(value: "Officer 2", child: Text("Officer Karim")),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Officer assigned successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text("Assign"),
          ),
        ],
      ),
    );
  }

  /// Logout
  Future<void> logout() async {
    await AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}