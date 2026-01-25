import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MyOffenseScreen extends StatefulWidget {
  const MyOffenseScreen({super.key});

  @override
  State<MyOffenseScreen> createState() => _MyOffenseScreenState();
}

class _MyOffenseScreenState extends State<MyOffenseScreen> {
  late Future<List<dynamic>> offenseFuture;

  @override
  void initState() {
    super.initState();
    offenseFuture = ApiService.getMyOffenses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: offenseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Failed to load offenses"));
        }

        final offenses = snapshot.data!;

        if (offenses.isEmpty) {
          return const Center(child: Text("No offenses found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: offenses.length,
          itemBuilder: (context, index) {
            final o = offenses[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          o['thana_name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        statusBadge(o['status']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Issue: ${o['details_offense']}"),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Fine: ৳${o['fine']}"),
                        Text("Point: ${o['point']}"),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "Date: ${o['created_at']}",
                      style: const TextStyle(color: Colors.grey),
                    ),

                    if (o['status'] == 'unpaid')
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                          ),
                          onPressed: () {
                            // 🔜 Pay Now logic
                          },
                          child: const Text("Pay Now", style: TextStyle(color: Colors.white)),
                        ),
                      )
                    else
                      Text(
                        "Txn ID: ${o['transaction_id']}",
                        style: const TextStyle(color: Colors.green),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'paid' ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
