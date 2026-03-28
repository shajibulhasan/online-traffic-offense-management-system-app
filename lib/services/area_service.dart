import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_traffic_offense_management_system/urls/urls.dart';
import '../screens/model/area.dart';

class AreaService {
  final String token;
  static const String baseUrl = Urls.baseUrl; // Replace with your URL

  AreaService({required this.token});

  // Get all areas
  Future<List<Area>> getAllAreas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/areas'),
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
          final List<dynamic> areasData = data['data'] ?? [];
          return areasData.map((json) => Area.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load areas');
        }
      } else {
        throw Exception('Failed to load areas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get thanas by district (for dropdown)
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

  // Get all districts list
  List<String> getAllDistricts() {
    return [
      'Bagerhat', 'Bandarban', 'Barguna', 'Barisal', 'Bhola', 'Bogura',
      'Brahmanbaria', 'Chandpur', 'Chapai Nawabganj', 'Chittagong',
      'Chuadanga', 'Comilla', 'Coxsbazar', 'Dhaka', 'Dinajpur', 'Faridpur',
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

  // Create new area
  Future<Area> createArea(Map<String, dynamic> areaData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/areas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(areaData),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Area.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create area');
        }
      } else {
        throw Exception('Failed to create area: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update area
  Future<Area> updateArea(int id, Map<String, dynamic> areaData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/areas/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(areaData),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            return Area.fromJson(data['data']);
          }
        }
        throw Exception('Failed to update area');
      } else {
        throw Exception('Failed to update area: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete area
  Future<void> deleteArea(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/areas/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(response.body);
      print(response.statusCode);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete area');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}