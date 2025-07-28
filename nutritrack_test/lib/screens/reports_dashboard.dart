import 'package:flutter/material.dart';

class ReportsAnalyticsScreen extends StatelessWidget {
  const ReportsAnalyticsScreen({super.key});

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
                  Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF7BAC73),
                    size: 20,
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
                    selected: true,
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryCard(
                    'Medicine',
                    Icons.medication,
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryCard(
                    'Psychologist',
                    Icons.psychology,
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
            // Doctor cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDoctorCard(
                    'Ashlynn Caizoni',
                    'Gynecologist Specialist',
                    '08.00am - 03.00pm',
                    Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildDoctorCard(
                    'Ashlynn Caizoni',
                    'Medicine Specialist',
                    '08.00am - 03.00pm',
                    Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildDoctorCard(
                    'Ashlynn Caizoni',
                    'Psychologist',
                    '08.00am - 03.00pm',
                    Icons.person,
                  ),
                ],
              ),
            ),
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
  }) {
    return Container(
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
            Icon(icon, size: 32, color: selected ? Color(0xFF7BAC73) : Colors.black),
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
}
