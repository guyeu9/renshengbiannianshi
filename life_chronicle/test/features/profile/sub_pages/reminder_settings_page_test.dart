import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_utils/test_database.dart';
import '../helpers/profile_test_helpers.dart';

void main() {
  // 使用 LiveTestWidgetsFlutterBinding 以避免 FakeAsync 与 Drift 的
  // StreamQueryStore.markAsClosed 调度的 0 时长 Timer 冲突。
  // 详见 helpers/profile_test_helpers.dart 中 settleDriftTimers 的注释。
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await setUpCommonMocks();
  });

  tearDownAll(() {
    tearDownCommonMocks(tempDir);
  });

  setUp(() async {
    db = createTestDatabase();
    // 每个测试前清空 SharedPreferences mock 值，确保初始状态可控
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('ReminderSettingsPage 基本渲染', () {
    testWidgets('页面标题和 3 个 Tab 正确显示', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/reminder'));
      await tester.pumpAndSettle();

      expect(find.text('提醒设置'), findsOneWidget);
      expect(find.text('通用'), findsOneWidget);
      expect(find.text('生日'), findsOneWidget);
      expect(find.text('联络'), findsOneWidget);
    });

    testWidgets('默认状态（SharedPreferences 未设置）显示"已开启所有提醒"', (tester) async {
      // _loadSettings 中 prefs.getBool('global_reminder_enabled') ?? true 默认为 true
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/reminder'));
      await tester.pumpAndSettle();

      expect(find.text('提醒总开关'), findsOneWidget);
      expect(find.text('已开启所有提醒'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });

    testWidgets('global_reminder_enabled=false 时显示"已关闭所有提醒"', (tester) async {
      SharedPreferences.setMockInitialValues({
        'global_reminder_enabled': false,
      });

      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/reminder'));
      await tester.pumpAndSettle();

      expect(find.text('已关闭所有提醒'), findsOneWidget);
    });
  });

  group('通用 Tab', () {
    testWidgets('显示生日提醒天数 ChoiceChip 选项', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/reminder'));
      await tester.pumpAndSettle();

      expect(find.text('生日提醒'), findsOneWidget);
      expect(find.text('提前提醒天数'), findsOneWidget);
      expect(find.text('1天前'), findsOneWidget);
      expect(find.text('3天前'), findsOneWidget);
      expect(find.text('7天前'), findsOneWidget);
      expect(find.text('14天前'), findsOneWidget);
      // 默认选中 3 天前
      expect(find.text('在朋友生日前3天发送提醒通知'), findsOneWidget);
    });

    testWidgets('显示免打扰模式和测试通知区块', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/reminder'));
      await tester.pumpAndSettle();

      expect(find.text('免打扰时段'), findsOneWidget);
      expect(find.text('免打扰模式'), findsOneWidget);
      expect(find.text('22:00 - 08:00 期间不发送提醒'), findsOneWidget);

      // 向下滚动以显示"测试通知"区块（ListView 内容超出默认 800x600 视口）
      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('测试通知'), findsOneWidget);
      expect(find.text('发送测试通知'), findsOneWidget);
      expect(find.text('发送'), findsOneWidget);
    });
  });

  group('生日 Tab', () {
    testWidgets('无好友时显示空状态', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/reminder'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('生日'));
      await tester.pumpAndSettle();

      expect(find.text('暂无生日记录'), findsOneWidget);
      expect(find.text('为朋友添加生日后可设置提醒'), findsOneWidget);
      expect(find.byIcon(Icons.cake_outlined), findsOneWidget);
    });
  });

  group('联络 Tab', () {
    testWidgets('无好友时显示空状态', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/reminder'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('联络'));
      await tester.pumpAndSettle();

      expect(find.text('暂无好友记录'), findsOneWidget);
      expect(find.text('添加好友后可设置联络提醒'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });
  });
}
