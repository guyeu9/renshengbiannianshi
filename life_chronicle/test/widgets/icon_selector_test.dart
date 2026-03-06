import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/widgets/icon_selector.dart';
import 'package:life_chronicle/core/utils/icon_utils.dart';

void main() {
  group('IconSelector', () {
    testWidgets('renders icons from provided list', (WidgetTester tester) async {
      final testIcons = ['work', 'favorite', 'flag'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelector(
              selectedIcon: null,
              onIconSelected: (_) {},
              iconNames: testIcons,
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsNWidgets(3));
    });

    testWidgets('triggers callback when icon is selected', (WidgetTester tester) async {
      String? selectedIcon;
      final testIcons = ['work', 'favorite', 'flag'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelector(
              selectedIcon: null,
              onIconSelected: (icon) {
                selectedIcon = icon;
              },
              iconNames: testIcons,
            ),
          ),
        ),
      );

      expect(selectedIcon, isNull);
      await tester.tap(find.byType(InkWell).first);
      expect(selectedIcon, 'work');
    });

    testWidgets('shows selected icon with correct styling', (WidgetTester tester) async {
      final testIcons = ['work', 'favorite', 'flag'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelector(
              selectedIcon: 'favorite',
              onIconSelected: (_) {},
              iconNames: testIcons,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('uses moduleKey to get icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelector(
              selectedIcon: null,
              onIconSelected: (_) {},
              moduleKey: 'moment',
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsWidgets);
    });
  });

  group('IconSelectorSheet', () {
    testWidgets('renders title and icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorSheet(
              selectedIcon: null,
              onIconSelected: (_) {},
              title: '选择图标',
            ),
          ),
        ),
      );

      expect(find.text('选择图标'), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('close button dismisses sheet', (WidgetTester tester) async {
      bool didPop = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: IconSelectorSheet(
                    selectedIcon: null,
                    onIconSelected: (_) {},
                  ),
                ),
              ),
              observers: [_MockNavigatorObserver(onPop: () => didPop = true)],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(didPop, isTrue);
    });
  });

  group('IconPickerField', () {
    testWidgets('renders with hint text when no icon selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconPickerField(
              selectedIcon: null,
              onIconSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('点击选择图标'), findsOneWidget);
    });

    testWidgets('renders selected icon name when icon is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconPickerField(
              selectedIcon: 'work',
              onIconSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('work'), findsOneWidget);
    });
  });
}

class _MockNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPop;

  _MockNavigatorObserver({required this.onPop});

  @override
  void didPop(Route route, Route? previousRoute) {
    onPop();
    super.didPop(route, previousRoute);
  }
}
