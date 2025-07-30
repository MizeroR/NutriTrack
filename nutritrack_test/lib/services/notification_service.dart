// services/notification_service.dart
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      // Get all types of notifications
      final alerts = await _getAlerts();
      final registrations = await _getRegistrationNotifications();
      final appointments = await _getAppointmentNotifications();

      return [...alerts, ...registrations, ...appointments]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<List<NotificationModel>> _getAlerts() async {
    final alertsData = await _apiService.getHealthcareWorkerAlerts();
    return alertsData.map((alert) {
      return NotificationModel(
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
      );
    }).toList();
  }

  Future<List<NotificationModel>> _getAppointmentNotifications() async {
    final appointmentsData = await _apiService.getNotifications();
    return appointmentsData.where((n) => n['type'] == 'appointment').map((
      appt,
    ) {
      return NotificationModel(
        id: appt['id'],
        title: appt['title'] ?? 'New Appointment',
        message: appt['message'] ?? 'Appointment scheduled',
        createdAt: _parseDate(appt['createdAt']),
        type: NotificationType.appointment,
        patientId: appt['patientId'],
        appointmentId: appt['appointmentId'],
        metadata: {
          'healthcareWorkerId': appt['healthcareWorkerId'],
          'doctorName': appt['doctorName'],
          'condition': appt['condition'],
        },
      );
    }).toList();
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
            createdAt: _parseDate(log['timestamp']),
            type: NotificationType.patientRegistration,
            metadata: {'phone': log['phone'], 'message': log['message']},
          ),
        )
        .toList();
  }

  DateTime _parseDate(dynamic date) {
    try {
      if (date is String) {
        return DateTime.parse(date);
      } else if (date is Map) {
        if (date['_seconds'] != null) {
          return DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);
        } else if (date['timestamp'] != null) {
          return date['timestamp'].toDate();
        }
      }
      return DateTime.now();
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }
}
