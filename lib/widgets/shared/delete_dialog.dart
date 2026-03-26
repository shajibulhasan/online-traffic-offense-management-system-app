import 'package:flutter/material.dart';

void showDeleteDialog({
  required BuildContext context,
  required String type,
  required VoidCallback onDelete,
}) {
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
            onDelete();
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