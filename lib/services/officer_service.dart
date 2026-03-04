// lib/services/officer_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/model/driver_model.dart';
import '../screens/model/offense_model.dart';
import '../urls/urls.dart';

class OfficerService {
  final String token;

  OfficerService({required this.token});

  // Search Driver
  Future<DriverModel?> searchDriver({
    required String type,
    required String value,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/officer/search-driver?type=$type&value=${Uri.encodeComponent(value)}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['success'] == true) {
          if (data['driver'] != null) {
            var driverData = data['driver'];

            // Print raw data from backend
            print('📊 Raw driver data from backend:');
            print('  - id: ${driverData['id']} (${driverData['id'].runtimeType})');
            print('  - name: ${driverData['name']} (${driverData['name'].runtimeType})');
            print('  - email: ${driverData['email']} (${driverData['email'].runtimeType})');
            print('  - phone: ${driverData['phone']} (${driverData['phone'].runtimeType})');

            // Check if email exists and is not null
            if (driverData.containsKey('email')) {
              print('✅ Email key exists in response');
              if (driverData['email'] != null) {
                print('✅ Email value is NOT null: ${driverData['email']}');
              } else {
                print('❌ Email value is null');
              }
            } else {
              print('❌ Email key does NOT exist in response');
            }

            return DriverModel(
              id: driverData['id'] ?? 0,
              name: driverData['name'] ?? 'Unknown',
              email: driverData['email']?.toString() ?? '', // This will now work
              phone: driverData['phone']?.toString(),
              nid: driverData['nid']?.toString(),
              license: driverData['license']?.toString(),
              role: driverData['role'] ?? 'driver',
            );
          } else {
            throw Exception('Driver data not found in response');
          }
        } else {
          throw Exception(data['message'] ?? 'Driver not found');
        }
      } else if (response.statusCode == 404) {
        // Driver not found
        return null;
      } else {
        try {
          var errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to search driver');
        } catch (e) {
          throw Exception('Failed to search driver: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Search driver error: $e');
      rethrow;
    }
  }

  // Add Offense
  Future<OffenseModel> addOffense(OffenseModel offense) async {
    try {
      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/officer/add-offense'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(offense.toJson()),
      );

      print('Add offense response: ${response.statusCode}');
      print('Add offense body: ${response.body}');

      if (response.statusCode == 201) {
        var data = json.decode(response.body);

        if (data['success'] == true) {
          if (data['offense'] != null) {
            return OffenseModel.fromJson(data['offense']);
          } else {
            return OffenseModel.fromJson(data);
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to add offense');
        }
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add offense');
      }
    } catch (e) {
      print('Add offense error: $e');
      rethrow;
    }
  }
}