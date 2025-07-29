import 'package:flutter/material.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final int? visits; // Make nullable
  final String phone;
  final String? duration; // Make nullable
  final String language;
  final int trimester;
  final DateTime createdAt;

  Color statusColor;
  bool hasNewMessage;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    this.visits, // No longer required
    required this.phone,
    this.duration, // No longer required
    required this.language,
    required this.trimester,
    required this.createdAt,
    this.statusColor = Colors.grey, // Default color
    this.hasNewMessage = false, // Default false
  });

  factory Patient.fromFirestore(Map<String, dynamic> data, String id) {
    return Patient(
      id: id,
      name: data['name'] ?? 'Unknown',
      age: (data['age'] is int) ? data['age'] : (int.tryParse(data['age'].toString()) ?? 0),
      visits: data['visits'],
      phone: data['phone'] ?? '',
      duration: data['duration'],
      language: data['language'] ?? 'english',
      trimester: (data['trimester'] is int) ? data['trimester'] : (int.tryParse(data['trimester'].toString()) ?? 1),
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
    );
  }
}
