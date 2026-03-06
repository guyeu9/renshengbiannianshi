import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/providers/uuid_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('uuidProvider', () {
    test('should provide an instance of Uuid', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final uuid = container.read(uuidProvider);

      expect(uuid, isA<Uuid>());
    });

    test('should generate valid v4 UUIDs', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final uuid = container.read(uuidProvider);
      final uuid1 = uuid.v4();
      final uuid2 = uuid.v4();

      expect(uuid1, isNotNull);
      expect(uuid1.length, greaterThan(0));
      expect(uuid1, matches(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'));
      
      expect(uuid2, isNotNull);
      expect(uuid2, isNot(equals(uuid1)));
    });

    test('should generate different UUIDs on each call', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final uuid = container.read(uuidProvider);
      final uuidSet = <String>{};

      for (int i = 0; i < 100; i++) {
        uuidSet.add(uuid.v4());
      }

      expect(uuidSet.length, equals(100));
    });

    test('should generate valid v5 UUIDs from name', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final uuid = container.read(uuidProvider);
      const name = 'test-name';
      const namespace = Uuid.NAMESPACE_URL;
      
      final uuid5 = uuid.v5(namespace, name);

      expect(uuid5, isNotNull);
      expect(uuid5, matches(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'));
    });

    test('should generate identical v5 UUIDs for same name and namespace', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final uuid = container.read(uuidProvider);
      const name = 'same-test-name';
      const namespace = Uuid.NAMESPACE_DNS;

      final uuid5a = uuid.v5(namespace, name);
      final uuid5b = uuid.v5(namespace, name);

      expect(uuid5a, equals(uuid5b));
    });

    test('should be a singleton (same instance from container)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final uuid1 = container.read(uuidProvider);
      final uuid2 = container.read(uuidProvider);

      expect(identical(uuid1, uuid2), isTrue);
    });
  });
}
