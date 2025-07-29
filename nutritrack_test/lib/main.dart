import 'package:flutter/material.dart';
import 'package:nutritrack_test/Navigation/nav_logic.dart';
import 'package:provider/provider.dart';
import 'state/auth_state.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_wrapper.dart';
import 'screens/signup_page.dart';
import 'Navigation/nav_state.dart';
import 'screens/patients_dashboard.dart';
import 'screens/reports_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:nutritrack_test/services/api_service.dart';
import 'package:nutritrack_test/services/notification_service.dart';
import '../navigation/persistent_layout.dart';

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
        '/home': (context) => const PersistentLayout(child: MainScreen()),
        '/signup': (context) => const SignUpScreen(),
        '/patients_dashboard': (context) =>
            const PersistentLayout(child: PatientsDashboard()),
        '/reports_dashboard': (context) =>
            const PersistentLayout(child: ReportsAnalyticsScreen()),
      },
    );
  }
}
