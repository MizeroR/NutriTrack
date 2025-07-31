// notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../utils/notification_utils.dart';
import '../widgets/notification_group.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _notificationsFuture = Provider.of<NotificationService>(
        context,
        listen: false,
      ).getNotifications();
    });
  }

  void markAllAsRead() {
    setState(() {
      // In a real implementation, you'd update this on the backend
      _notificationsFuture = _notificationsFuture.then((notifications) {
        return notifications.map((n) {
          n.isRead = true;
          return n;
        }).toList();
      });
    });
  }

  void handleNotificationTap(NotificationModel notification) {
    // Handle different notification types
    switch (notification.type) {
      case NotificationType.alert:
        // Navigate to patient details with alert focus
        Navigator.pushNamed(
          context,
          '/patient_details',
          arguments: {
            'patientId': notification.patientId,
            'highlightAlertId': notification.id,
          },
        );
        break;
      case NotificationType.patientRegistration:
        // Navigate to patient details
        Navigator.pushNamed(
          context,
          '/patient_details',
          arguments: {'phone': notification.metadata?['phone']},
        );
        break;
      case NotificationType.system:
        // Show dialog with message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(notification.title),
            content: Text(notification.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;

      case NotificationType.appointment:
        // Navigate to appointments screen or show appointment details
        Navigator.pushNamed(
          context,
          '/appointment-details',
          arguments: {'appointmentId': notification.appointmentId},
        );
        break;
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.grey[100],
  //     body: SafeArea(
  //       child: Column(
  //         children: [
  //           _buildTopBar(),
  //           const SizedBox(height: 8),
  //           Expanded(
  //             child: RefreshIndicator(
  //               onRefresh: _refreshNotifications,
  //               child: FutureBuilder<List<NotificationModel>>(
  //                 future: _notificationsFuture,
  //                 builder: (context, snapshot) {
  //                   if (snapshot.connectionState == ConnectionState.waiting) {
  //                     return const Center(child: CircularProgressIndicator());
  //                   }
  //                   if (snapshot.hasError) {
  //                     return Center(child: Text('Error: ${snapshot.error}'));
  //                   }
  //                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //                     return const Center(child: Text('No notifications'));
  //                   }

  //                   final grouped = groupNotificationsByDate(snapshot.data!);
  //                   return SingleChildScrollView(
  //                     padding: const EdgeInsets.only(bottom: 24),
  //                     child: Column(
  //                       children: grouped.entries.map((entry) {
  //                         return NotificationGroup(
  //                           groupLabel: entry.key,
  //                           notifications: entry.value,
  //                           onTap: handleNotificationTap,
  //                         );
  //                       }).toList(),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotifications,
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found'));
          }

          final grouped = groupNotificationsByDate(snapshot.data!);
          return RefreshIndicator(
            onRefresh: _refreshNotifications,
            child: ListView(
              children: grouped.entries
                  .map(
                    (entry) => NotificationGroup(
                      groupLabel: entry.key,
                      notifications: entry.value,
                      onTap: _handleNotificationTap,
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (notification.patientId != null) {
      Navigator.pushNamed(
        context,
        '/patient-details',
        arguments: {'patientId': notification.patientId},
      );
    }
  }
}

//   Widget _buildTopBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.pop(context),
//           ),
//           const SizedBox(width: 16),
//           const Expanded(
//             child: Text(
//               "Notifications",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//             ),
//           ),
//           TextButton(
//             onPressed: markAllAsRead,
//             child: const Text(
//               "Mark all",
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF3F8362),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
