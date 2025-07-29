import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String time;
  final Color profileColor; // For colored profile alternative

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.time,
    this.profileColor = const Color(0xFF7BAC73),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Option 1: Initials Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: profileColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: profileColor, width: 2),
            ),
            child: Center(
              child: Text(
                name.split(' ').map((n) => n[0]).join(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: profileColor,
                ),
              ),
            ),
          ),

          // Alternative Option 2: Icon Avatar
          /* Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: profileColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.person_outline,
              size: 32,
              color: profileColor,
            ),
          ), */
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
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
