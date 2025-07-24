import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/config.dart';

class PatientNutritionScreen extends StatefulWidget {
  const PatientNutritionScreen({super.key});

  @override
  State<PatientNutritionScreen> createState() => _PatientNutritionScreenState();
}

class _PatientNutritionScreenState extends State<PatientNutritionScreen> {
  Map<String, dynamic>? summary;
  bool isLoading = true;
  bool isSending = false;

  late String patientId;
  late String patientName;

  @override
  void didChangeDependencies() {
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments;

    if (args == null || args is! Map) {
      print("❌ No arguments passed to PatientNutritionScreen");
      return; // or show an error UI if necessary
    }

    patientId = args['id'];
    patientName = args['name'];
    fetchSummary();
    super.didChangeDependencies();
  }

  Future<void> fetchSummary() async {
    setState(() => isLoading = true);
    final url = Uri.parse("$baseUrl/nutrition-summary/$patientId?days=7");

    try {
      final res = await http.get(
        url,
        headers: {
          'ngrok-skip-browser-warning': 'true', // ✅ FIX!
        },
      );

      if (res.statusCode == 200) {
        setState(() {
          summary = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        print('❌ Failed to load summary');
      }
    } catch (e) {
      print('❌ Error fetching summary: $e');
    }
  }

  Future<void> sendAlert() async {
    setState(() => isSending = true);
    final url = Uri.parse('$baseUrl/send-alert');
    final body = jsonEncode({'patientId': patientId});

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true', // ✅ FIX!
        },
        body: body,
      );

      final msg = jsonDecode(res.body)['message'];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg ?? 'Alert sent!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send alert: $e")));
    } finally {
      setState(() => isSending = false);
    }
  }

  Widget buildBar(String label, int percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $percent%'),
        SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent / 100,
          minHeight: 10,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation(color),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nutrition - $patientName')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrient Coverage (7 days)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  buildBar(
                    "Calories",
                    summary!['percentMet']['calories'],
                    Colors.orange,
                  ),
                  buildBar(
                    "Protein",
                    summary!['percentMet']['protein'],
                    Colors.green,
                  ),
                  buildBar("Iron", summary!['percentMet']['iron'], Colors.red),
                  const SizedBox(height: 16),

                  if ((summary!['flags'] as List).isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "⚠️ Alerts:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          for (var flag in summary!['flags'])
                            Text(
                              "- $flag",
                              style: TextStyle(color: Colors.red[900]),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(
                    "Recommendations:",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  for (var r in summary!['recommendations'])
                    Text("• $r", style: TextStyle(color: Colors.black87)),
                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: isSending ? null : sendAlert,
                    icon: const Icon(Icons.warning_amber),
                    label: isSending
                        ? const CircularProgressIndicator()
                        : const Text("Send SMS Alert"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
