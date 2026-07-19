import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/features/profile/presentation/ai_model_management_page.dart';

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

  /// 辅助方法：pump widget 后多 pump 几次让 Drift StreamProvider 完成初始数据发射。
  /// LiveTestWidgetsFlutterBinding 下 StreamProvider 的初始数据通过 microtask 发射，
  /// 需要额外的 pump(Duration.zero) 来处理 microtask 并触发重建。
  Future<void> pumpAndSettleStreams(WidgetTester tester) async {
    await tester.pump(Duration.zero);
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpAndSettle();
  }

  group('AiModelManagementPage 基本渲染', () {
    testWidgets('页面标题和 2 个 Tab 正确显示', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/ai-models'));
      await pumpAndSettleStreams(tester);

      expect(find.text('AI 模型管理'), findsOneWidget);
      expect(find.text('对话服务'), findsOneWidget);
      expect(find.text('Embedding 服务'), findsOneWidget);
    });

    testWidgets('无对话服务商时显示空状态', (tester) async {
      // 清空默认插入的服务商（beforeOpen 钩子会自动插入默认 chat 和 embedding 服务）
      await db.delete(db.aiProviders).go();

      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/ai-models'));
      await pumpAndSettleStreams(tester);

      expect(find.text('暂无 AI 服务商'), findsOneWidget);
      expect(find.text('点击下方按钮添加您的第一个服务商'), findsOneWidget);
      expect(find.byIcon(Icons.psychology_alt), findsOneWidget);
    });

    testWidgets('添加服务商 FAB 可见', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/ai-models'));
      await pumpAndSettleStreams(tester);

      expect(find.text('添加服务商'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('帮助按钮可见', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/ai-models'));
      await pumpAndSettleStreams(tester);

      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.byTooltip('服务说明'), findsOneWidget);
    });

    testWidgets('返回按钮可见', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/ai-models'));
      await pumpAndSettleStreams(tester);

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });
  });

  group('对话服务商列表', () {
    testWidgets('有对话服务商时显示服务商卡片', (tester) async {
      final now = DateTime.now();
      await db.aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'test-chat-1',
        name: '测试对话服务商',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'sk-test123',
        modelName: const Value('gpt-4'),
        createdAt: now,
        updatedAt: now,
      ));

      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/ai-models'));
      await pumpAndSettleStreams(tester);

      // 服务商名称（唯一）
      expect(find.text('测试对话服务商'), findsOneWidget);
      // 模型名称
      expect(find.text('gpt-4'), findsOneWidget);
      // API 类型徽章 - TabBarView 会保活相邻 tab，使用 findsWidgets 允许至少一个
      expect(find.text('OPENAI'), findsWidgets);
      // 编辑和删除按钮
      expect(find.byIcon(Icons.edit_outlined), findsWidgets);
      expect(find.byIcon(Icons.delete_outline), findsWidgets);
    });

    testWidgets('切换到 Embedding 服务 Tab 显示空状态', (tester) async {
      // 清空默认插入的服务商（beforeOpen 钩子会自动插入默认 chat 和 embedding 服务）
      await db.delete(db.aiProviders).go();

      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/ai-models'));
      await pumpAndSettleStreams(tester);

      await tester.tap(find.text('Embedding 服务'));
      await pumpAndSettleStreams(tester);

      expect(find.text('暂无 AI 服务商'), findsOneWidget);
    });
  });
}
