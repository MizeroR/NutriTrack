import 'package:flutter/material.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  String _selectedCategory = 'Gynecologist';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Custom top bar with arrow icon and correct padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF7BAC73),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reports and analytics',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Category section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category cards
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildCategoryCard(
                    'Gynecologist',
                    Icons.medical_services,
                    selected: _selectedCategory == 'Gynecologist',
                    onTap: () =>
                        setState(() => _selectedCategory = 'Gynecologist'),
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryCard(
                    'Medicine',
                    Icons.medication,
                    selected: _selectedCategory == 'Medicine',
                    onTap: () => setState(() => _selectedCategory = 'Medicine'),
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryCard(
                    'Psychologist',
                    Icons.psychology,
                    selected: _selectedCategory == 'Psychologist',
                    onTap: () =>
                        setState(() => _selectedCategory = 'Psychologist'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // All Doctors section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'All Doctors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Dynamic content based on selected category
            Expanded(child: _buildCategoryContent()),
          ],
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.home_outlined, color: Colors.grey[600], size: 28),
                Icon(Icons.phone_outlined, color: Colors.grey[600], size: 28),
                SizedBox(width: 56), // Space for FAB
                Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey[600],
                  size: 28,
                ),
                Icon(Icons.person_outline, color: Colors.grey[600], size: 28),
              ],
            ),
            // Plus button with correct color and no shadow, not a circle
            Positioned(
              bottom: 12,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFF7BAC73),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
            // Only the green underline at the bottom, no extra horizontal divider
            Positioned(
              bottom: 0,
              left: MediaQuery.of(context).size.width / 2 - 28,
              child: Container(
                width: 56,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFF7BAC73),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon, {
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Color(0xFF7BAC73) : Colors.black,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: selected ? Color(0xFF7BAC73) : Colors.black,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? Color(0xFF7BAC73) : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(
    String name,
    String specialty,
    String time,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Color(0xFF7BAC73).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 32, color: Color(0xFF7BAC73)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent() {
    switch (_selectedCategory) {
      case 'Gynecologist':
        return _buildGynecologistContent();
      case 'Medicine':
        return _buildMedicineContent();
      case 'Psychologist':
        return _buildPsychologistContent();
      default:
        return _buildGynecologistContent();
    }
  }

  Widget _buildGynecologistContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildDoctorCard(
          'Dr. Sarah Johnson',
          'Gynecologist Specialist',
          '08.00am - 03.00pm',
          Icons.person,
        ),
        const SizedBox(height: 16),
        _buildDoctorCard(
          'Dr. Maria Rodriguez',
          'Maternal-Fetal Medicine',
          '09.00am - 04.00pm',
          Icons.person,
        ),
      ],
    );
  }

  Widget _buildMedicineContent() {
    final medicines = [
      {
        'name': 'Prenatal Vitamins',
        'description': 'Essential vitamins for pregnancy',
        'dosage': 'Once daily',
      },
      {
        'name': 'Folic Acid',
        'description': 'Prevents birth defects',
        'dosage': '400-800 mcg daily',
      },
      {
        'name': 'Iron Supplements',
        'description': 'Prevents anemia during pregnancy',
        'dosage': '27mg daily',
      },
      {
        'name': 'Calcium',
        'description': 'Supports bone development',
        'dosage': '1000mg daily',
      },
      {
        'name': 'DHA Omega-3',
        'description': 'Brain development support',
        'dosage': '200-300mg daily',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final medicine = medicines[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.04),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFF7BAC73).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.medication,
                  size: 32,
                  color: Color(0xFF7BAC73),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine['name']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine['description']!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          medicine['dosage']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPsychologistContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.psychology_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No Psychologists Added',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add mental health professionals to support your patients',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddPsychologistDialog,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Psychologist'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7BAC73),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPsychologistDialog() {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final scheduleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Psychologist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'Role/Specialization',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: scheduleController,
              decoration: const InputDecoration(
                labelText: 'Schedule (e.g., 09:00am - 05:00pm)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${nameController.text} added successfully'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7BAC73)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
