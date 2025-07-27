import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoController.forward();

    // Navigate after short delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/wrapper');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA2DC90),
      body: SafeArea(
        child: Center(
          child: ScaleTransition(
            scale: _logoAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/nutrimama_logo.png', height: 120),
                const SizedBox(height: 12),
                const Text(
                  'NutriTrack',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
