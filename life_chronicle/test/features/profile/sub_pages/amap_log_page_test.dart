import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/features/profile/presentation/amap_log_page.dart';

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

  group('AmapLogPage 基本渲染', () {
    testWidgets('页面标题与返回按钮正确显示', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/amap-log'),
      );
      await tester.pumpAndSettle();

      expect(find.text('地图诊断日志'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('AppBar 操作按钮（刷新、清空）可见', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/amap-log'),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byTooltip('刷新'), findsOneWidget);
      expect(find.byTooltip('清空'), findsOneWidget);
    });

    testWidgets('初始空状态显示"暂无日志"占位文本', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/amap-log'),
      );
      await tester.pumpAndSettle();

      // FileLogger 在 mock 的临时目录下没有日志文件，应回退到 "暂无日志"。
      expect(find.text('暂无日志'), findsOneWidget);
    });

    testWidgets('页面类型为 AmapLogPage', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/amap-log'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AmapLogPage), findsOneWidget);
    });

    testWidgets('点击刷新按钮不崩溃且页面仍可正常渲染', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/amap-log'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('刷新'));
      await tester.pumpAndSettle();

      // 刷新后页面标题仍然存在，证明页面未崩溃。
      expect(find.text('地图诊断日志'), findsOneWidget);
      expect(find.byType(AmapLogPage), findsOneWidget);
    });
  });
}
