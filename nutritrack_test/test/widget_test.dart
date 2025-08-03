import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutritrack_test/widgets/auth_text_field.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('AuthTextField displays correctly', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              controller: controller,
              hintText: 'Test Field',
              prefixIcon: Icons.email,
            ),
          ),
        ),
      );

      // Verify the text field is displayed
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('AuthTextField with password toggle', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              controller: controller,
              hintText: 'Password',
              prefixIcon: Icons.lock,
              obscureText: true,
              showPasswordToggle: true,
            ),
          ),
        ),
      );

      // Verify password field with toggle
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      // Check for any visibility icon (on or off)
      expect(find.byType(IconButton), findsOneWidget);
    });
  });
}
