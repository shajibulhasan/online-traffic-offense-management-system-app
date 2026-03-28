class Area {
  final int id;
  final String district;
  final String thanaName;
  final String areaName;
  final String detailsArea;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Area({
    required this.id,
    required this.district,
    required this.thanaName,
    required this.areaName,
    required this.detailsArea,
    this.createdAt,
    this.updatedAt,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      district: json['district'] ?? '',
      thanaName: json['thana_name'] ?? '',
      areaName: json['area_name'] ?? '',
      detailsArea: json['details_area'] ?? '',
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
      'district': district,
      'thana_name': thanaName,
      'area_name': areaName,
      'details_area': detailsArea,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}