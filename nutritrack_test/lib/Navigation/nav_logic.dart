import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Navigation/nav_state.dart';
import '../widgets/bottom_nav_bar.dart'; // Updated import
import '../screens/home_screen.dart';
import '../screens/settings.dart';
import '../screens/notifications_screen.dart';
import '../Navigation/persistent_layout.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navState = Provider.of<NavState>(context);

    final List<Widget> screens = [
      const HomeScreen(),
      Placeholder(), // Updated to use directly
      const SettingsScreen(),
      const NotificationsScreen(),
    ];

    return PersistentLayout(child: screens[navState.selectedIndex]);
  }
}
