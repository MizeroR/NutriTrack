import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

// class PersistentLayout extends StatelessWidget {
//   final Widget child;

//   const PersistentLayout({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     // Check if the current screen is PatientsDashboard
//     final bool isPatientsDashboard =
//         ModalRoute.of(context)?.settings.name == '/patients_dashboard';

//     return Scaffold(
//       body: child,
//       bottomNavigationBar: const CustomBottomNavBar(),
//       // Only show the centered FAB if NOT on PatientsDashboard
//       floatingActionButton: isPatientsDashboard
//           ? null // Hide FAB if on PatientsDashboard
//           : FloatingActionButton(
//               heroTag: 'persistent_fab',
//               backgroundColor: const Color(0xFF7BAC73),
//               onPressed: () {},
//               child: const Icon(Icons.add, size: 30),
//             ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }

class PersistentLayout extends StatelessWidget {
  final Widget child;

  const PersistentLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final isFullScreen =
        route?.settings.name == '/patients_dashboard' ||
        route?.settings.name == '/reports_analytics' ||
        route?.settings.name == '/alert_management';

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: isFullScreen ? null : const CustomBottomNavBar(),
      floatingActionButton: isFullScreen
          ? null
          : FloatingActionButton(
              heroTag: UniqueKey().toString(), // Dynamic unique tag
              backgroundColor: const Color(0xFF7BAC73),
              onPressed: () {},
              child: const Icon(Icons.add, size: 30),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
