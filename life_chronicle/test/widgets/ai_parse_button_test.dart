import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/widgets/ai_parse_button.dart';

void main() {
  group('AiParseButton', () {
    testWidgets('renders with text parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiParseButton(
              text: 'AI 解析',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('AI 解析'), findsOneWidget);
    });

    testWidgets('renders with child parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiParseButton(
              child: const Icon(Icons.auto_awesome),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('triggers onPressed callback when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiParseButton(
              text: 'AI 解析',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      expect(wasPressed, isFalse);
      await tester.tap(find.byType(AiParseButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiParseButton(
              text: 'AI 解析',
              onPressed: () {},
            ),
          ),
        ),
      );

      final textButton = tester.widget<TextButton>(find.byType(TextButton));
      expect(textButton.style, isNotNull);
    });
  });
}
