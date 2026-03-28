class Thana {
  final int id;
  final String division;
  final String district;
  final String thanaName;
  final String contact;
  final String address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Thana({
    required this.id,
    required this.division,
    required this.district,
    required this.thanaName,
    required this.contact,
    required this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory Thana.fromJson(Map<String, dynamic> json) {
    return Thana(
      id: json['id'],
      division: json['division'] ?? '',
      district: json['district'] ?? '',
      thanaName: json['thana_name'] ?? '',
      contact: json['contact'] ?? '',
      address: json['address'] ?? '',
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
      'division': division,
      'district': district,
      'thana_name': thanaName,
      'contact': contact,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}