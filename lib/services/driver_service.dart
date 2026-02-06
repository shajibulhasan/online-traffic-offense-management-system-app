import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../screens/model/driver_model.dart';


class DriverService {
  static const String baseUrl = "http://192.168.0.197:8000/api/myProfile";

  static Future<DriverModel> fetchDriverProfile(String token) async {
    debugPrint("TOKEN FROM STORAGE: $token");
    final response = await http.get(
      Uri.parse(baseUrl),

      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",

      },
    );

    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return DriverModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        "STATUS: ${response.statusCode}, BODY: ${response.body}",
      );
    }

  }
}
