import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Navigation/nav_state.dart';

class _NavIcon extends StatelessWidget {
  final int index;
  final IconData icon;
  final bool isActive;

  const _NavIcon({
    required this.index,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final navState = Provider.of<NavState>(context, listen: false);

    return IconButton(
      icon: Icon(
        icon,
        size: 28,
        color: isActive ? const Color(0xFF7BAC73) : Colors.grey[600],
      ),
      onPressed: () {
        navState.setIndex(index);
        // No need for manual navigation - PersistentLayout handles it
      },
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navState = Provider.of<NavState>(context);
    final selectedIndex = navState.selectedIndex;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              index: 0,
              icon: Icons.home_outlined,
              isActive: selectedIndex == 0,
            ),
            _NavIcon(
              index: 1,
              icon: Icons.people_outline,
              isActive: selectedIndex == 1,
            ),
            const SizedBox(width: 48), // Space for FAB
            _NavIcon(
              index: 2,
              icon: Icons.notifications_outlined,
              isActive: selectedIndex == 2,
            ),
            _NavIcon(
              index: 3,
              icon: Icons.person_outline,
              isActive: selectedIndex == 3,
            ),
          ],
        ),
      ),
    );
  }
}
