import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";
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


}
