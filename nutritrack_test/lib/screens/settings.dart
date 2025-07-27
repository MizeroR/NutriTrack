import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_state.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              SettingsSection(
                title: 'Profile',
                children: [
                  SettingsItem(
                    icon: Icons.person_outline,
                    title: 'Your Profile',
                    onTap: () => _navigateToProfile(context),
                  ),
                ],
              ),

              // Personal Info Section
              SettingsSection(
                title: 'Personal Info',
                children: [
                  SettingsItem(
                    icon: Icons.history,
                    title: 'History Transaction',
                    onTap: () {},
                  ),
                ],
              ),

              // Security Section
              SettingsSection(
                title: 'Security',
                children: [
                  SettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Change password',
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Forgot password',
                    onTap: () {},
                  ),
                ],
              ),

              // General Section
              SettingsSection(
                title: 'General',
                showDivider: false,
                children: [
                  SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notification',
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icons.language_outlined,
                    title: 'Languages',
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help and Support',
                    onTap: () {},
                  ),
                ],
              ),

              // Logout Button
              // In settings.dart, replace the current logout button with this:

              // Account Section
              SettingsSection(
                title: 'Account',
                showDivider: false,
                children: [
                  SettingsItem(
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: () => _showLogoutDialog(context, authState),
                    showTrailingIcon: false, // Remove the arrow for logout
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    // Replace with your profile screen navigation
    Navigator.pushNamed(context, '/profile');
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthState authState,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authState.logout();
              // Navigate to login screen after logout
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
