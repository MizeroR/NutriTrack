import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_state.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';
import 'login_screen.dart';
import '../services/settings_service.dart';
import '../screens/splash_screen.dart';

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
                    onTap: () => _showProfileDialog(context),
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
                    onTap: () => _showHistoryDialog(context),
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
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  SettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Forgot password',
                    onTap: () => _showForgotPasswordDialog(context),
                  ),
                ],
              ),

              // General Section
              SettingsSection(
                title: 'General',
                showDivider: false,
                children: [
                  // Add this new toggle item
                  Consumer<SettingsService>(
                    builder: (context, settings, child) {
                      return FutureBuilder<bool>(
                        future: settings.isDarkMode(),
                        builder: (context, snapshot) {
                          final isDarkMode = snapshot.data ?? false;
                          return SettingsItem(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            showTrailingIcon: false,
                            onTap: null, // Disable tap, only toggle works
                            trailing: Switch(
                              value: isDarkMode,
                              onChanged: (value) async {
                                final navigator = Navigator.of(context);
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );

                                await settings.setDarkMode(value);

                                navigator.pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const SplashScreen(),
                                  ),
                                  (route) => false,
                                );

                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Dark mode ${value ? 'enabled' : 'disabled'}',
                                    ),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notification',
                    onTap: () => _showNotificationDialog(context),
                  ),
                  SettingsItem(
                    icon: Icons.language_outlined,
                    title: 'Languages',
                    onTap: () => _showLanguageDialog(context),
                  ),
                  SettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help and Support',
                    onTap: () => _showHelpDialog(context),
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

  void _showProfileDialog(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${authState.currentUserData?['name'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Email: ${authState.user?.email ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text(
              'Healthcare ID: ${authState.currentUserData?['healthcareId'] ?? 'N/A'}',
            ),
            const SizedBox(height: 8),
            Text('Role: ${authState.currentUserData?['role'] ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction History'),
        content: const Text('No recent transactions found.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email to reset password:'),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset link sent to your email')),
              );
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Push Notifications'),
                Switch(value: true, onChanged: null),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email Notifications'),
                Switch(value: false, onChanged: null),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SMS Alerts'),
                Switch(value: true, onChanged: null),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: const Text(
          'Current language: English\n\nOnly English is supported at this time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Contact Support: support@nutritrack.com'),
            SizedBox(height: 8),
            Text('• Phone: +1-800-NUTRI-TRACK'),
            SizedBox(height: 8),
            Text('• FAQ: Visit our website'),
            SizedBox(height: 8),
            Text('• App Version: 1.0.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
            onPressed: () {
              Navigator.of(context).pop();
              authState.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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
