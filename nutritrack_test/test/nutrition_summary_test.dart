import 'package:flutter_test/flutter_test.dart';
import 'package:nutritrack_test/models/nutrition_summary.dart';

void main() {
  group('NutritionSummary Tests', () {
    test('should create nutrition summary from JSON', () {
      final jsonData = {
        'patientId': 'patient_123',
        'daysAnalyzed': 7,
        'totals': {
          'calories': 1800.0,
          'protein': 65.0,
          'iron': 18.0,
        },
        'targets': {
          'calories': 2200.0,
          'protein': 71.0,
          'iron': 27.0,
        },
        'percentMet': {
          'calories': 82,
          'protein': 92,
          'iron': 67,
        },
        'flags': ['Low iron intake'],
        'recommendations': ['Increase iron-rich foods like spinach and beans'],
      };

      final summary = NutritionSummary.fromJson(jsonData);

      expect(summary.patientId, 'patient_123');
      expect(summary.daysAnalyzed, 7);
      expect(summary.totals['calories'], 1800.0);
      expect(summary.targets['protein'], 71.0);
      expect(summary.percentMet['iron'], 67);
      expect(summary.flags.length, 1);
      expect(summary.recommendations.length, 1);
    });

    test('should handle empty nutrition data', () {
      final jsonData = {
        'patientId': 'patient_456',
        'daysAnalyzed': 0,
        'totals': <String, dynamic>{},
        'targets': <String, dynamic>{},
        'percentMet': <String, dynamic>{},
        'flags': <String>[],
        'recommendations': <String>[],
      };

      final summary = NutritionSummary.fromJson(jsonData);

      expect(summary.patientId, 'patient_456');
      expect(summary.daysAnalyzed, 0);
      expect(summary.totals.isEmpty, true);
      expect(summary.flags.isEmpty, true);
      expect(summary.recommendations.isEmpty, true);
    });
  });
}