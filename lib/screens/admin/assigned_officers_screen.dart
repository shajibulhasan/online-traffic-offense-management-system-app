import 'package:flutter/material.dart';
import '../../widgets/shared/assign_officer_dialog.dart';

class AssignedOfficersScreen extends StatefulWidget {
  const AssignedOfficersScreen({super.key});

  @override
  State<AssignedOfficersScreen> createState() => _AssignedOfficersScreenState();
}

class _AssignedOfficersScreenState extends State<AssignedOfficersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Officers"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "By Thana", icon: Icon(Icons.location_city)),
            Tab(text: "By Area", icon: Icon(Icons.map)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ByThanaView(),
          _ByAreaView(),
        ],
      ),
    );
  }
}

class _ByThanaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
                trailing: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  onPressed: () => showAssignOfficerDialog(context),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text("Officer ${index + 2}"),
                subtitle: const Text("Area: Kafrul"),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  onPressed: () => showAssignOfficerDialog(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ByAreaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
              onPressed: () => showAssignOfficerDialog(context),
            ),
          ),
        );
      },
    );
  }
}