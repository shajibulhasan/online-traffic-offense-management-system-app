class AssignedOfficer {
  final int id;
  final String name;
  final String email;
  final String district;
  final String thana;
  final String areaLead;
  final int officerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AssignedOfficer({
    required this.id,
    required this.name,
    required this.email,
    required this.district,
    required this.thana,
    required this.areaLead,
    required this.officerId,
    this.createdAt,
    this.updatedAt,
  });

  factory AssignedOfficer.fromJson(Map<String, dynamic> json) {
    return AssignedOfficer(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      district: json['district'] ?? '',
      thana: json['thana'] ?? '',
      areaLead: json['area_lead'] ?? '',
      officerId: json['officer_id'] ?? 0,
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
      'district': district,
      'thana': thana,
      'area_lead': areaLead,
      'officer_id': officerId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}