import 'package:flutter_test/flutter_test.dart';
import 'package:nutritrack_test/models/patient.dart';

void main() {
  group('Patient Model Tests', () {
    test('should create patient from valid data', () {
      final patient = Patient(
        id: 'test_id',
        name: 'Jane Doe',
        age: 28,
        phone: '+250788123456',
        language: 'english',
        trimester: 2,
        createdAt: DateTime.now(),
      );

      expect(patient.id, 'test_id');
      expect(patient.name, 'Jane Doe');
      expect(patient.age, 28);
      expect(patient.phone, '+250788123456');
      expect(patient.language, 'english');
      expect(patient.trimester, 2);
    });

    test('should create patient from Firestore data', () {
      final firestoreData = {
        'name': 'Maria Uwimana',
        'age': '26',
        'phone': '+250788654321',
        'language': 'kinyarwanda',
        'trimester': '3',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final patient = Patient.fromFirestore(firestoreData, 'firestore_id');

      expect(patient.id, 'firestore_id');
      expect(patient.name, 'Maria Uwimana');
      expect(patient.age, 26);
      expect(patient.phone, '+250788654321');
      expect(patient.language, 'kinyarwanda');
      expect(patient.trimester, 3);
    });

    test('should handle valid trimester values', () {
      for (int trimester = 1; trimester <= 3; trimester++) {
        final patient = Patient(
          id: 'test',
          name: 'Test',
          age: 25,
          phone: '+250788123456',
          language: 'english',
          trimester: trimester,
          createdAt: DateTime.now(),
        );
        expect(patient.trimester, trimester);
      }
    });
  });
}