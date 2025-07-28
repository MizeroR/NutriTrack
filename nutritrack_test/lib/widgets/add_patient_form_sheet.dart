import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_state.dart';
import '../services/api_service.dart';

class AddPatientFormDialog extends StatefulWidget {
  const AddPatientFormDialog({super.key});

  @override
  State<AddPatientFormDialog> createState() => _AddPatientFormDialogState();
}

class _AddPatientFormDialogState extends State<AddPatientFormDialog> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _selectedTrimester;
  String? _selectedLanguage;
  String? _selectedAge;
  final List<String> _ageOptions = List.generate(100, (i) => '${i + 1}');
  final List<String> _trimesterOptions = ['1', '2', '3'];
  final List<String> _languageOptions = ['english', 'swahili', 'kinyarwanda'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Center(
                  child: Text(
                    'Add New Patient',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Row(
                children: [
                  Icon(
                    Icons.report_outlined,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Medical Report (Required)',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              _buildFormField(
                label: 'Name',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                hintText: 'Enter patient name',
                suffixIcon: _nameController.text.isNotEmpty
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              const SizedBox(height: 16),

              // Mobile Field
              _buildFormField(
                label: 'Mobile',
                controller: _mobileController,
                prefixIcon: Icons.phone_outlined,
                hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Age Field
              _buildFormField(
                label: 'Age',
                prefixIcon: Icons.cake_outlined,
                hintText: 'Select age',
                readOnly: true,
                suffixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAge,
                    items: _ageOptions
                        .map(
                          (age) =>
                              DropdownMenuItem(value: age, child: Text(age)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedAge = val),
                    hint: Text('Select age'),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Language Field
              _buildFormField(
                label: 'Language',
                prefixIcon: Icons.language,
                hintText: 'Select language',
                readOnly: true,
                suffixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: _languageOptions
                        .map(
                          (lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(
                              lang[0].toUpperCase() + lang.substring(1),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedLanguage = val),
                    hint: Text('Select language'),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Trimester Field
              _buildFormField(
                label: 'Trimester',
                prefixIcon: Icons.pregnant_woman,
                hintText: 'Select trimester',
                readOnly: true,
                suffixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTrimester,
                    items: _trimesterOptions
                        .map(
                          (tri) =>
                              DropdownMenuItem(value: tri, child: Text(tri)),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedTrimester = val),
                    hint: Text('Select trimester'),
                  ),
                ),
              ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final phone = _mobileController.text.trim();
    if (!phone.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Phone number must include country code (e.g. +250...)',
          ),
        ),
      );
      return;
    }
    if (_nameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _selectedAge == null ||
        _selectedTrimester == null ||
        _selectedLanguage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final authState = Provider.of<AuthState>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final patientData = {
        'name': _nameController.text,
        'phone': _mobileController.text,
        'age': int.parse(_selectedAge!),
        'trimester': int.parse(_selectedTrimester!),
        'language': _selectedLanguage!,
        'assignedTo': authState.currentUserData?['healthcareId'],
      };

      await apiService.registerPatient(patientData);
      if (mounted) {
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient registered successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}

Widget _buildFormField({
  required String label,
  TextEditingController? controller,
  IconData? prefixIcon,
  String? hintText,
  TextInputType? keyboardType,
  bool readOnly = false,
  Widget? suffixIcon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey.shade600)
              : null,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}
