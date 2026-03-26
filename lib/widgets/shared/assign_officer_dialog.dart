import 'package:flutter/material.dart';

void showAssignOfficerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Assign Officer"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "Select Officer",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: "Officer 1", child: Text("Officer Rashid")),
              DropdownMenuItem(value: "Officer 2", child: Text("Officer Karim")),
              DropdownMenuItem(value: "Officer 3", child: Text("Officer Rahman")),
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