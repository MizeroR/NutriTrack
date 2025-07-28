// notification_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  String _formatTimeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}M';
    if (diff.inHours < 24) return '${diff.inHours}H';
    return DateFormat('MMM d').format(date);
  }

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'person_add':
        return Icons.person_add_alt_1;
      case 'calendar':
        return Icons.calendar_today;
      case 'notes':
        return Icons.note;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String iconType) {
    switch (iconType) {
      case 'warning':
        return const Color(0xFFF44336); // Red for alerts
      case 'person_add':
        return const Color(0xFF4CAF50); // Green for registrations
      default:
        return const Color(0xFF2196F3); // Blue for others
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : const Color(0xFFE6F3ED).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!notification.isRead)
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getIconColor(notification.iconType).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(notification.iconType),
                color: _getIconColor(notification.iconType),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notification.metadata?['phone'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notification.metadata!['phone'],
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTimeAgo(notification.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
