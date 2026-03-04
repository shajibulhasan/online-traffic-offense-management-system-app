// lib/models/driver_model.dart
import 'package:flutter/cupertino.dart';

class DriverModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? nid;
  final String? license;
  final String role;
  final int? totalPoints;
  final String? profileImage;
  final int? status;
  final String? district;
  final String? thana;

  DriverModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.nid,
    this.license,
    required this.role,
    this.totalPoints,
    this.profileImage,
    this.status,
    this.district,
    this.thana,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🔄 Parsing DriverModel from JSON: $json');

    return DriverModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      nid: json['nid']?.toString(),
      license: json['license']?.toString(),
      role: json['role'] ?? 'user',
      totalPoints: json['total_points'],
      profileImage: json['profile_image'],
      status: json['status'],
      district: json['district'],
      thana: json['thana'],
    );
  }

  // Helper method to check if user is driver
  bool get isDriver {
    return role.toLowerCase() == 'driver' ||
        role.toLowerCase() == 'user';  // 'user' role কেও driver হিসেবে ধরা
  }

  // Display role for UI
  String get displayRole {
    if (role.toLowerCase() == 'user') return 'Driver';
    if (role.toLowerCase() == 'driver') return 'Driver';
    if (role.toLowerCase() == 'admin') return 'Admin';
    if (role.toLowerCase() == 'officer') return 'Officer';
    return role;
  }

  DriverModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? nid,
    String? license,
    String? role,
    int? totalPoints,
    String? profileImage,
    int? status,
    String? district,
    String? thana,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nid: nid ?? this.nid,
      license: license ?? this.license,
      role: role ?? this.role,
      totalPoints: totalPoints ?? this.totalPoints,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
      district: district ?? this.district,
      thana: thana ?? this.thana,
    );
  }

  @override
  String toString() {
    return 'DriverModel(id: $id, name: $name, email: $email, role: $role)';
  }
}