import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/features/profile/presentation/profile_page.dart';

import '../../test_utils/test_database.dart';
import 'helpers/profile_test_helpers.dart';

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

  group('ProfilePage 基本渲染', () {
    testWidgets('页面标题和主要区块正确显示', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.text('功能管理'), findsOneWidget);
      expect(find.text('退出登录'), findsOneWidget);
    });

    testWidgets('所有功能入口 tile 正确显示', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.text('收藏中心'), findsOneWidget);
      expect(find.text('编年史管理'), findsOneWidget);
      expect(find.text('年度报告'), findsOneWidget);
      expect(find.text('数据备份'), findsOneWidget);
      expect(find.text('模块管理'), findsOneWidget);
      expect(find.text('万物互联'), findsOneWidget);
      expect(find.text('AI 模型管理'), findsOneWidget);
      expect(find.text('个人资料'), findsOneWidget);
      expect(find.text('提醒设置'), findsOneWidget);
      expect(find.text('隐私与安全'), findsOneWidget);
      expect(find.text('帮助与反馈'), findsOneWidget);
    });

    testWidgets('悬浮按钮正确显示（返回、分享、通知）', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('编年史卡片区域显示', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.text('生成编年史'), findsOneWidget);
    });
  });

  group('_Header 组件渲染', () {
    testWidgets('有用户名时显示用户名', (tester) async {
      await insertTestUserProfile(db, displayName: '张三');

      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.text('张三'), findsOneWidget);
    });

    testWidgets('无用户名时显示"未设置"', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.text('未设置'), findsOneWidget);
    });

    testWidgets('有签名时显示签名文本', (tester) async {
      await insertTestUserProfile(db, signature: '我的签名\n第二行');

      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.text('我的签名'), findsOneWidget);
      expect(find.text('第二行'), findsOneWidget);
    });

    testWidgets('无签名时显示默认签名', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.text('我频繁的记录着，我热烈的分享着'), findsOneWidget);
      expect(find.text('你要知道诗人的一生也可能非常普通'), findsOneWidget);
    });

    testWidgets('有记录天数时显示天数', (tester) async {
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      await insertTestUserProfile(db, createdAt: tenDaysAgo);

      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('记录天数格式化：1000+ 显示为 k 单位', (tester) async {
      final twelveHundredDaysAgo = DateTime.now().subtract(const Duration(days: 1200));
      await insertTestUserProfile(db, createdAt: twelveHundredDaysAgo);

      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.textContaining('1.2k'), findsOneWidget);
    });

    testWidgets('头像区域正确渲染', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.history_edu), findsOneWidget);
    });
  });

  group('退出登录按钮', () {
    testWidgets('点击退出登录显示 SnackBar', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('退出登录'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('退出登录'));
      await tester.pumpAndSettle();

      expect(find.text('退出登录功能开发中，敬请期待'), findsOneWidget);
    });
  });

  group('PopScope', () {
    testWidgets('PopScope 存在且页面正确渲染在 /profile 路由', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('功能管理'), findsOneWidget);
    });
  });

  group('_ChronicleCard', () {
    testWidgets('点击编年史卡片跳转到 chronicle-config', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('生成编年史'));
      await tester.pumpAndSettle();

      expect(find.text('chronicle-config'), findsOneWidget);
    });
  });
}

