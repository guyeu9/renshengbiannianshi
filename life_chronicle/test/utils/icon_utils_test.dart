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

    group('getModuleIcon', () {
      test('should return correct icon for food module', () {
        final icon = IconUtils.getModuleIcon('food');
        expect(icon, equals(Icons.restaurant));
      });

      test('should return correct icon for travel module', () {
        final icon = IconUtils.getModuleIcon('travel');
        expect(icon, equals(Icons.airplanemode_active));
      });

      test('should return correct icon for moment module', () {
        final icon = IconUtils.getModuleIcon('moment');
        expect(icon, equals(Icons.auto_awesome));
      });

      test('should return correct icon for bond module', () {
        final icon = IconUtils.getModuleIcon('bond');
        expect(icon, equals(Icons.group));
      });

      test('should return correct icon for goal module', () {
        final icon = IconUtils.getModuleIcon('goal');
        expect(icon, equals(Icons.outlined_flag));
      });

      test('should return correct icon for schedule module', () {
        final icon = IconUtils.getModuleIcon('schedule');
        expect(icon, equals(Icons.calendar_today));
      });

      test('should return default icon for unknown module', () {
        final icon = IconUtils.getModuleIcon('unknown');
        expect(icon, equals(Icons.event));
      });
    });

    group('getModuleIconName', () {
      test('should return correct icon name for food module', () {
        final name = IconUtils.getModuleIconName('food');
        expect(name, equals('restaurant'));
      });

      test('should return correct icon name for moment module', () {
        final name = IconUtils.getModuleIconName('moment');
        expect(name, equals('auto_awesome'));
      });
    });

    group('getActionIcon', () {
      test('should return correct icon for add action', () {
        final icon = IconUtils.getActionIcon('add');
        expect(icon, equals(Icons.add));
      });

      test('should return correct icon for edit action', () {
        final icon = IconUtils.getActionIcon('edit');
        expect(icon, equals(Icons.edit));
      });

      test('should return correct icon for delete action', () {
        final icon = IconUtils.getActionIcon('delete');
        expect(icon, equals(Icons.delete_outline));
      });

      test('should return correct icon for search action', () {
        final icon = IconUtils.getActionIcon('search');
        expect(icon, equals(Icons.search));
      });

      test('should return default icon for unknown action', () {
        final icon = IconUtils.getActionIcon('unknown');
        expect(icon, equals(Icons.help_outline));
      });
    });

    group('getStatusIcon', () {
      test('should return correct icon for favorite status', () {
        final icon = IconUtils.getStatusIcon('favorite');
        expect(icon, equals(Icons.favorite));
      });

      test('should return correct icon for bookmark status', () {
        final icon = IconUtils.getStatusIcon('bookmark');
        expect(icon, equals(Icons.bookmark));
      });

      test('should return correct icon for chevron_right status', () {
        final icon = IconUtils.getStatusIcon('chevron_right');
        expect(icon, equals(Icons.chevron_right));
      });

      test('should return default icon for unknown status', () {
        final icon = IconUtils.getStatusIcon('unknown');
        expect(icon, equals(Icons.circle));
      });
    });

    group('getMomentTagIconNames', () {
      test('should return list of moment tag icon names', () {
        final names = IconUtils.getMomentTagIconNames();
        expect(names, isNotEmpty);
        expect(names, contains('card_giftcard'));
        expect(names, contains('sunny'));
        expect(names, contains('favorite'));
      });
    });

    group('getGoalTagIconNames', () {
      test('should return list of goal tag icon names', () {
        final names = IconUtils.getGoalTagIconNames();
        expect(names, isNotEmpty);
        expect(names, contains('work'));
        expect(names, contains('school'));
        expect(names, contains('fitness_center'));
      });
    });

    group('getTagIconNamesForModule', () {
      test('should return moment icons for moment module', () {
        final names = IconUtils.getTagIconNamesForModule('moment');
        expect(names, contains('card_giftcard'));
        expect(names, contains('sunny'));
      });

      test('should return goal icons for goal module', () {
        final names = IconUtils.getTagIconNamesForModule('goal');
        expect(names, contains('work'));
        expect(names, contains('school'));
      });

      test('should return all icons for unknown module', () {
        final names = IconUtils.getTagIconNamesForModule('unknown');
        expect(names, equals(IconUtils.availableIcons));
      });
    });

    group('isValidIconName', () {
      test('should return true for valid icon name', () {
        expect(IconUtils.isValidIconName('home'), isTrue);
        expect(IconUtils.isValidIconName('restaurant'), isTrue);
        expect(IconUtils.isValidIconName('auto_awesome'), isTrue);
      });

      test('should return false for invalid icon name', () {
        expect(IconUtils.isValidIconName('unknown_icon'), isFalse);
        expect(IconUtils.isValidIconName(''), isFalse);
        expect(IconUtils.isValidIconName(null), isFalse);
      });
    });

    group('moduleIcons', () {
      test('should return map of module icons', () {
        final icons = IconUtils.moduleIcons;
        expect(icons, isNotEmpty);
        expect(icons['food'], equals(Icons.restaurant));
        expect(icons['moment'], equals(Icons.auto_awesome));
      });
    });

    group('actionIcons', () {
      test('should return map of action icons', () {
        final icons = IconUtils.actionIcons;
        expect(icons, isNotEmpty);
        expect(icons['add'], equals(Icons.add));
        expect(icons['edit'], equals(Icons.edit));
      });
    });

    group('statusIcons', () {
      test('should return map of status icons', () {
        final icons = IconUtils.statusIcons;
        expect(icons, isNotEmpty);
        expect(icons['favorite'], equals(Icons.favorite));
        expect(icons['chevron_right'], equals(Icons.chevron_right));
      });
    });
  });

  group('IconOption', () {
    group('fromNames', () {
      test('should create list of IconOption from names', () {
        final options = IconOption.fromNames(['home', 'work']);
        expect(options.length, equals(2));
        expect(options[0].name, equals('home'));
        expect(options[0].icon, equals(Icons.home));
        expect(options[1].name, equals('work'));
        expect(options[1].icon, equals(Icons.work));
      });
    });

    group('getMomentOptions', () {
      test('should return list of moment icon options', () {
        final options = IconOption.getMomentOptions();
        expect(options, isNotEmpty);
        expect(options.any((o) => o.name == 'card_giftcard'), isTrue);
        expect(options.any((o) => o.name == 'sunny'), isTrue);
      });
    });

    group('getGoalOptions', () {
      test('should return list of goal icon options', () {
        final options = IconOption.getGoalOptions();
        expect(options, isNotEmpty);
        expect(options.any((o) => o.name == 'work'), isTrue);
        expect(options.any((o) => o.name == 'school'), isTrue);
      });
    });

    group('getOptionsForModule', () {
      test('should return moment options for moment module', () {
        final options = IconOption.getOptionsForModule('moment');
        expect(options, isNotEmpty);
        expect(options.any((o) => o.name == 'card_giftcard'), isTrue);
      });

      test('should return goal options for goal module', () {
        final options = IconOption.getOptionsForModule('goal');
        expect(options, isNotEmpty);
        expect(options.any((o) => o.name == 'work'), isTrue);
      });
    });
  });
}
