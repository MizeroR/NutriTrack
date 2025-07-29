import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000';
  final String? healthcareWorkerId;

  ApiService({this.healthcareWorkerId});

  Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Get the Firebase Auth token
    final token = await user.getIdToken();
    print('Current Firebase Token: $token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get patients assigned to this healthcare worker
  Future<List<dynamic>> getAssignedPatients() async {
    if (healthcareWorkerId == null) throw Exception('No healthcare worker ID');

    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/patients?assignedTo=$healthcareWorkerId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Patients API Response: $data'); // Debug log
      return data;
    } else {
      throw Exception('Failed to load patients');
    }
  }

  // Register a new patient and send SMS
  // In api_service.dart
  Future<void> registerPatient(Map<String, dynamic> patientData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/send-sms'),
        headers: headers,
        body: jsonEncode({
          ...patientData,
          'assignedTo': healthcareWorkerId, // Ensure this is included
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to register patient: ${response.body}');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Get nutrition alerts for a patient
  // Future<List<dynamic>> getPatientAlerts(
  //   String patientId, {
  //   int days = 7,
  // }) async {
  //   final headers = await _getHeaders();
  //   final response = await http.get(
  //     Uri.parse('$_baseUrl/alerts?patientId=$patientId&days=$days'),
  //     headers: headers,
  //   );

  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to load alerts');
  //   }
  // }

  Future<List<dynamic>> getHealthcareWorkerAlerts({int days = 7}) async {
    final currentHcwId = healthcareWorkerId;
    if (currentHcwId == null || currentHcwId.isEmpty) {
      print('No healthcareWorkerId available - returning empty list');
      return [];
    }
    try {
      final currentHcwId = healthcareWorkerId;
      if (currentHcwId == null) {
        print('Healthcare Worker ID not available - checking auth state');
        await FirebaseAuth.instance.authStateChanges().first;
        throw Exception('No healthcare worker ID after auth check');
      }

      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$_baseUrl/hcw-alerts?healthcareWorkerId=$currentHcwId&days=$days',
      );

      final response = await http.get(uri, headers: headers);
      print('Alerts API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
        throw Exception('Invalid response format');
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error fetching alerts: $e');
      rethrow;
    }
  }

  // Get all alerts (not patient-specific)
  // Future<List<dynamic>> getAlerts() async {
  //   try {
  //     final headers = await _getHeaders();
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/alerts'),
  //       headers: headers,
  //     );
  //     print('Alerts API Response - Status: ${response.statusCode}');
  //     print('Alerts API Response - Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       throw Exception(
  //         'Failed to load alerts - Status: ${response.statusCode}',
  //       );
  //     }
  //   } catch (e) {
  //     print('Error fetching alerts: $e');
  //     throw Exception('Failed to load alerts: $e');
  //   }
  // }

  // Get SMS logs
  Future<List<dynamic>> getSmsLogs() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/sms-logs'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load SMS logs');
    }
  }

  // Send nutrition alert to patient
  // Future<void> sendNutritionAlert(String patientId) async {
  //   final headers = await _getHeaders();
  //   final response = await http.post(
  //     Uri.parse('$_baseUrl/send-alert'),
  //     headers: headers,
  //     body: jsonEncode({'patientId': patientId}),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to send alert');
  //   }
  // }
}
