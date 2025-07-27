import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Navigation/nav_state.dart';
import '../widgets/custom_navbar.dart';

class PersistentLayout extends StatelessWidget {
  final Widget child;

  const PersistentLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const CustomNavBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF81B56C),
        onPressed: () {},
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
