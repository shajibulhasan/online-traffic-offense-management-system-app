class Officer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String nid;
  final String? district;
  final String? thana;
  final String? areaLead;
  final String? license;
  final String? profileImage;
  final String role;
  final int status; // 0 = pending, 1 = approved
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Officer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nid,
    this.district,
    this.thana,
    this.areaLead,
    this.license,
    this.profileImage,
    required this.role,
    required this.status,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Officer.fromJson(Map<String, dynamic> json) {
    return Officer(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      nid: json['nid']?.toString() ?? '',
      district: json['district'],
      thana: json['thana'],
      areaLead: json['area_lead'],
      license: json['license'],
      profileImage: json['profile_image'],
      role: json['role'] ?? 'officer',
      status: json['status'] ?? 0,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'nid': nid,
      'district': district,
      'thana': thana,
      'area_lead': areaLead,
      'license': license,
      'profile_image': profileImage,
      'role': role,
      'status': status,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to check if officer is approved
  bool get isApproved => status == 1;
  bool get isPending => status == 0;
}