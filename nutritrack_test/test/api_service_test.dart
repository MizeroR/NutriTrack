import 'package:flutter_test/flutter_test.dart';
import 'package:nutritrack_test/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    test('should initialize with healthcare worker ID', () {
      const testId = 'HCW001';
      final apiService = ApiService(healthcareWorkerId: testId);
      
      expect(apiService.healthcareWorkerId, testId);
    });

    test('should initialize without healthcare worker ID', () {
      final apiService = ApiService();
      
      expect(apiService.healthcareWorkerId, null);
    });

    test('should handle null healthcare worker ID', () {
      final apiService = ApiService(healthcareWorkerId: null);
      
      expect(apiService.healthcareWorkerId, null);
    });
  });
}