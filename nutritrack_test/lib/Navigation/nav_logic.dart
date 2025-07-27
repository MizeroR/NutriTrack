import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Navigation/nav_state.dart';
import '../widgets/custom_navbar.dart';
import '../screens/home_screen.dart'; // first tab
import '../screens/settings.dart';
import '../screens/notifications_screen.dart';
import '../Navigation/persistent_layout.dart';
// import other future screens here as needed

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navState = Provider.of<NavState>(context);

    final List<Widget> screens = [
      HomeScreen(),
      Placeholder(),
      SettingsScreen(),
      NotificationsScreen(),
    ];

    return PersistentLayout(child: screens[navState.selectedIndex]);
  }
}
