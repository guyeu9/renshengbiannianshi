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

  static IconData fromName(String? name) {
    if (name == null || name.isEmpty) return Icons.flag;
    return _iconMap[name] ?? Icons.flag;
  }

  static String toName(IconData icon) {
    for (final entry in _iconMap.entries) {
      if (entry.value == icon) return entry.key;
    }
    return 'flag';
  }

  static List<String> get availableIcons => _iconMap.keys.toList();

  static List<IconData> get allIcons => _iconMap.values.toList();
}
