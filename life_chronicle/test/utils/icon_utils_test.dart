import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/utils/icon_utils.dart';
import 'package:flutter/material.dart';

void main() {
  group('IconUtils', () {
    group('fromName', () {
      test('should return correct icon for valid icon name', () {
        final icon = IconUtils.fromName('home');
        expect(icon, equals(Icons.home));
      });

      test('should return correct icon for restaurant icon', () {
        final icon = IconUtils.fromName('restaurant');
        expect(icon, equals(Icons.restaurant));
      });

      test('should return correct icon for favorite icon', () {
        final icon = IconUtils.fromName('favorite');
        expect(icon, equals(Icons.favorite));
      });

      test('should return default icon for null icon name', () {
        final icon = IconUtils.fromName(null);
        expect(icon, equals(Icons.flag));
      });

      test('should return default icon for empty icon name', () {
        final icon = IconUtils.fromName('');
        expect(icon, equals(Icons.flag));
      });

      test('should return default icon for unknown icon name', () {
        final icon = IconUtils.fromName('unknown_icon_xyz');
        expect(icon, equals(Icons.flag));
      });

      test('should return correct icon for work icon', () {
        final icon = IconUtils.fromName('work');
        expect(icon, equals(Icons.work));
      });

      test('should return correct icon for school icon', () {
        final icon = IconUtils.fromName('school');
        expect(icon, equals(Icons.school));
      });

      test('should return correct icon for fitness_center icon', () {
        final icon = IconUtils.fromName('fitness_center');
        expect(icon, equals(Icons.fitness_center));
      });

      test('should return correct icon for flight icon', () {
        final icon = IconUtils.fromName('airplanemode_active');
        expect(icon, equals(Icons.airplanemode_active));
      });
    });

    group('toName', () {
      test('should return correct name for valid icon data', () {
        final name = IconUtils.toName(Icons.home);
        expect(name, equals('home'));
      });

      test('should return correct name for restaurant icon', () {
        final name = IconUtils.toName(Icons.restaurant);
        expect(name, equals('restaurant'));
      });

      test('should return default name for unknown icon data', () {
        final name = IconUtils.toName(Icons.ac_unit);
        expect(name, equals('flag'));
      });

      test('should return correct name for favorite icon', () {
        final name = IconUtils.toName(Icons.favorite);
        expect(name, equals('favorite'));
      });
    });

    group('availableIcons', () {
      test('should return list of available icon names', () {
        final icons = IconUtils.availableIcons;
        expect(icons, isNotEmpty);
        expect(icons, contains('home'));
        expect(icons, contains('restaurant'));
        expect(icons, contains('favorite'));
        expect(icons, contains('work'));
      });
    });

    group('allIcons', () {
      test('should return list of all IconData', () {
        final icons = IconUtils.allIcons;
        expect(icons, isNotEmpty);
        expect(icons, contains(Icons.home));
        expect(icons, contains(Icons.restaurant));
        expect(icons, contains(Icons.favorite));
      });
    });
  });
}
