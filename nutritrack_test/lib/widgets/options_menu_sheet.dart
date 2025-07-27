import 'package:flutter/material.dart';
import 'add_patient_form_sheet.dart';

class OptionsMenuSheet extends StatelessWidget {
  const OptionsMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 24),

          _buildOptionTile(
            icon: Icons.manage_accounts_outlined,
            label: 'Manage Patient Details',
            onTap: () {},
          ),
          const SizedBox(height: 16),

          _buildOptionTile(
            icon: Icons.chat_bubble_outline,
            label: 'Check Chat History',
            onTap: () {},
          ),
          const SizedBox(height: 32),

          Center(
            child: GestureDetector(
              onTap: () => _openAddPatientForm(context),
              child: Container(
                width: 180,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Add Patient',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.campaign_outlined, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Broadcast to all patients',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green.shade800, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddPatientForm(BuildContext context) {
    // Capture a valid context before popping
    final navigatorContext = Navigator.of(context, rootNavigator: true);

    // Close the bottom sheet
    navigatorContext.pop();

    // Schedule the dialog after the sheet is gone
    Future.delayed(const Duration(milliseconds: 200), () {
      showDialog(
        context: navigatorContext.context,
        barrierDismissible: true,
        builder: (context) => const AddPatientFormDialog(),
      );
    });
  }
}
