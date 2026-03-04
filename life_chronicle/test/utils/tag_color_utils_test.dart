import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/utils/tag_color_utils.dart';

void main() {
  group('TagColorUtils', () {
    group('colorFromHex', () {
      test('should return correct color from valid hex string', () {
        final color = TagColorUtils.colorFromHex('#FF5733');
        expect(color.red, equals(255));
        expect(color.green, equals(87));
        expect(color.blue, equals(51));
      });

      test('should handle hex string without # prefix', () {
        final color = TagColorUtils.colorFromHex('FF5733');
        expect(color.red, equals(255));
        expect(color.green, equals(87));
        expect(color.blue, equals(51));
      });

      test('should handle lowercase hex string', () {
        final color = TagColorUtils.colorFromHex('#ff5733');
        expect(color.red, equals(255));
        expect(color.green, equals(87));
        expect(color.blue, equals(51));
      });

      test('should return default color for null', () {
        final color = TagColorUtils.colorFromHex(null);
        expect(color, equals(TagColorUtils.defaultBackgroundColor));
      });

      test('should return default color for empty string', () {
        final color = TagColorUtils.colorFromHex('');
        expect(color, equals(TagColorUtils.defaultBackgroundColor));
      });

      test('should return default color for invalid hex string', () {
        final color = TagColorUtils.colorFromHex('invalid');
        expect(color, equals(TagColorUtils.defaultBackgroundColor));
      });
    });

    group('getBackgroundColor', () {
      test('should return selected background color when selected', () {
        final color = TagColorUtils.getBackgroundColor('#FF5733', true);
        expect(color, equals(TagColorUtils.selectedBackgroundColor));
      });

      test('should return color with alpha when not selected and has hex', () {
        final color = TagColorUtils.getBackgroundColor('#FF5733', false);
        expect(color.alpha, equals(38)); // 0.15 * 255 ≈ 38
      });

      test('should return default background when not selected and no hex', () {
        final color = TagColorUtils.getBackgroundColor(null, false);
        expect(color, equals(TagColorUtils.defaultBackgroundColor));
      });
    });

    group('getBorderColor', () {
      test('should return selected border color when selected', () {
        final color = TagColorUtils.getBorderColor('#FF5733', true);
        expect(color, equals(TagColorUtils.selectedBorderColor));
      });

      test('should return color with alpha when not selected and has hex', () {
        final color = TagColorUtils.getBorderColor('#FF5733', false);
        expect(color.alpha, equals(38)); // 0.15 * 255 ≈ 38
      });

      test('should return default background when not selected and no hex', () {
        final color = TagColorUtils.getBorderColor(null, false);
        expect(color, equals(TagColorUtils.defaultBackgroundColor));
      });
    });

    group('getTextColor', () {
      test('should return selected text color when selected', () {
        final color = TagColorUtils.getTextColor('#FF5733', true);
        expect(color, equals(TagColorUtils.selectedTextColor));
      });

      test('should return hex color when not selected and has hex', () {
        final color = TagColorUtils.getTextColor('#FF5733', false);
        expect(color.red, equals(255));
        expect(color.green, equals(87));
        expect(color.blue, equals(51));
      });

      test('should return default text color when not selected and no hex', () {
        final color = TagColorUtils.getTextColor(null, false);
        expect(color, equals(TagColorUtils.defaultTextColor));
      });
    });

    group('getTagColors', () {
      test('should return correct TagColors for selected state', () {
        final tagColors = TagColorUtils.getTagColors('#FF5733', true);
        expect(tagColors.background, equals(TagColorUtils.selectedBackgroundColor));
        expect(tagColors.border, equals(TagColorUtils.selectedBorderColor));
        expect(tagColors.text, equals(TagColorUtils.selectedTextColor));
      });

      test('should return correct TagColors for unselected state with hex', () {
        final tagColors = TagColorUtils.getTagColors('#FF5733', false);
        expect(tagColors.background.alpha, equals(38));
        expect(tagColors.border.alpha, equals(38));
        expect(tagColors.text.red, equals(255));
      });

      test('should return correct TagColors for unselected state without hex', () {
        final tagColors = TagColorUtils.getTagColors(null, false);
        expect(tagColors.background, equals(TagColorUtils.defaultBackgroundColor));
        expect(tagColors.border, equals(TagColorUtils.defaultBackgroundColor));
        expect(tagColors.text, equals(TagColorUtils.defaultTextColor));
      });
    });

    group('TagColors', () {
      test('should create TagColors with correct values', () {
        const tagColors = TagColors(
          background: Colors.red,
          border: Colors.blue,
          text: Colors.green,
        );
        expect(tagColors.background, equals(Colors.red));
        expect(tagColors.border, equals(Colors.blue));
        expect(tagColors.text, equals(Colors.green));
      });
    });

    group('default constants', () {
      test('should have correct default background color', () {
        expect(TagColorUtils.defaultBackgroundColor, equals(const Color(0xFFF3F4F6)));
      });

      test('should have correct selected background color', () {
        expect(TagColorUtils.selectedBackgroundColor, equals(const Color(0x1A2BCDEE)));
      });

      test('should have correct selected border color', () {
        expect(TagColorUtils.selectedBorderColor, equals(const Color(0x332BCDEE)));
      });

      test('should have correct selected text color', () {
        expect(TagColorUtils.selectedTextColor, equals(const Color(0xFF22BEBE)));
      });

      test('should have correct default text color', () {
        expect(TagColorUtils.defaultTextColor, equals(const Color(0xFF6B7280)));
      });
    });
  });
}
