import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';

class PatientsDashboard extends StatefulWidget {
  const PatientsDashboard({super.key});

  @override
  State<PatientsDashboard> createState() => _PatientsDashboardState();
}

class _PatientsDashboardState extends State<PatientsDashboard> {
  final TextEditingController _searchController = TextEditingController();

  final List<Patient> patients = [
    Patient(
      name: 'Joseline',
      age: 23,
      duration: '3 months',
      visits: 4,
      statusColor: Colors.red,
      hasNewMessage: true,
    ),
    Patient(
      name: 'Teta Natalie',
      age: 30,
      duration: '3 months',
      visits: 7,
      statusColor: Colors.yellow,
      hasNewMessage: false,
    ),
    Patient(
      name: 'Marine Uwase',
      age: 35,
      duration: '5 months',
      visits: 5,
      statusColor: Colors.yellow,
      hasNewMessage: false,
    ),
    Patient(
      name: 'Ineza Gloria',
      age: 28,
      duration: '1 month',
      visits: 2,
      statusColor: Colors.green,
      hasNewMessage: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_outline, color: Colors.green),
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
      body: Column(
        children: [
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
                hintText: 'Search (${patients.length} Patients)',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                border: InputBorder.none,
              ),
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
          itemCount: patients.length,
          itemBuilder: (context, index) {
            return PatientCard(
              patient: patients[index],
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) =>
                //         PatientOverviewScreen(patient: patients[index]),
                //   ),
                // );
              },
            );
          },
        ),
      ),
    );
  }
}
