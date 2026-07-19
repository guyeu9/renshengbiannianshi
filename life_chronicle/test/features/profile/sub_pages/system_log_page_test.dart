import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/features/profile/presentation/system_log_page.dart';

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
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('SystemLogPage 基本渲染', () {
    testWidgets('AppBar 标题与操作按钮（导出、清空）正确显示', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/system-log'),
      );
      await tester.pumpAndSettle();

      expect(find.text('系统日志'), findsOneWidget);
      expect(find.byTooltip('导出'), findsOneWidget);
      expect(find.byTooltip('清空'), findsOneWidget);
      expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byType(SystemLogPage), findsOneWidget);
    });

    testWidgets('统计栏显示四个 emoji 统计项', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/system-log'),
      );
      await tester.pumpAndSettle();

      expect(find.text('❌'), findsOneWidget);
      expect(find.text('⚠️'), findsOneWidget);
      expect(find.text('ℹ️'), findsOneWidget);
      expect(find.text('📊'), findsOneWidget);
      // 初始状态计数均为 0。
      expect(find.text('0'), findsNWidgets(4));
    });

    testWidgets('搜索框可见且 hint 文本正确', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/system-log'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('搜索日志...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('级别筛选 chip 全部可见', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/system-log'),
      );
      await tester.pumpAndSettle();

      // 注意："全部" 文本同时出现在级别筛选 chip 和时间范围下拉中，
      // 因此使用 FilterChip widget 精确定位。
      expect(find.widgetWithText(FilterChip, '全部'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'ERROR'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'WARN'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'INFO'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'DEBUG'), findsOneWidget);
    });

    testWidgets('时间范围下拉默认显示"全部"', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/system-log'),
      );
      await tester.pumpAndSettle();

      // _timeFilterIndex 初始为 2，对应 "全部"。
      // 使用 DropdownButton 精确定位，避免与级别筛选 chip 的 "全部" 冲突。
      expect(find.widgetWithText(DropdownButton<int>, '全部'), findsOneWidget);
    });

    testWidgets('初始空状态显示"暂无日志记录"与刷新按钮', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/system-log'),
      );
      await tester.pumpAndSettle();

      // 搜索框下方的空状态文本应可见（无日志数据时）。
      expect(find.text('暂无日志记录'), findsOneWidget);
      // "刷新" 文本按钮（TextButton.icon）。
      expect(find.widgetWithText(TextButton, '刷新'), findsOneWidget);
    });

    testWidgets('在搜索框输入关键词后显示清除按钮', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/system-log'),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      // 输入文本后，suffixIcon 应显示 Icons.clear 清除按钮。
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.text('test'), findsOneWidget);
    });
  });
}
