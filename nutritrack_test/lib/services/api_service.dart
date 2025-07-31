import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition_summary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient.dart';

class ApiService {
  static const String _baseUrl = 'https://nutritrack-ln4l.onrender.com';
  // static const String _baseUrl = 'https://3b027c08e174.ngrok-free.app';

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
      'ngrok-skip-browser-warning': 'true',
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

  // In api_service.dart
  Future<List<dynamic>> getNotifications() async {
    if (healthcareWorkerId == null) {
      throw Exception('No healthcare worker ID');
    }

    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/notifications?healthcareWorkerId=$healthcareWorkerId',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notifications');
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

  Future<void> updatePatient(Patient patient) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/patients/${patient.id}'),
      headers: headers,
      body: jsonEncode({
        'name': patient.name,
        'age': patient.age,
        'phone': patient.phone,
        'trimester': patient.trimester,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update patient: ${response.body}');
    }
  }

  Future<void> deletePatient(String patientId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/patients/$patientId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete patient: ${response.body}');
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

  Future<void> registerAppointment(Map<String, dynamic> appointmentData) async {
    final headers = await _getHeaders();
    print('Sending appointment data: $appointmentData');
    final response = await http.post(
      Uri.parse('$_baseUrl/register-appointment'),
      headers: {
        ...headers,
        'Content-Type': 'application/json', // Ensure content-type is set
      },
      body: jsonEncode(appointmentData),
    );

    if (response.statusCode != 201) {
      print('Appointment creation failed: ${response.body}');
      throw Exception('Failed to register appointment: ${response.body}');
    }
  }

  Future<List<dynamic>> getHealthcareWorkerAppointments() async {
    if (healthcareWorkerId == null) {
      throw Exception('No healthcare worker ID');
    }

    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/appointments?healthcareWorkerId=$healthcareWorkerId',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load appointments');
    }
  }

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

  // Get nutrition summary for a patient
  Future<NutritionSummary> getNutritionSummary(
    String patientId, {
    int days = 7,
  }) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/nutrition-summary/$patientId?days=$days'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return NutritionSummary.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load nutrition summary');
    }
  }

  Future<void> sendNutritionAlert(String patientId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/send-alert'),
      headers: headers,
      body: jsonEncode({'patientId': patientId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send alert');
    }
  }

  // In api_service.dart
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final headers = await _getHeaders();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          ...headers,
          'Content-Type': 'application/json', // Required for your backend
        },
        body: jsonEncode(body), // Matches your backend's JSON expectation
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
}
