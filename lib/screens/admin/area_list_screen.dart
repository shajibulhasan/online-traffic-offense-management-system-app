import 'package:flutter/material.dart';
import '../../widgets/shared/add_edit_dialog.dart';
import '../../widgets/shared/delete_dialog.dart';

class AreaListScreen extends StatefulWidget {
  const AreaListScreen({super.key});

  @override
  State<AreaListScreen> createState() => _AreaListScreenState();
}

class _AreaListScreenState extends State<AreaListScreen> {
  final List<Map<String, dynamic>> _areas = [
    {'id': 1, 'name': 'Mirpur DOHS', 'thana': 'Mirpur'},
    {'id': 2, 'name': 'Kafrul', 'thana': 'Mirpur'},
    {'id': 3, 'name': 'Gulshan-1', 'thana': 'Gulshan'},
    {'id': 4, 'name': 'Gulshan-2', 'thana': 'Gulshan'},
    {'id': 5, 'name': 'Banani DOHS', 'thana': 'Banani'},
  ];

  void _addArea(Map<String, dynamic> areaData) {
    setState(() {
      _areas.add({
        'id': _areas.length + 1,
        'name': areaData['name'],
        'thana': areaData['thana'],
      });
    });
  }

  void _editArea(int id, Map<String, dynamic> newData) {
    setState(() {
      final index = _areas.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        _areas[index]['name'] = newData['name'];
        _areas[index]['thana'] = newData['thana'];
      }
    });
  }

  void _deleteArea(int id) {
    setState(() {
      _areas.removeWhere((a) => a['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Area List"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddEditDialog(
              context: context,
              type: 'area',
              onSaveArea: _addArea,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _areas.length,
        itemBuilder: (context, index) {
          final area = _areas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text("${index + 1}"),
              ),
              title: Text(area['name']),
              subtitle: Text("Thana: ${area['thana']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showAddEditDialog(
                      context: context,
                      type: 'area',
                      isEdit: true,
                      initialValue: area['name'],
                      initialThana: area['thana'],
                      onSaveArea: (newData) => _editArea(area['id'], newData),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => showDeleteDialog(
                      context: context,
                      type: 'area',
                      onDelete: () => _deleteArea(area['id']),
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