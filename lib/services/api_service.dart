import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:online_traffic_offense_management_system/urls/urls.dart';
import 'auth_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static const String baseUrl = Urls.baseUrl;
  // emulator


  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return {
      'status': response.statusCode,
      'data': jsonDecode(response.body),
    };
  }

  static Future<List<dynamic>> getMyOffenses() async {
    final token = await AuthService.getToken();

    debugPrint("TOKEN FROM STORAGE: $token");

    final response = await http.get(
      Uri.parse('$baseUrl/my-offenses'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded['data'] == null) {
        throw Exception("Data key missing");
      }

      return decoded['data'];
    } else {
      throw Exception("Server error");
    }
  }

  static Future<Map<String, dynamic>> createBkashPayment({
    required double amount,
    required String offenseId,
    required String merchantInvoiceNumber,
  }) async {
    try {
      print('Creating payment for amount: $amount, offenseId: $offenseId');
      print('URL: $baseUrl/bkash/create-payment/$amount/$offenseId');

      final response = await http.post(
        Uri.parse('$baseUrl/bkash/create-payment/$amount/$offenseId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      print('Network error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<void> updateOffenseAfterPayment(
      String offenseId,
      String transactionId,
      ) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/offenses/update-payment-status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'offense_id': offenseId,
          'transaction_id': transactionId,
          'status': 'paid',
        }),
      );
    } catch (e) {
      print('Error updating offense: $e');
    }
  }

  static Future<String> downloadOffensePdf() async {
    final token = await AuthService.getToken();
    final user = await AuthService.getUser();
    final userId = user['id'];

    if (token == null || userId == null) {
      throw Exception('User not logged in');
    }

    final dio = Dio();

    final url = "$baseUrl/offense-list-pdf/$userId";

    final dir = await getApplicationDocumentsDirectory();
    final savePath = "${dir.path}/offense_list_$userId.pdf";

    await dio.download(
      url,
      savePath,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return savePath;
  }
}
