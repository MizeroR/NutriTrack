import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Navigation/nav_state.dart'; // Updated import
import '../screens/home_screen.dart';
import '../screens/settings.dart';
import '../screens/notifications_screen.dart';
import '../Navigation/persistent_layout.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentLayout(
      child: Consumer<NavState>(
        builder: (context, navState, _) {
          final screens = [
            const HomeScreen(), // This should be your patients screen
            const NotificationsScreen(),
            const SettingsScreen(),
          ];
          return screens[navState.selectedIndex];
        },
      ),
    );
  }
}
