// notification_model.dart
enum NotificationType { alert, patientRegistration, system, appointment }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? appointmentId;
  final DateTime createdAt;
  final NotificationType type;
  bool isRead;
  final String? patientId; // For linking to patient details
  final Map<String, dynamic>? metadata; // Additional data

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.appointmentId,
    this.patientId,
    this.metadata,
  });

  // Helper getter for icon
  String get iconType {
    switch (type) {
      case NotificationType.alert:
        return 'warning';
      case NotificationType.patientRegistration:
        return 'person_add';
      case NotificationType.system:
        return 'info';
      case NotificationType.appointment:
        return 'event';
    }
  }
}
