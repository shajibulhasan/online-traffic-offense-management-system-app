class OffenseModel {
  final int? id;
  final String offenseType;
  final String detailsOffense;
  final int fine;
  final int point;
  final int driverId;
  final String thana;
  final String officerName;
  final int officerId;
  final DateTime? createdAt;
  final String? status;
  final String? transactionId;

  OffenseModel({
    this.id,
    required this.offenseType,
    required this.detailsOffense,
    required this.fine,
    required this.point,
    required this.driverId,
    required this.thana,
    required this.officerName,
    required this.officerId,
    this.createdAt,
    this.status,
    this.transactionId,
  });

  factory OffenseModel.fromJson(Map<String, dynamic> json) {
    return OffenseModel(
      id: json['id'],
      offenseType: json['offense_type'] ?? '',
      detailsOffense: json['details_offense'] ?? '',
      fine: int.tryParse(json['fine']?.toString() ?? '0') ?? 0,
      point: int.tryParse(json['point']?.toString() ?? '0') ?? 0,
      driverId: json['driver_id'] ?? 0,
      thana: json['thana'] ?? '',
      officerName: json['officer_name'] ?? '',
      officerId: json['officer_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      status: json['status'],
      transactionId: json['transaction_id']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offense_type': offenseType,
      'details_offense': detailsOffense,
      'fine': fine,
      'point': point,
      'driver_id': driverId,
      'thana': thana,
      'officer_name': officerName,
      'officer_id' : officerId,
      'status': status,
      'transaction_id': transactionId,
    };
  }
}