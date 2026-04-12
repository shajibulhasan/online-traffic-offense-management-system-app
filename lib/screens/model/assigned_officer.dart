class AssignedOfficer {
  final int id;
  final int officerId;
  final String name;
  final String email;
  final String district;
  final String thana;
  final String areaLead;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AssignedOfficer({
    required this.id,
    required this.officerId,
    required this.name,
    required this.email,
    required this.district,
    required this.thana,
    required this.areaLead,
    this.createdAt,
    this.updatedAt,
  });

  factory AssignedOfficer.fromJson(Map<String, dynamic> json) {
    return AssignedOfficer(
      id: json['id'] ?? 0,
      officerId: json['officer_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      thana: json['thana']?.toString() ?? '',
      areaLead: json['area_lead']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'officer_id': officerId,
      'name': name,
      'email': email,
      'district': district,
      'thana': thana,
      'area_lead': areaLead,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}