// services/notification_service.dart
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      // Get both alerts and SMS logs
      final alerts = await _getAlerts();
      final registrations = await _getRegistrationNotifications();

      return [...alerts, ...registrations]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<List<NotificationModel>> _getAlerts() async {
    final alertsData = await _apiService.getHealthcareWorkerAlerts();
    return alertsData
        .map(
          (alert) => NotificationModel(
            id: alert['id'],
            title: 'Nutrition Alert',
            message: alert['message'] ?? 'New nutrition alert',
            createdAt: _parseDate(alert['triggeredAt']),
            type: NotificationType.alert,
            patientId: alert['patientId'],
            metadata: {
              'healthcareWorkerId': alert['healthcareWorkerId'],
              'severity': alert['severity'] ?? 'medium',
            },
          ),
        )
        .toList();
  }

  DateTime _parseDate(dynamic date) {
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return DateTime.now();
  }

  Future<List<NotificationModel>> _getRegistrationNotifications() async {
    final smsLogs = await _apiService.getSmsLogs();
    return smsLogs
        .where((log) => log['type'] == 'onboarding')
        .map(
          (log) => NotificationModel(
            id: log['messageSid'],
            title: 'New Patient Registered',
            message: 'Sent onboarding SMS to ${log['phone']}',
            createdAt: log['timestamp'].toDate(),
            type: NotificationType.patientRegistration,
            metadata: {'phone': log['phone'], 'message': log['message']},
          ),
        )
        .toList();
  }
}
