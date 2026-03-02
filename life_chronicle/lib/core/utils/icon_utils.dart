import 'package:flutter/material.dart';

class IconUtils {
  static const Map<String, IconData> iconRegistry = {
    'restaurant': Icons.restaurant,
    'airplanemode_active': Icons.airplanemode_active,
    'auto_awesome': Icons.auto_awesome,
    'diversity_3': Icons.diversity_3,
    'flag': Icons.flag,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'self_improvement': Icons.self_improvement,
    'camera_alt': Icons.camera_alt,
    'directions_walk': Icons.directions_walk,
    'card_giftcard': Icons.card_giftcard,
    'sunny': Icons.sunny,
    'local_florist': Icons.local_florist,
    'coffee': Icons.coffee,
    'beach_access': Icons.beach_access,
    'pets': Icons.pets,
    'music_note': Icons.music_note,
    'nightlife': Icons.nightlife,
    'movie': Icons.movie,
    'celebration': Icons.celebration,
    'fitness_center': Icons.fitness_center,
    'directions_run': Icons.directions_run,
    'sports_gymnastics': Icons.sports_gymnastics,
    'sports_soccer': Icons.sports_soccer,
    'sports_basketball': Icons.sports_basketball,
    'sports_tennis': Icons.sports_tennis,
    'pool': Icons.pool,
    'directions_bike': Icons.directions_bike,
    'menu_book': Icons.menu_book,
    'school': Icons.school,
    'edit_note': Icons.edit_note,
    'palette': Icons.palette,
    'cake': Icons.cake,
    'local_cafe': Icons.local_cafe,
    'icecream': Icons.icecream,
    'shopping_bag': Icons.shopping_bag,
    'redeem': Icons.redeem,
    'spa': Icons.spa,
    'flight': Icons.flight,
    'train': Icons.train,
    'directions_car': Icons.directions_car,
    'volunteer_activism': Icons.volunteer_activism,
  };

  static IconData fromName(String? name, {IconData defaultIcon = Icons.star}) {
    if (name == null || name.isEmpty) return defaultIcon;
    return iconRegistry[name] ?? defaultIcon;
  }
}
