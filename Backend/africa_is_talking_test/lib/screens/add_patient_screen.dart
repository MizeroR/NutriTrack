import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedLanguage = 'english';
  int _selectedTrimester = 1;
  String? _assignedTo; // Optional field for health worker ID

  bool _isSubmitting = false;

  Future<void> _submitPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final uri = Uri.parse(
      'http://localhost:3000/send-sms',
    ); // Replace if hosted
    final body = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'language': _selectedLanguage,
      'trimester': _selectedTrimester,
      'assignedTo': _assignedTo ?? 'unassigned',
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient registered and SMS sent!')),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Patient')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 12),

              // Language
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(labelText: 'Language'),
                items: ['english', 'kinyarwanda', 'swahili'].map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(lang.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedLanguage = val!),
              ),

              const SizedBox(height: 12),

              // Trimester
              DropdownButtonFormField<int>(
                value: _selectedTrimester,
                decoration: const InputDecoration(labelText: 'Trimester'),
                items: [1, 2, 3].map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text('Trimester $t'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedTrimester = val!),
              ),

              const SizedBox(height: 12),

              // Optional: Assigned Health Worker ID (manual for now)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Assigned Health Worker ID (optional)',
                ),
                onChanged: (val) => _assignedTo = val.trim(),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPatient,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Register Patient'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
