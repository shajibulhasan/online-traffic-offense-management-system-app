import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_traffic_offense_management_system/urls/urls.dart';
import '../screens/model/thana.dart';

class ThanaService {
  final String token;
  static const String baseUrl = Urls.baseUrl; // If using API routes, otherwise remove this

  ThanaService({required this.token});

  // Get all thanas
  Future<List<Thana>> getAllThanas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/thanas/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Thana List Response Status: ${response.statusCode}');
      print('Thana List Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Handle different response structures
        List<Thana> thanas = [];

        if (data['success'] == true) {
          // If data is directly in 'data' field
          if (data['data'] is List) {
            thanas = (data['data'] as List)
                .map((json) => Thana.fromJson(json))
                .toList();
          }
          // If data is directly the list
          else if (data is List) {
            thanas = (data as List)
                .map((json) => Thana.fromJson(json))
                .toList();
          }
          // If data is in 'thanas' field
          else if (data['thanas'] is List) {
            thanas = (data['thanas'] as List)
                .map((json) => Thana.fromJson(json))
                .toList();
          }
        }
        // If response is directly an array
        else if (data is List) {
          thanas = (data as List)
              .map((json) => Thana.fromJson(json))
              .toList();
        }

        return thanas;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found. Please check the URL.');
      } else {
        throw Exception('Failed to load thanas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllThanas: $e');
      throw Exception('Error: $e');
    }
  }

  // Create new thana
  Future<Thana> createThana(Map<String, dynamic> thanaData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/thanas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(thanaData),
      );

      print('Create Thana Response Status: ${response.statusCode}');
      print('Create Thana Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          // Check if data exists and is not null
          if (data['data'] != null) {
            return Thana.fromJson(data['data']);
          } else {
            // If no data returned, throw exception
            throw Exception('No data returned from server');
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to create thana');
        }
      } else {
        throw Exception('Failed to create thana: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createThana: $e');
      throw Exception('Error: $e');
    }
  }

  // Update thana
  Future<Thana> updateThana(int id, Map<String, dynamic> thanaData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/thanas/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(thanaData),
      );

      print('Update Thana Response Status: ${response.statusCode}');
      print('Update Thana Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Check if response body is empty
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          if (data['data'] != null) {
            return Thana.fromJson(data['data']);
          } else {
            return await getThanaById(id);
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to update thana');
        }
      } else {
        throw Exception('Failed to update thana: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateThana: $e');
      throw Exception('Error: $e');
    }
  }

// Add this helper method to get thana by ID
  Future<Thana> getThanaById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/get/thana/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Thana.fromJson(data['data']);
        } else {
          throw Exception('Thana not found');
        }
      } else {
        throw Exception('Failed to fetch thana');
      }
    } catch (e) {
      throw Exception('Error fetching thana: $e');
    }
  }

  // Delete thana
  Future<void> deleteThana(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/thanas/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Delete Thana Response Status: ${response.statusCode}');
      print('Delete Thana Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] != true && data['success'] != null) {
          throw Exception(data['message'] ?? 'Failed to delete thana');
        }
      } else {
        throw Exception('Failed to delete thana: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteThana: $e');
      throw Exception('Error: $e');
    }
  }
}