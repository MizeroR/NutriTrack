// models/alert_model.dart
class AlertModel {
  final String id;
  final String patientId;
  final String phone;
  final String message;
  final DateTime triggeredAt;

  AlertModel({
    required this.id,
    required this.patientId,
    required this.phone,
    required this.message,
    required this.triggeredAt,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map, String id) {
    return AlertModel(
      id: id,
      patientId: map['patientId'] ?? '',
      phone: map['phone'] ?? '',
      message: map['message'] ?? '',
      triggeredAt: _parseTimestamp(map['triggeredAt']),
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is Map && timestamp['_seconds'] != null) {
      // If using Firebase Timestamp format
      return DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
    }
    return DateTime.now(); // Fallback
  }
}
