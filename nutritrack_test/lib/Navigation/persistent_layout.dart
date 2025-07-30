import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class PersistentLayout extends StatelessWidget {
  final Widget child;

  const PersistentLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Check if the current screen is PatientsDashboard
    final bool isPatientsDashboard =
        ModalRoute.of(context)?.settings.name == '/patients_dashboard';

    return Scaffold(
      body: child,
      bottomNavigationBar: const CustomBottomNavBar(),
      // Only show the centered FAB if NOT on PatientsDashboard
      floatingActionButton: isPatientsDashboard
          ? null // Hide FAB if on PatientsDashboard
          : FloatingActionButton(
              backgroundColor: const Color(0xFF7BAC73),
              onPressed: () {},
              child: const Icon(Icons.add, size: 30),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
