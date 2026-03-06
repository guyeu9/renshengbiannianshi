import 'package:flutter/material.dart';

class IconUtils {
  IconUtils._();

  static const Map<String, IconData> _iconMap = {
    'work': Icons.work,
    'favorite': Icons.favorite,
    'airplanemode_active': Icons.airplanemode_active,
    'flag': Icons.flag,
    'outlined_flag': Icons.outlined_flag,
    'school': Icons.school,
    'fitness_center': Icons.fitness_center,
    'restaurant': Icons.restaurant,
    'book': Icons.book,
    'code': Icons.code,
    'brush': Icons.brush,
    'music_note': Icons.music_note,
    'sports_soccer': Icons.sports_soccer,
    'pets': Icons.pets,
    'home': Icons.home,
    'shopping_bag': Icons.shopping_bag,
    'savings': Icons.savings,
    'directions_car': Icons.directions_car,
    'directions_bike': Icons.directions_bike,
    'directions_run': Icons.directions_run,
    'directions_walk': Icons.directions_walk,
    'self_improvement': Icons.self_improvement,
    'psychology': Icons.psychology,
    'lightbulb': Icons.lightbulb,
    'star': Icons.star,
    'emoji_events': Icons.emoji_events,
    'card_giftcard': Icons.card_giftcard,
    'celebration': Icons.celebration,
    'explore': Icons.explore,
    'public': Icons.public,
    'language': Icons.language,
    'attach_money': Icons.attach_money,
    'trending_up': Icons.trending_up,
    'business': Icons.business,
    'laptop': Icons.laptop,
    'phone': Icons.phone,
    'camera_alt': Icons.camera_alt,
    'movie': Icons.movie,
    'headphones': Icons.headphones,
    'palette': Icons.palette,
    'edit': Icons.edit,
    'description': Icons.description,
    'task': Icons.task,
    'checklist': Icons.checklist,
    'calendar_today': Icons.calendar_today,
    'schedule': Icons.schedule,
    'alarm': Icons.alarm,
    'timer': Icons.timer,
    'local_cafe': Icons.local_cafe,
    'local_bar': Icons.local_bar,
    'local_dining': Icons.local_dining,
    'local_florist': Icons.local_florist,
    'local_hospital': Icons.local_hospital,
    'local_library': Icons.local_library,
    'local_parking': Icons.local_parking,
    'local_pharmacy': Icons.local_pharmacy,
    'local_pizza': Icons.local_pizza,
    'local_shipping': Icons.local_shipping,
    'auto_awesome': Icons.auto_awesome,
    'group': Icons.group,
    'diversity_1': Icons.diversity_1,
    'diversity_3': Icons.diversity_3,
    'sunny': Icons.sunny,
    'coffee': Icons.coffee,
    'beach_access': Icons.beach_access,
    'nightlife': Icons.nightlife,
    'sports_gymnastics': Icons.sports_gymnastics,
    'sports_basketball': Icons.sports_basketball,
    'sports_tennis': Icons.sports_tennis,
    'pool': Icons.pool,
    'menu_book': Icons.menu_book,
    'edit_note': Icons.edit_note,
    'cake': Icons.cake,
    'icecream': Icons.icecream,
    'redeem': Icons.redeem,
    'spa': Icons.spa,
    'flight': Icons.flight,
    'train': Icons.train,
    'volunteer_activism': Icons.volunteer_activism,
    'people': Icons.people,
    'person': Icons.person,
    'person_add': Icons.person_add,
    'emoji_people': Icons.emoji_people,
    'event': Icons.event,
  };

  static const Map<String, IconData> _moduleIcons = {
    'food': Icons.restaurant,
    'travel': Icons.airplanemode_active,
    'moment': Icons.auto_awesome,
    'bond': Icons.group,
    'goal': Icons.outlined_flag,
    'schedule': Icons.calendar_today,
  };

  static const Map<String, IconData> _actionIcons = {
    'add': Icons.add,
    'edit': Icons.edit,
    'delete': Icons.delete_outline,
    'share': Icons.share,
    'search': Icons.search,
    'filter': Icons.filter_list,
    'more': Icons.more_vert,
    'close': Icons.close,
    'back': Icons.arrow_back_ios_new,
    'forward': Icons.arrow_forward_ios,
    'refresh': Icons.refresh,
    'save': Icons.save,
    'cancel': Icons.close,
    'confirm': Icons.check,
    'settings': Icons.settings,
    'help': Icons.help_outline,
    'info': Icons.info_outline,
    'warning': Icons.warning_amber,
    'error': Icons.error_outline,
    'success': Icons.check_circle_outline,
  };

  static const Map<String, IconData> _statusIcons = {
    'favorite': Icons.favorite,
    'favorite_border': Icons.favorite_border,
    'bookmark': Icons.bookmark,
    'bookmark_border': Icons.bookmark_border,
    'check_circle': Icons.check_circle,
    'radio_unchecked': Icons.radio_button_unchecked,
    'check': Icons.check,
    'expand_more': Icons.expand_more,
    'expand_less': Icons.expand_less,
    'chevron_right': Icons.chevron_right,
    'chevron_left': Icons.chevron_left,
  };

  static const List<String> _momentTagIcons = [
    'card_giftcard', 'sunny', 'directions_walk', 'local_florist', 'coffee',
    'beach_access', 'pets', 'music_note', 'nightlife', 'movie',
    'celebration', 'camera_alt', 'fitness_center', 'directions_run',
    'sports_gymnastics', 'sports_soccer', 'sports_basketball', 'sports_tennis',
    'pool', 'directions_bike', 'menu_book', 'school', 'edit_note',
    'palette', 'restaurant', 'cake', 'local_cafe', 'icecream',
    'shopping_bag', 'redeem', 'spa', 'flight', 'train',
    'favorite', 'star', 'volunteer_activism',
  ];

  static const List<String> _goalTagIcons = [
    'work', 'favorite', 'airplanemode_active', 'school', 'fitness_center',
    'self_improvement', 'psychology', 'lightbulb', 'star', 'emoji_events',
    'celebration', 'explore', 'public', 'language', 'attach_money',
    'trending_up', 'business', 'laptop', 'code', 'book',
    'menu_book', 'edit_note', 'task', 'checklist', 'flag',
    'savings', 'home', 'directions_car', 'directions_bike', 'directions_run',
    'sports_soccer', 'sports_basketball', 'pool', 'palette', 'music_note',
    'camera_alt', 'pets', 'restaurant', 'local_cafe',
  ];

  static IconData fromName(String? name, {IconData defaultIcon = Icons.flag}) {
    if (name == null || name.isEmpty) return defaultIcon;
    return _iconMap[name] ?? defaultIcon;
  }

  static String toName(IconData icon) {
    for (final entry in _iconMap.entries) {
      if (entry.value == icon) return entry.key;
    }
    return 'flag';
  }

  static IconData getModuleIcon(String moduleKey, {IconData defaultIcon = Icons.event}) {
    return _moduleIcons[moduleKey] ?? defaultIcon;
  }

  static String getModuleIconName(String moduleKey) {
    final icon = _moduleIcons[moduleKey];
    if (icon == null) return 'event';
    return toName(icon);
  }

  static IconData getActionIcon(String actionKey, {IconData defaultIcon = Icons.help_outline}) {
    return _actionIcons[actionKey] ?? defaultIcon;
  }

  static IconData getStatusIcon(String statusKey, {IconData defaultIcon = Icons.circle}) {
    return _statusIcons[statusKey] ?? defaultIcon;
  }

  static List<String> get availableIcons => _iconMap.keys.toList();

  static List<IconData> get allIcons => _iconMap.values.toList();

  static List<String> get moduleKeys => _moduleIcons.keys.toList();

  static List<String> get actionKeys => _actionIcons.keys.toList();

  static List<String> get statusKeys => _statusIcons.keys.toList();

  static List<IconData> getMomentTagIcons() {
    return _momentTagIcons.map((name) => fromName(name)).toList();
  }

  static List<String> getMomentTagIconNames() {
    return List.from(_momentTagIcons);
  }

  static List<IconData> getGoalTagIcons() {
    return _goalTagIcons.map((name) => fromName(name)).toList();
  }

  static List<String> getGoalTagIconNames() {
    return List.from(_goalTagIcons);
  }

  static List<IconData> getTagIconsForModule(String moduleKey) {
    switch (moduleKey) {
      case 'moment':
        return getMomentTagIcons();
      case 'goal':
        return getGoalTagIcons();
      default:
        return allIcons;
    }
  }

  static List<String> getTagIconNamesForModule(String moduleKey) {
    switch (moduleKey) {
      case 'moment':
        return getMomentTagIconNames();
      case 'goal':
        return getGoalTagIconNames();
      default:
        return availableIcons;
    }
  }

  static bool isValidIconName(String? name) {
    if (name == null || name.isEmpty) return false;
    return _iconMap.containsKey(name);
  }

  static Map<String, IconData> get moduleIcons => Map.from(_moduleIcons);
  static Map<String, IconData> get actionIcons => Map.from(_actionIcons);
  static Map<String, IconData> get statusIcons => Map.from(_statusIcons);
}

class IconOption {
  const IconOption({
    required this.name,
    required this.icon,
    this.category = '',
  });

  final String name;
  final IconData icon;
  final String category;

  static List<IconOption> fromNames(List<String> names, {String category = ''}) {
    return names.map((name) => IconOption(
      name: name,
      icon: IconUtils.fromName(name),
      category: category,
    )).toList();
  }

  static List<IconOption> getMomentOptions() {
    return fromNames(IconUtils.getMomentTagIconNames(), category: 'moment');
  }

  static List<IconOption> getGoalOptions() {
    return fromNames(IconUtils.getGoalTagIconNames(), category: 'goal');
  }

  static List<IconOption> getOptionsForModule(String moduleKey) {
    return fromNames(IconUtils.getTagIconNamesForModule(moduleKey), category: moduleKey);
  }
}
