import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_state.dart';
import '../widgets/auth_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _healthcareIdController = TextEditingController();
  final _facilityNameController = TextEditingController();

  String? _selectedRole;

  final List<String> _roles = [
    'Nurse',
    'Doctor',
    'Community Health Worker',
    'Midwife',
    'Health Assistant',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _healthcareIdController.dispose();
    _facilityNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Logo
              SizedBox(
                width: 120,
                height: 60,
                child: Image.asset(
                  'assets/images/logo.jpg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 60),

              // Error Message
              if (authState.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => authState.clearError(),
                        child: Icon(
                          Icons.close,
                          color: Colors.red[700],
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthTextField(
                      controller: _nameController,
                      hintText: 'Full Name',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _healthcareIdController,
                      hintText: 'Healthcare Worker ID',
                      validator: (value) =>
                          value!.isEmpty ? 'Healthcare ID is required' : null,
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _facilityNameController,
                      hintText: 'Facility Name (Optional)',
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        hintText: 'Select Role',
                      ),
                      items: _roles
                          .map(
                            (role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedRole = value),
                      validator: (value) =>
                          value == null ? 'Please select a role' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Terms Agreement
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      authState.setAgreeToTerms(!authState.agreeToTerms);
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: authState.agreeToTerms
                              ? const Color(0xFF91C788)
                              : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                        color: authState.agreeToTerms
                            ? const Color(0xFF91C788)
                            : Colors.transparent,
                      ),
                      child: authState.agreeToTerms
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I agree with the Terms of Service & Privacy Policy',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit
              GestureDetector(
                onTap: authState.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await authState.register(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            _healthcareIdController.text.trim(),
                            _facilityNameController.text.trim(),
                            _selectedRole!,
                          );
                          // Navigate to the home screen or show a success message
                          // Add this check after registration
                          if (authState.isLoggedIn) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        }
                      },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF91C788),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
