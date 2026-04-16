// models/offense.dart
import 'package:intl/intl.dart';

class Offense {
  final int id;
  final int driverId;
  final int officerId;
  final String thanaName;
  final String offenseType;
  final String detailsOffense;
  final String fine;
  final String point;
  final String? transactionId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String driverName;
  final String officerName;

  Offense({
    required this.id,
    required this.driverId,
    required this.officerId,
    required this.thanaName,
    required this.offenseType,
    required this.detailsOffense,
    required this.fine,
    required this.point,
    this.transactionId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.driverName,
    required this.officerName,
  });

  factory Offense.fromJson(Map<String, dynamic> json) {
    return Offense(
      id: json['id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      officerId: json['officer_id'] ?? 0,
      thanaName: json['thana_name'] ?? 'N/A',
      offenseType: json['offense_type'] ?? 'N/A',
      detailsOffense: json['details_offense'] ?? 'N/A',
      fine: json['fine']?.toString() ?? '0',
      point: json['point']?.toString() ?? '0',
      transactionId: json['transaction_id'],
      status: json['status'] ?? 'unknown',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      driverName: json['driver_name'] ?? 'Unknown',
      officerName: json['officer_name'] ?? 'Unknown',
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    try {
      // Try parsing as DateTime
      if (dateValue is DateTime) return dateValue;

      // Try parsing string
      String dateString = dateValue.toString();
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        // Try parsing with specific format
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateValue.toString());
      } catch (e) {
        return DateTime.now();
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'officer_id': officerId,
      'thana_name': thanaName,
      'offense_type': offenseType,
      'details_offense': detailsOffense,
      'fine': fine,
      'point': point,
      'transaction_id': transactionId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'driver_name': driverName,
      'officer_name': officerName,
    };
  }
}