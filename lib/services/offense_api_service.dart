// services/offense_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_traffic_offense_management_system/urls/urls.dart';
import '../screens/model/offense.dart';
import 'auth_service.dart';

class OffenseApiService {
  static const String baseUrl = Urls.baseUrl;

  // Get all offenses
  Future<List<Offense>> getAllOffenses() async {
    try {
      final url = Uri.parse('$baseUrl/admin/offenses');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      print('All Offenses URL: $url');
      print('All Offenses Status: ${response.statusCode}');
      print('All Offenses Body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];

          if (data.isEmpty) {
            print('No offenses found');
            return [];
          }

          final offenses = data.map((item) => Offense.fromJson(item)).toList();
          print('Parsed ${offenses.length} offenses successfully');

          return offenses;
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in getAllOffenses: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load offenses: $e');
    }
  }

  // Get paid offenses
  Future<List<Offense>> getPaidOffenses() async {
    try {
      final url = Uri.parse('$baseUrl/admin/offenses/paid');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      print('Paid Offenses URL: $url');
      print('Paid Offenses Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];

          if (data.isEmpty) {
            print('No paid offenses found');
            return [];
          }

          final offenses = data.map((item) => Offense.fromJson(item)).toList();
          print('Parsed ${offenses.length} paid offenses successfully');

          return offenses;
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPaidOffenses: $e');
      throw Exception('Failed to load paid offenses: $e');
    }
  }

  // Get unpaid offenses
  Future<List<Offense>> getUnpaidOffenses() async {
    try {
      final url = Uri.parse('$baseUrl/admin/offenses/unpaid');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      print('Unpaid Offenses URL: $url');
      print('Unpaid Offenses Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];

          if (data.isEmpty) {
            print('No unpaid offenses found');
            return [];
          }

          final offenses = data.map((item) => Offense.fromJson(item)).toList();
          print('Parsed ${offenses.length} unpaid offenses successfully');

          return offenses;
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUnpaidOffenses: $e');
      throw Exception('Failed to load unpaid offenses: $e');
    }
  }

  // Combined fetch all data
  Future<Map<String, List<Offense>>> fetchAllOffenseData() async {
    try {
      final results = await Future.wait([
        getAllOffenses(),
        getPaidOffenses(),
        getUnpaidOffenses(),
      ]);

      return {
        'all': results[0],
        'paid': results[1],
        'unpaid': results[2],
      };
    } catch (e) {
      print('Error fetching all data: $e');
      rethrow;
    }
  }
}