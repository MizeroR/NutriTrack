import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String assetPath;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const HomeCard({
    super.key,
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 200, // ✅ Fixed height for all cards
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF81B56C), Color(0xFFA3D69B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              color: const Color.fromARGB(179, 255, 253, 253),
              fontSize: 18,
            ),
          ),

          const Spacer(),

          // ✅ Bottom button
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    buttonLabel,
                    style: TextStyle(
                      color: Color(0xFF81B56C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16, color: Color(0xFF81B56C)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
