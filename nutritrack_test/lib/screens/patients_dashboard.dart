// patients_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';
import '../services/api_service.dart';
import 'patient_overview_screen.dart';

class PatientsDashboard extends StatefulWidget {
  const PatientsDashboard({super.key});

  @override
  State<PatientsDashboard> createState() => _PatientsDashboardState();
}

class _PatientsDashboardState extends State<PatientsDashboard> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Patient>> _patientsFuture;
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _patientsFuture = _fetchPatients();
  }

  Future<List<Patient>> _fetchPatients() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final patientsData = await apiService.getAssignedPatients();

    final patients = patientsData.map<Patient>((patient) {
      return Patient.fromFirestore(patient, patient['id']);
    }).toList();

    // Set default status colors (you can implement your logic here)
    for (var patient in patients) {
      patient.statusColor = _determineStatusColor(patient);
      patient.hasNewMessage = _checkForNewMessages(patient);
    }

    _allPatients = patients;
    _filteredPatients = patients;
    return patients;
  }

  Color _determineStatusColor(Patient patient) {
    // Implement your logic for status colors
    if (patient.trimester == 1) return Colors.red;
    if (patient.trimester == 2) return Colors.yellow;
    return Colors.green;
  }

  bool _checkForNewMessages(Patient patient) {
    // Implement your logic for new messages
    return false; // Placeholder
  }

  void _filterPatients(String query) {
    setState(() {
      _filteredPatients = _allPatients.where((patient) {
        return patient.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Changed from Scaffold
      color: Colors.white,
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Patients Dashboard',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
          ),
          _buildSearchBar(),
          _buildSortBar(),
          const SizedBox(height: 16),
          _buildPatientGrid(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Patients',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                border: InputBorder.none,
              ),
              onChanged: _filterPatients,
            ),
          ),
          const Icon(Icons.tune, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AZ',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Sort by',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientGrid() {
    return FutureBuilder<List<Patient>>(
      future: _patientsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No patients found'));
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                return PatientCard(
                  patient: _filteredPatients[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientOverviewScreen(
                          patient: _filteredPatients[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
