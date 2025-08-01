import 'package:flutter/material.dart';
import '../widgets/home_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(child: Image.asset('assets/images/logo.png', height: 50)),
          const SizedBox(height: 30),
          HomeCard(
            assetPath: 'assets/images/icons/patient2.png',
            title: 'Patients Dashboard',
            subtitle: 'Patient List Overview',
            buttonLabel: 'Patient logs',
            onTap: () => Navigator.pushNamed(context, '/patients_dashboard'),
          ),
          HomeCard(
            assetPath: 'assets/images/icons/reports.png',
            title: 'Reports & Analytics',
            subtitle: 'Report and schedule appointment',
            buttonLabel: 'Doctor logs',
            onTap: () => Navigator.pushNamed(context, '/reports_analytics'),
          ),
          HomeCard(
            assetPath: 'assets/images/icons/alert.png',
            title: 'Alert Management',
            subtitle: 'Assign Follow-up',
            buttonLabel: 'Period logs',
            onTap: () => Navigator.pushNamed(context, '/alert_management'),
          ),
        ],
      ),
    );
  }

  //     return Scaffold(
  //       backgroundColor: Colors.white,
  //       extendBody: true,
  //       body: SafeArea(
  //         child: SingleChildScrollView(
  //           padding: const EdgeInsets.only(bottom: 80),
  //           child: Column(
  //             children: [
  //               const SizedBox(height: 20),
  //               Center(child: Image.asset('assets/images/logo.png', height: 50)),
  //               const SizedBox(height: 30),
  //               HomeCard(
  //                 assetPath: 'assets/images/icons/patient2.png',
  //                 title: 'Patients Dashboard',
  //                 subtitle: 'Patient List Overview',
  //                 buttonLabel: 'Patient logs',
  //                 onTap: () {
  //                   Navigator.pushNamed(context, '/patients_dashboard');
  //                 },
  //               ),
  //               HomeCard(
  //                 assetPath: 'assets/images/icons/reports.png',
  //                 title: 'Reports & Analytics',
  //                 subtitle: 'Report To Doctor and schedule appointment',
  //                 buttonLabel: 'Doctor logs',
  //                 onTap: () {
  //                   Navigator.pushNamed(context, '/reports_analytics');
  //                 },
  //               ),
  //               HomeCard(
  //                 assetPath: 'assets/images/icons/alert.png',
  //                 title: 'Alert Management',
  //                 subtitle: 'Assign Follow-up',
  //                 buttonLabel: 'Period logs',
  //                 onTap: () {
  //                   Navigator.pushNamed(context, '/alert_management');
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }
}
