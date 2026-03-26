import 'package:flutter/material.dart';

void showVerificationDialog(BuildContext context, bool isApprove) {
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