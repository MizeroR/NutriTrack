import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_state.dart';
import '../widgets/auth_text_field.dart';
// import '../widgets/social_auth_button.dart';
import '../screens/signup_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              SizedBox(
                width: 120,
                height: 60,
                child: Image.asset(
                  'assets/images/logo.png',
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
                      Expanded(child: Text(authState.errorMessage!)),
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

              // Email Field
              AuthTextField(
                controller: emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field
              AuthTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Login Button
              GestureDetector(
                onTap: authState.isLoading
                    ? null
                    : () async {
                        // Add your login logic here
                        await authState.login(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        // Navigate to the home screen or show a success message
                        if (authState.isLoggedIn) {
                          Navigator.pushReplacementNamed(context, '/home');
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
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Log In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Social Login Buttons
              Row(
                children: [
                  // Expanded(
                  //   child: SocialAuthButton(
                  //     iconText: 'G',
                  //     label: 'Google',
                  //     onPressed: authState.isLoading
                  //         ? null
                  //         : () => authState.signInWithGoogle(),
                  //   ),
                  // ),
                  const SizedBox(width: 16),
                  // Expanded(
                  //   child: SocialAuthButton(
                  //     iconText: 'f',
                  //     label: 'Facebook',
                  //     onPressed: authState.isLoading
                  //         ? null
                  //         : () => authState.signInWithFacebook(),
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(height: 32),

              // Sign Up Redirect
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
                child: const Text(
                  'Don\'t have an account? Sign Up',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
