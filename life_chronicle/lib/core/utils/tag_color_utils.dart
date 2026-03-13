import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TagColorUtils {
  TagColorUtils._();

  static const Color defaultBackgroundColor = Color(0xFFF3F4F6);
  static const Color selectedBackgroundColor = Color(0x1A2BCDEE);
  static const Color selectedBorderColor = Color(0x332BCDEE);
  static const Color selectedTextColor = Color(0xFF22BEBE);
  static const Color defaultTextColor = Color(0xFF6B7280);

  static Color colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return defaultBackgroundColor;
    try {
      final cleanHex = hex.replaceFirst('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (e) {
      debugPrint('解析颜色值失败: $e');
      return defaultBackgroundColor;
    }
  }

  static Color getBackgroundColor(String? tagColorHex, bool isSelected) {
    if (isSelected) return selectedBackgroundColor;
    if (tagColorHex != null && tagColorHex.isNotEmpty) {
      return colorFromHex(tagColorHex).withValues(alpha: 0.15);
    }
    return defaultBackgroundColor;
  }

  static Color getBorderColor(String? tagColorHex, bool isSelected) {
    if (isSelected) return selectedBorderColor;
    if (tagColorHex != null && tagColorHex.isNotEmpty) {
      return colorFromHex(tagColorHex).withValues(alpha: 0.15);
    }
    return defaultBackgroundColor;
  }

  static Color getTextColor(String? tagColorHex, bool isSelected) {
    if (isSelected) return selectedTextColor;
    if (tagColorHex != null && tagColorHex.isNotEmpty) {
      return colorFromHex(tagColorHex);
    }
    return defaultTextColor;
  }

  static TagColors getTagColors(String? tagColorHex, bool isSelected) {
    return TagColors(
      background: getBackgroundColor(tagColorHex, isSelected),
      border: getBorderColor(tagColorHex, isSelected),
      text: getTextColor(tagColorHex, isSelected),
    );
  }
}

class TagColors {
  const TagColors({
    required this.background,
    required this.border,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color text;
}
