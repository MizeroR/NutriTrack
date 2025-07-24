import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Navigation/nav_state.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavIcon(
                    index: 0,
                    selectedIndex: selectedIndex,
                    iconPath: 'assets/images/icons/Home.png',
                  ),
                  _NavIcon(
                    index: 1,
                    selectedIndex: selectedIndex,
                    iconPath: 'assets/images/icons/Call.png',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
            // Right side
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavIcon(
                    index: 2,
                    selectedIndex: selectedIndex,
                    iconPath: 'assets/images/icons/Person.png',
                  ),
                  _NavIcon(
                    index: 3,
                    selectedIndex: selectedIndex,
                    iconPath: 'assets/images/icons/Notification.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String iconPath;

  const _NavIcon({
    required this.index,
    required this.selectedIndex,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final navState = Provider.of<NavState>(context, listen: false);
    final isActive = index == selectedIndex;

    return GestureDetector(
      onTap: () {
        navState.setIndex(index);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF81B56C).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            height: 22,
            fit: BoxFit.contain,
            color: isActive ? const Color(0xFF81B56C) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
