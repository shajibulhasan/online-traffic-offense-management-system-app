import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../payment/bkash_payment_screen.dart';

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
    _loadOffenses();
  }

  void _loadOffenses() {
    setState(() {
      offenseFuture = ApiService.getMyOffenses();
    });
  }

  Future<void> _handlePayment(String offenseId, double fine) async {
    final merchantInvoiceNumber = 'INV${DateTime.now().millisecondsSinceEpoch}';

    print('Starting payment for offense: $offenseId, amount: $fine');

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BkashPaymentScreen(
          amount: fine,
          offenseId: offenseId,
          merchantInvoiceNumber: merchantInvoiceNumber,
        ),
      ),
    );

    print('Payment result: $result');

    if (result != null && result['success'] == true) {
      // Update offense status
      await ApiService.updateOffenseAfterPayment(
        offenseId,
        result['transaction_id'],
      );

      // Reload offenses
      _loadOffenses();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful! Transaction ID: ${result['transaction_id']}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } else if (result != null && result['success'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Payment failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offenses'),
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: offenseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOffenses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final offenses = snapshot.data!;

          if (offenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    "No offenses found",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text("You have no offense records"),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadOffenses();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: offenses.length,
              itemBuilder: (context, index) {
                final o = offenses[index];
                final fine = double.tryParse(o['fine'].toString()) ?? 0.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                o['thana_name'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            statusBadge(o['status']),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Issue: ${o['details_offense'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Fine: ৳${o['fine']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                "Point: ${o['point']}",
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              "Date: ${o['created_at'] ?? 'N/A'}",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                        const Divider(height: 16),

                        if (o['status'] == 'unpaid')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Due: ৳${o['fine']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _handlePayment(o['id'].toString(), fine),
                                icon: const Icon(Icons.payment, size: 18),
                                label: const Text("Pay Now"),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Txn ID: ${o['transaction_id'] ?? 'N/A'}",
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget statusBadge(String status) {
    final isPaid = status.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid ? Colors.green.shade400 : Colors.red.shade400,
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isPaid ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}