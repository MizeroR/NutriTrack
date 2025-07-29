import 'package:flutter/material.dart';
import '../widgets/category_card.dart';
import '../widgets/doctor_card.dart';
import '../widgets/bottom_nav_bar.dart';

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
            _buildTopBar(),
            const SizedBox(height: 16),
            _buildCategorySection(),
            const SizedBox(height: 24),
            _buildAllDoctorsSection(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF7BAC73),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Reports and analytics',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
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
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: const [
              CategoryCard(
                title: 'Gynecologist',
                icon: Icons.female, // Using Flutter's built-in icons
                selected: true,
              ),
              SizedBox(width: 16),
              CategoryCard(title: 'Medicine', icon: Icons.medical_services),
              SizedBox(width: 16),
              CategoryCard(title: 'Psychologist', icon: Icons.psychology),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllDoctorsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                DoctorCard(
                  name: 'Ashlynn Caizoni',
                  specialty: 'Gynecologist Specialist',
                  time: '08.00am - 03.00pm',
                  profileColor: Color(0xFF7BAC73),
                ),
                SizedBox(height: 16),
                DoctorCard(
                  name: 'John Smith',
                  specialty: 'Medicine Specialist',
                  time: '09.00am - 04.00pm',
                  profileColor: Color(0xFF5D9CEC),
                ),
                SizedBox(height: 16),
                DoctorCard(
                  name: 'Sarah Johnson',
                  specialty: 'Psychologist',
                  time: '10.00am - 05.00pm',
                  profileColor: Color(0xFFED5565),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
