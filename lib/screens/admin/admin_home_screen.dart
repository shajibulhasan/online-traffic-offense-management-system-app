import 'package:flutter/material.dart';
import '../../widgets/admin/stat_card.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final userName = args?['userName'] ?? 'Admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, $userName 👋",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Chip(
            label: const Text("ADMIN", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green.shade700,
          ),
          const SizedBox(height: 30),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: const [
              StatCard(
                icon: Icons.pending_actions,
                title: "Pending Verifications",
                value: "12",
                color: Colors.orange,
              ),
              StatCard(
                icon: Icons.location_city,
                title: "Total Thana",
                value: "8",
                color: Colors.blue,
              ),
              StatCard(
                icon: Icons.map,
                title: "Total Areas",
                value: "25",
                color: Colors.green,
              ),
              StatCard(
                icon: Icons.person,
                title: "Total Officers",
                value: "45",
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 30),
          const RecentActivitiesSection(),
        ],
      ),
    );
  }
}

class RecentActivitiesSection extends StatelessWidget {
  const RecentActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activities",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      ],
    );
  }
}