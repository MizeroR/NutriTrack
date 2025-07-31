import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_state.dart';
import '../services/api_service.dart';

class AddAppointmentFormDialog extends StatefulWidget {
  const AddAppointmentFormDialog({super.key});
  @override
  State<AddAppointmentFormDialog> createState() =>
      _AddAppointmentFormDialogState();
}

class _AddAppointmentFormDialogState extends State<AddAppointmentFormDialog> {
  final _appointmentDateController = TextEditingController();
  final _conditionController = TextEditingController();
  String? _selectedDoctor;
  String? _selectedPatient;
  DateTime? _selectedDateTime;
  List<dynamic> _patientOptions = [];
  bool _isLoadingPatients = true;

  // List of doctors (example)
  final List<String> _doctorOptions = [
    'Dr. Jane Doe',
    'Dr. John Smith',
    'Dr. Emily Brown',
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final patients = await apiService.getAssignedPatients();
      setState(() {
        _patientOptions = patients;
        _isLoadingPatients = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPatients = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load patients: ${e.toString()}')),
        );
      }
    }
  }

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
                    'Add New Appointment',
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
                    Icons.event_outlined,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Appointment Details (Required)',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Patient Name Field - Now a dropdown
              _buildPatientDropdown(),
              const SizedBox(height: 16),
              // Appointment Date and Time Field
              _buildFormField(
                label: 'Appointment Date & Time',
                controller: _appointmentDateController,
                prefixIcon: Icons.calendar_today_outlined,
                hintText: 'Select date and time',
                readOnly: true,
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        _selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        _appointmentDateController.text = _selectedDateTime!
                            .toLocal()
                            .toString();
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Doctor Field
              _buildFormField(
                label: 'Doctor',
                prefixIcon: Icons.account_box_outlined,
                hintText: 'Select doctor',
                readOnly: true,
                suffixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDoctor,
                    items: _doctorOptions
                        .map(
                          (doctor) => DropdownMenuItem(
                            value: doctor,
                            child: Text(doctor),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedDoctor = val),
                    hint: const Text('Select doctor'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Condition Field
              _buildFormField(
                label: 'Condition',
                controller: _conditionController,
                prefixIcon: Icons.medical_services_outlined,
                hintText: 'Enter condition or reason',
              ),
              const SizedBox(height: 32),
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

  Widget _buildPatientDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patient',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: _selectedPatient,
              isExpanded: true,
              underline: const SizedBox(),
              hint: _isLoadingPatients
                  ? const Text('Loading patients...')
                  : const Text('Select patient'),
              items: _patientOptions.map((patient) {
                return DropdownMenuItem<String>(
                  value: patient['id'],
                  child: Text(patient['name'] ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPatient = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_selectedPatient == null ||
        _appointmentDateController.text.isEmpty ||
        _selectedDoctor == null ||
        _conditionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final authState = Provider.of<AuthState>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      // Find the selected patient's name
      final selectedPatient = _patientOptions.firstWhere(
        (patient) => patient['id'] == _selectedPatient,
        orElse: () => {'name': 'Unknown'},
      );

      final appointmentData = {
        'patientName': selectedPatient['name'],
        'patientId': _selectedPatient,
        'appointmentDateTime': _selectedDateTime?.toUtc().toIso8601String(),
        'doctorName': _selectedDoctor!,
        'condition': _conditionController.text,
        'assignedTo': authState.currentUserData?['healthcareId'],
      };

      print('Submitting appointment data: $appointmentData'); // Debug log

      await apiService.registerAppointment(appointmentData);
      if (mounted) {
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment registered successfully')),
        );
      }
    } catch (e) {
      print('Error creating appointment: $e'); // More detailed error logging
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
}
