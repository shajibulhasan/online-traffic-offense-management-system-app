import 'package:flutter/material.dart';

void showAddEditDialog({
  required BuildContext context,
  required String type,
  bool isEdit = false,
  String? initialValue,
  String? initialThana,
  Function(String)? onSave,
  Function(Map<String, dynamic>)? onSaveArea,
}) {
  final nameController = TextEditingController(text: initialValue);
  String? selectedThana = initialThana;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(isEdit ? "Edit $type" : "Add New $type"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "${type[0].toUpperCase()}${type.substring(1)} Name",
                  border: const OutlineInputBorder(),
                ),
              ),
              if (type == 'area') const SizedBox(height: 16),
              if (type == 'area')
                DropdownButtonFormField<String>(
                  value: selectedThana,
                  decoration: const InputDecoration(
                    labelText: "Select Thana",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Mirpur", child: Text("Mirpur")),
                    DropdownMenuItem(value: "Gulshan", child: Text("Gulshan")),
                    DropdownMenuItem(value: "Banani", child: Text("Banani")),
                    DropdownMenuItem(value: "Uttara", child: Text("Uttara")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedThana = value;
                    });
                  },
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
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                if (type == 'thana') {
                  onSave?.call(name);
                } else if (type == 'area') {
                  if (selectedThana == null) return;
                  onSaveArea?.call({
                    'name': name,
                    'thana': selectedThana,
                  });
                }

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
        );
      },
    ),
  );
}