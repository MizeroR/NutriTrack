// screens/assigned_patients_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/config.dart';

class AssignedPatientsScreen extends StatefulWidget {
  const AssignedPatientsScreen({super.key});

  @override
  State<AssignedPatientsScreen> createState() => _AssignedPatientsScreenState();
}

class _AssignedPatientsScreenState extends State<AssignedPatientsScreen> {
  List<dynamic> patients = [];
  final String healthWorkerId = "HW001"; // Simulated login

  @override
  void initState() {
    super.initState();
    fetchAssignedPatients();
  }

  Future<void> fetchAssignedPatients() async {
    final uri = Uri.parse("$baseUrl/patients?assignedTo=$healthWorkerId");
    try {
      final res = await http.get(
        uri,
        headers: {
          'ngrok-skip-browser-warning': 'true', // 👈 Skip ngrok browser warning
        },
      );

      // 🧪 DEBUG PRINTS
      print("📡 Status Code: ${res.statusCode}");
      print("📡 Response Body: ${res.body}");

      if (res.statusCode == 200) {
        setState(() => patients = jsonDecode(res.body));
      } else {
        print('❌ Failed to load patients: ${res.body}');
      }
    } catch (e) {
      print('❌ Network error: $e');
    }
  }

  void openPatientScreen(String patientId, String patientName) {
    Navigator.pushNamed(
      context,
      '/nutrition',
      arguments: {'id': patientId, 'name': patientName},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Assigned Patients')),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return ListTile(
            title: Text(patient['name']),
            subtitle: Text("Trimester ${patient['trimester']}"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => openPatientScreen(patient['id'], patient['name']),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
