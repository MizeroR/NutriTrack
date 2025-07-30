import 'package:flutter/material.dart';
import 'package:nutritrack_test/Navigation/nav_logic.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authState = AuthState();
  await authState.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authState),
        ChangeNotifierProvider(create: (_) => NavState()),
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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static void showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OptionsMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriTrack Mama',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
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
            onPressed: () {
              // Action for the FAB
            },
            child: const Icon(Icons.add, size: 30),
          ),
          extendBody: true,
        ),
        '/alert_management': (context) => const AlertManagementScreen(),
      },
    );
  }
}
