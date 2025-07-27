import 'package:intl/intl.dart';
import '../models/notification_model.dart';

Map<String, List<NotificationModel>> groupNotificationsByDate(
  List<NotificationModel> notifications,
) {
  final Map<String, List<NotificationModel>> grouped = {};

  for (var notification in notifications) {
    final DateTime now = DateTime.now();
    final DateTime created = notification.createdAt;
    String label;

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notifDate = DateTime(created.year, created.month, created.day);

    if (notifDate == today) {
      label = 'Today';
    } else if (notifDate == yesterday) {
      label = 'Yesterday';
    } else {
      label = DateFormat('d MMMM').format(created); // e.g., '15 April'
    }

    if (!grouped.containsKey(label)) {
      grouped[label] = [];
    }

    grouped[label]!.add(notification);
  }

  return grouped;
}
