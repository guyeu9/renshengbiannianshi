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

      test('should return correct icon for auto_awesome icon (小确幸)', () {
        final icon = IconUtils.fromName('auto_awesome');
        expect(icon, equals(Icons.auto_awesome));
      });

      test('should return correct icon for group icon (羁绊)', () {
        final icon = IconUtils.fromName('group');
        expect(icon, equals(Icons.group));
      });

      test('should return correct icon for outlined_flag icon (目标)', () {
        final icon = IconUtils.fromName('outlined_flag');
        expect(icon, equals(Icons.outlined_flag));
      });

      test('should return correct icon for sunny icon', () {
        final icon = IconUtils.fromName('sunny');
        expect(icon, equals(Icons.sunny));
      });

      test('should return correct icon for coffee icon', () {
        final icon = IconUtils.fromName('coffee');
        expect(icon, equals(Icons.coffee));
      });

      test('should return correct icon for beach_access icon', () {
        final icon = IconUtils.fromName('beach_access');
        expect(icon, equals(Icons.beach_access));
      });

      test('should return correct icon for nightlife icon', () {
        final icon = IconUtils.fromName('nightlife');
        expect(icon, equals(Icons.nightlife));
      });

      test('should return correct icon for sports_gymnastics icon', () {
        final icon = IconUtils.fromName('sports_gymnastics');
        expect(icon, equals(Icons.sports_gymnastics));
      });

      test('should return correct icon for sports_basketball icon', () {
        final icon = IconUtils.fromName('sports_basketball');
        expect(icon, equals(Icons.sports_basketball));
      });

      test('should return correct icon for sports_tennis icon', () {
        final icon = IconUtils.fromName('sports_tennis');
        expect(icon, equals(Icons.sports_tennis));
      });

      test('should return correct icon for pool icon', () {
        final icon = IconUtils.fromName('pool');
        expect(icon, equals(Icons.pool));
      });

      test('should return correct icon for menu_book icon', () {
        final icon = IconUtils.fromName('menu_book');
        expect(icon, equals(Icons.menu_book));
      });

      test('should return correct icon for edit_note icon', () {
        final icon = IconUtils.fromName('edit_note');
        expect(icon, equals(Icons.edit_note));
      });

      test('should return correct icon for cake icon', () {
        final icon = IconUtils.fromName('cake');
        expect(icon, equals(Icons.cake));
      });

      test('should return correct icon for icecream icon', () {
        final icon = IconUtils.fromName('icecream');
        expect(icon, equals(Icons.icecream));
      });

      test('should return correct icon for redeem icon', () {
        final icon = IconUtils.fromName('redeem');
        expect(icon, equals(Icons.redeem));
      });

      test('should return correct icon for spa icon', () {
        final icon = IconUtils.fromName('spa');
        expect(icon, equals(Icons.spa));
      });

      test('should return correct icon for flight icon', () {
        final icon = IconUtils.fromName('flight');
        expect(icon, equals(Icons.flight));
      });

      test('should return correct icon for train icon', () {
        final icon = IconUtils.fromName('train');
        expect(icon, equals(Icons.train));
      });

      test('should return correct icon for volunteer_activism icon', () {
        final icon = IconUtils.fromName('volunteer_activism');
        expect(icon, equals(Icons.volunteer_activism));
      });

      test('should return correct icon for diversity_3 icon', () {
        final icon = IconUtils.fromName('diversity_3');
        expect(icon, equals(Icons.diversity_3));
      });

      test('should return correct icon for diversity_1 icon', () {
        final icon = IconUtils.fromName('diversity_1');
        expect(icon, equals(Icons.diversity_1));
      });

      test('should return correct icon for directions_walk icon', () {
        final icon = IconUtils.fromName('directions_walk');
        expect(icon, equals(Icons.directions_walk));
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
