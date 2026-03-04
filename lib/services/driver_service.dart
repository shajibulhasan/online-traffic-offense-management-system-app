// lib/services/driver_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:online_traffic_offense_management_system/urls/urls.dart';
import '../screens/model/driver_model.dart';

class DriverService {
  static Future<DriverModel> fetchDriverProfile(String token) async {
    try {
      debugPrint("🔑 TOKEN FROM STORAGE: $token");

      final response = await http.get(
        Uri.parse("${Urls.baseUrl}/myProfile"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📡 STATUS CODE: ${response.statusCode}");
      debugPrint("📦 BODY: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        // চেক করুন response এ data field আছে কিনা
        if (jsonResponse['data'] != null) {
          // data field থেকে ডাটা নিন
          debugPrint("✅ Data field found, parsing from data");
          return DriverModel.fromJson(jsonResponse['data']);
        } else {
          // যদি data field না থাকে, পুরো response ব্যবহার করুন
          debugPrint("⚠️ No data field found, parsing full response");
          return DriverModel.fromJson(jsonResponse);
        }
      } else {
        throw Exception(
          "STATUS: ${response.statusCode}, BODY: ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("❌ Error in fetchDriverProfile: $e");
      rethrow;
    }
  }
}