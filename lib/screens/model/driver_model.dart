class DriverModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? nid;
  final String? license;
  final String? profileImage;
  final String role;

  DriverModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.nid,
    this.license,
    this.profileImage,
    required this.role,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    final data = json['data']; // 👈 VERY IMPORTANT

    return DriverModel(
      id: data['id'],
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      nid: data['nid'],
      license: data['license'],
      profileImage: data['profile_image'],
      role: data['role'] ?? '',
    );
  }

  DriverModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? nid,
    String? role,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nid: nid ?? this.nid,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'nid': nid,
      'role': role,
    };
  }
}
