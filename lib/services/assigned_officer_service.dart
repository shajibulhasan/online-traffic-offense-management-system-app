import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_traffic_offense_management_system/urls/urls.dart';
import '../screens/model/assigned_officer.dart';

class AssignedOfficerService {
  final String token;
  static const String baseUrl = Urls.baseUrl; // Replace with your URL

  AssignedOfficerService({required this.token});

  // Get all assigned officers
  Future<List<AssignedOfficer>> getAllAssignedOfficers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assigned-officers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Assigned Officers Response Status: ${response.statusCode}');
      print('Assigned Officers Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> officersData = data['data'] ?? [];
          return officersData.map((json) => AssignedOfficer.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load assigned officers');
        }
      } else {
        throw Exception('Failed to load assigned officers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllAssignedOfficers: $e');
      throw Exception('Error: $e');
    }
  }

  // Get all officers for dropdown
  Future<List<Map<String, dynamic>>> getAllOfficers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/officers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> officersData = data['data'] ?? [];
          return officersData.map((json) => {
            'id': json['id'],
            'name': json['name'],
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting officers: $e');
      return [];
    }
  }

  // Get all areas for dropdown
  Future<List<Map<String, dynamic>>> getAllAreas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/areas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> areasData = data['data'] ?? [];
          return areasData.map((json) => {
            'id': json['id'],
            'area_name': json['area_name'],
            'thana_name': json['thana_name'],
            'district': json['district'],
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting areas: $e');
      return [];
    }
  }

  // Get thanas by district
  Future<List<Map<String, dynamic>>> getThanasByDistrict(String district) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/thanas-by-district/${Uri.encodeComponent(district)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> thanasData = data['data'] ?? [];
          return thanasData.map((json) => {
            'id': json['id'],
            'thana_name': json['thana_name'],
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting thanas: $e');
      return [];
    }
  }

  // Get all districts
  List<String> getAllDistricts() {
    return [
      'Bagerhat', 'Bandarban', 'Barguna', 'Barisal', 'Bhola', 'Bogura',
      'Brahmanbaria', 'Chandpur', 'Chapai Nawabganj', 'Chittagong',
      'Chuadanga', 'Comilla', "Coxsbazar", 'Dhaka', 'Dinajpur', 'Faridpur',
      'Feni', 'Gaibandha', 'Gazipur', 'Gopalganj', 'Habiganj', 'Jamalpur',
      'Jessore', 'Jhalokathi', 'Jhenaidah', 'Joypurhat', 'Khagrachari',
      'Khulna', 'Kishoreganj', 'Kurigram', 'Kushtia', 'Lakshmipur',
      'Lalmonirhat', 'Madaripur', 'Magura', 'Manikganj', 'Meherpur',
      'Moulvibazar', 'Munshiganj', 'Mymensingh', 'Naogaon', 'Narail',
      'Narayanganj', 'Narsingdi', 'Natore', 'Netrokona', 'Nilphamari',
      'Noakhali', 'Pabna', 'Panchagarh', 'Patuakhali', 'Pirojpur',
      'Rajbari', 'Rajshahi', 'Rangamati', 'Rangpur', 'Satkhira',
      'Shariatpur', 'Sherpur', 'Sirajganj', 'Sunamganj', 'Sylhet',
      'Tangail', 'Thakurgaon'
    ];
  }

  // Assign officer
  Future<AssignedOfficer> assignOfficer(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assigned-officers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      print('Assign Officer Response Status: ${response.statusCode}');
      print('Assign Officer Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return AssignedOfficer.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to assign officer');
        }
      } else {
        throw Exception('Failed to assign officer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in assignOfficer: $e');
      throw Exception('Error: $e');
    }
  }

  // Update assigned officer
  Future<AssignedOfficer> updateAssignedOfficer(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/assigned-officers/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      print('Update Assigned Officer Response Status: ${response.statusCode}');
      print('Update Assigned Officer Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return AssignedOfficer.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update assigned officer');
        }
      } else {
        throw Exception('Failed to update assigned officer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateAssignedOfficer: $e');
      throw Exception('Error: $e');
    }
  }

  // Delete assigned officer
  Future<void> deleteAssignedOfficer(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/assigned-officers/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Delete Assigned Officer Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to delete assigned officer');
        }
      } else {
        throw Exception('Failed to delete assigned officer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteAssignedOfficer: $e');
      throw Exception('Error: $e');
    }
  }
}