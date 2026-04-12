import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_traffic_offense_management_system/urls/urls.dart';
import '../screens/model/assigned_officer.dart';

class AssignedOfficerService {
  final String token;
  static const String baseUrl = Urls.baseUrl;

  AssignedOfficerService({required this.token});

  Future<List<AssignedOfficer>> getAllAssignedOfficers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assigned-officers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      print("Assigned Officers Response Status: ${response.statusCode}");
      print("Assigned Officers Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> officersData = data['data'] ?? [];
          return officersData.map((json) => AssignedOfficer.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error in getAllAssignedOfficers: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllOfficers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/officers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print("Officers Response Status: ${response.statusCode}");
      print("Officers Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> officersData = data['data'] ?? [];

          // শুধু ভালিড অফিসার রাখুন (id 0 বা null বাদ দিন)
          final validOfficers = officersData
              .where((json) => json['id'] != null && json['id'] != 0)
              .map((json) => {
            'id': json['id'],
            'name': json['name']?.toString() ?? 'Unknown',
          }).toList();

          return validOfficers;
        }
      }
      return [];
    } catch (e) {
      print('Error getting officers: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllAreas() async {
      final response = await http.get(
        Uri.parse('$baseUrl/areas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print("Areas Response Status: ${response.statusCode}");
      print("Areas Response Body: ${response.body}");
      print(token);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> areasData = data['data'] ?? [];
          return areasData.map((json) => {
            'id': json['id'],
            'area_name': json['area_name']?.toString() ?? '',
            'thana_name': json['thana_name']?.toString() ?? '',
            'district': json['district']?.toString() ?? '',
          }).toList();
        }
      }else{
        print('Failed to load areas. Status code: ${response.statusCode}');
      }
      return [];


  }

  Future<List<Map<String, dynamic>>> getThanasByDistrict(String district) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/thanas-by-district/${Uri.encodeComponent(district)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print("Thanas Response Status: ${response.statusCode}");
      print("Thanas Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> thanasData = data['data'] ?? [];
          return thanasData.map((json) => {
            'id': json['id'],
            'thana_name': json['thana_name']?.toString() ?? '',
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting thanas: $e');
      return [];
    }
  }

  List<String> getAllDistricts() {
    return [
      'Bagerhat', 'Bandarban', 'Barguna', 'Barisal', 'Bhola', 'Bogura',
      'Brahmanbaria', 'Chandpur', 'Chapai Nawabganj', 'Chittagong',
      'Chuadanga', 'Comilla', "Cox's Bazar", 'Dhaka', 'Dinajpur', 'Faridpur',
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
      ).timeout(const Duration(seconds: 30));

      print("Assign Officer Response Status: ${response.statusCode}");
      print("Assign Officer Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return AssignedOfficer.fromJson(responseData['data']);
        }
      }
      throw Exception('Failed to assign officer');
    } catch (e) {
      print('Error in assignOfficer: $e');
      throw Exception('Error: $e');
    }
  }

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
      ).timeout(const Duration(seconds: 30));

      print("Update Assigned Officer Response Status: ${response.statusCode}");
      print("Update Assigned Officer Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return AssignedOfficer.fromJson(responseData['data']);
        }
      }
      throw Exception('Failed to update assigned officer');
    } catch (e) {
      print('Error in updateAssignedOfficer: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteAssignedOfficer(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/assigned-officers/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print("Delete Assigned Officer Response Status: ${response.statusCode}");
      print("Delete Assigned Officer Response Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Failed to delete assigned officer');
      }
    } catch (e) {
      print('Error in deleteAssignedOfficer: $e');
      throw Exception('Error: $e');
    }
  }
}