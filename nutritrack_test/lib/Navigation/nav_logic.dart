import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Navigation/nav_state.dart';
import '../widgets/custom_navbar.dart';
import '../screens/home_screen.dart'; // first tab
import '../screens/settings.dart';
import '../screens/notifications_screen.dart';
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

    return Scaffold(
      body: screens[navState.selectedIndex],
      bottomNavigationBar: CustomNavBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF81B56C),
        onPressed: () {
          // Optional FAB action
        },
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
