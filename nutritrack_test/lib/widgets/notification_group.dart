import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'notification_card.dart';

class NotificationGroup extends StatelessWidget {
  final String groupLabel;
  final List<NotificationModel> notifications;
  final void Function(NotificationModel)? onTap;

  const NotificationGroup({
    Key? key,
    required this.groupLabel,
    required this.notifications,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            groupLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...notifications.map(
          (notification) => NotificationCard(
            notification: notification,
            onTap: () => onTap?.call(notification),
          ),
        ),
      ],
    );
  }
}
