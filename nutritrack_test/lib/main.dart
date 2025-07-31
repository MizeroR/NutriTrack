import 'package:flutter/material.dart';
import 'package:nutritrack_test/Navigation/nav_logic.dart';
import 'package:nutritrack_test/widgets/doctor_options.dart';
import 'package:provider/provider.dart';
import 'state/auth_state.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_wrapper.dart';
import 'screens/signup_page.dart';
import 'Navigation/nav_state.dart';
import 'screens/patients_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:nutritrack_test/services/api_service.dart';
import 'package:nutritrack_test/services/notification_service.dart';
import 'screens/reports_analytics_screen.dart';
import 'screens/alert_management.dart';
import '../widgets/options_menu_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/settings_service.dart';
// import 'screens/reports_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authState = AuthState();
  await authState.init();
  final settingsService = SettingsService();
  final isDarkMode = await settingsService.isDarkMode();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authState),
        ChangeNotifierProvider(create: (_) => NavState()),
        Provider.value(value: settingsService),
        ProxyProvider<AuthState, ApiService>(
          update: (context, authState, _) {
            final hcwId = authState.currentUserData?['healthcareId'];
            print('Creating ApiService with healthcareWorkerId: $hcwId');
            return ApiService(healthcareWorkerId: hcwId);
          },
        ),
        ProxyProvider<ApiService, NotificationService>(
          update: (context, apiService, _) => NotificationService(apiService),
        ),
      ],
      child: MyApp(isDarkMode: isDarkMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  static void showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OptionsMenuSheet(),
    );
  }

  static void showAppointmentForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OptionsMenuAppointment(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriTrack Mama',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/wrapper': (context) => const AuthWrapper(),
        '/home': (context) => const MainScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/patients_dashboard': (context) => Scaffold(
          body: const PatientsDashboard(),
          floatingActionButton: FloatingActionButton(
            heroTag: 'add_patient_fab',
            backgroundColor: Colors.green.shade700,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: () => showOptionsMenu(context),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          extendBody: true,
        ),
        '/reports_analytics': (context) => Scaffold(
          body: const ReportsAnalyticsScreen(),
          floatingActionButton: FloatingActionButton(
            heroTag: 'reports_analytics_fab',
            backgroundColor: const Color(0xFF7BAC73),
            onPressed: () => showAppointmentForm(context),
            child: const Icon(Icons.add, size: 30),
          ),
          extendBody: true,
        ),
        '/alert_management': (context) => const AlertManagementScreen(),
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      brightness: Brightness.light,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.grey[900],
      cardColor: Colors.grey[800],
    );
  }
}
