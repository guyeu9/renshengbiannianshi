import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/utils/api_key_masker.dart';

void main() {
  group('maskApiKey', () {
    test('should mask API key correctly for normal length key', () {
      const apiKey = 'sk-1234567890abcdefghijklmnop';
      final masked = maskApiKey(apiKey);
      expect(masked, equals('sk-****mnop'));
    });

    test('should return empty string for empty API key', () {
      final masked = maskApiKey('');
      expect(masked, equals(''));
    });

    test('should return **** for API key with length <= 8', () {
      final masked1 = maskApiKey('12345678');
      expect(masked1, equals('****'));

      final masked2 = maskApiKey('1234567');
      expect(masked2, equals('****'));

      final masked3 = maskApiKey('1');
      expect(masked3, equals('****'));
    });

    test('should handle API key with exactly 9 characters', () {
      final masked = maskApiKey('123456789');
      expect(masked, equals('123****6789'));
    });

    test('should handle API key with special characters', () {
      const apiKey = 'sk_test_1234567890abcdef';
      final masked = maskApiKey(apiKey);
      expect(masked, equals('sk_****cdef'));
    });

    test('should handle API key with hyphens and underscores', () {
      const apiKey = 'api-key_12345-67890';
      final masked = maskApiKey(apiKey);
      expect(masked, equals('api****7890'));
    });
  });

  group('isValidApiKeyFormat', () {
    test('should return true for valid API key format', () {
      expect(isValidApiKeyFormat('sk-1234567890abcdef'), isTrue);
      expect(isValidApiKeyFormat('abcdefghijklmnop'), isTrue);
      expect(isValidApiKeyFormat('API_KEY_12345678'), isTrue);
      expect(isValidApiKeyFormat('test-api-key-12345'), isTrue);
    });

    test('should return false for empty API key', () {
      expect(isValidApiKeyFormat(''), isFalse);
    });

    test('should return false for API key shorter than 8 characters', () {
      expect(isValidApiKeyFormat('1234567'), isFalse);
      expect(isValidApiKeyFormat('abc'), isFalse);
      expect(isValidApiKeyFormat('a'), isFalse);
    });

    test('should return false for API key longer than 64 characters', () {
      final longKey = 'a' * 65;
      expect(isValidApiKeyFormat(longKey), isFalse);
    });

    test('should return false for API key with invalid characters', () {
      expect(isValidApiKeyFormat('api key 12345'), isFalse);
      expect(isValidApiKeyFormat('api@key#12345'), isFalse);
      expect(isValidApiKeyFormat('api.key.12345'), isFalse);
    });

    test('should accept API key with exactly 8 characters', () {
      expect(isValidApiKeyFormat('12345678'), isTrue);
    });

    test('should accept API key with exactly 64 characters', () {
      final key64 = 'a' * 64;
      expect(isValidApiKeyFormat(key64), isTrue);
    });
  });
}
