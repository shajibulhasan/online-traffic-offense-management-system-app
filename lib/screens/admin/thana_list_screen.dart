import 'package:flutter/material.dart';
import '../../widgets/shared/add_edit_dialog.dart';
import '../../widgets/shared/delete_dialog.dart';

class ThanaListScreen extends StatefulWidget {
  const ThanaListScreen({super.key});

  @override
  State<ThanaListScreen> createState() => _ThanaListScreenState();
}

class _ThanaListScreenState extends State<ThanaListScreen> {
  final List<Map<String, dynamic>> _thanas = [
    {'id': 1, 'name': 'Mirpur', 'areas': 8, 'officers': 12},
    {'id': 2, 'name': 'Gulshan', 'areas': 6, 'officers': 10},
    {'id': 3, 'name': 'Banani', 'areas': 5, 'officers': 8},
    {'id': 4, 'name': 'Uttara', 'areas': 7, 'officers': 11},
    {'id': 5, 'name': 'Mohammadpur', 'areas': 4, 'officers': 7},
  ];

  void _addThana(String name) {
    setState(() {
      _thanas.add({
        'id': _thanas.length + 1,
        'name': name,
        'areas': 0,
        'officers': 0,
      });
    });
  }

  void _editThana(int id, String newName) {
    setState(() {
      final index = _thanas.indexWhere((t) => t['id'] == id);
      if (index != -1) {
        _thanas[index]['name'] = newName;
      }
    });
  }

  void _deleteThana(int id) {
    setState(() {
      _thanas.removeWhere((t) => t['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thana List"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddEditDialog(
              context: context,
              type: 'thana',
              onSave: _addThana,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _thanas.length,
        itemBuilder: (context, index) {
          final thana = _thanas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text("${index + 1}"),
              ),
              title: Text(thana['name']),
              subtitle: Text("${thana['areas']} areas, ${thana['officers']} officers"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showAddEditDialog(
                      context: context,
                      type: 'thana',
                      isEdit: true,
                      initialValue: thana['name'],
                      onSave: (name) => _editThana(thana['id'], name),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => showDeleteDialog(
                      context: context,
                      type: 'thana',
                      onDelete: () => _deleteThana(thana['id']),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}