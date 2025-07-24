import 'package:flutter/material.dart';
import 'screens/add_patient_screen.dart';
import 'screens/assigned_patients_screen.dart';
import 'screens/patient_nutrition_screen.dart';

void main() {
  runApp(const NutriTrackApp());
}

class NutriTrackApp extends StatelessWidget {
  const NutriTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriTrack MAMA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      initialRoute: '/',
      routes: {
        '/': (context) => const AssignedPatientsScreen(),
        '/add': (context) => const AddPatientScreen(),
        '/nutrition': (context) => const PatientNutritionScreen(),
        // Add route for PatientNutritionScreen later
      },
    );
  }
}
