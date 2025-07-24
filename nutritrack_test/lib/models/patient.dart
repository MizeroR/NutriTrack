import 'package:flutter/material.dart';

class Patient {
  final String name;
  final int age;
  final String duration;
  final int visits;
  final Color statusColor;
  final bool hasNewMessage;

  Patient({
    required this.name,
    required this.age,
    required this.duration,
    required this.visits,
    required this.statusColor,
    required this.hasNewMessage,
  });
}
