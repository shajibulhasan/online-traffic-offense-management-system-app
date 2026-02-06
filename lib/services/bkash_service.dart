
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class BkashService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String offenseId,
    required String merchantInvoiceNumber,
  }) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/bkash/create-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount.toString(),
          'offense_id': offenseId,
          'merchant_invoice_number': merchantInvoiceNumber,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment creation error: $e');
    }
  }

  static Future<Map<String, dynamic>> executePayment({
    required String paymentId,
    required String offenseId,
  }) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/bkash/execute-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'payment_id': paymentId,
          'offense_id': offenseId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to execute payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment execution error: $e');
    }
  }

  static Future<Map<String, dynamic>> queryPayment({
    required String paymentId,
  }) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/bkash/query-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'payment_id': paymentId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to query payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment query error: $e');
    }
  }
}