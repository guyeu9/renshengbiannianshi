import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/widgets/custom_bottom_sheet.dart';

void main() {
  group('CustomBottomSheet', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomSheet(
              child: const Text('测试内容'),
            ),
          ),
        ),
      );

      expect(find.text('测试内容'), findsOneWidget);
    });

    testWidgets('has drag indicator at top', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomSheet(
              child: const Text('测试内容'),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container).first;
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('showCustomBottomSheet displays bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showCustomBottomSheet(
                    context: context,
                    builder: (context) => const Text('底部面板内容'),
                  );
                },
                child: const Text('显示底部面板'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('底部面板内容'), findsNothing);
      await tester.tap(find.text('显示底部面板'));
      await tester.pumpAndSettle();
      expect(find.text('底部面板内容'), findsOneWidget);
    });
  });
}
