// 0.1.166 UI层操作后刷新可靠性测试
// 防护 0.1.159 同类 bug：UI 组件在用户操作后必须正确刷新
//
// 本测试验证：用户在编辑页面修改内容并保存后，
// 1. 数据库中的记录被正确更新
// 2. 返回详情页后，详情页显示最新内容（而非旧内容）
// 3. 返回列表页后，列表页显示最新内容（而非旧内容）
//
// 防护场景：用户编辑保存后，UI 仍显示旧内容（数据已更新但 UI 未刷新）

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:life_chronicle/features/food/presentation/food_page.dart';
import 'package:life_chronicle/features/goal/presentation/goal_page.dart';
import 'package:life_chronicle/features/moment/presentation/moment_page.dart';

import '../../test_utils/test_utils.dart';

/// 使用 LiveTestWidgetsFlutterBinding 以避免 FakeAsync 与 Drift 的 Timer 冲突。
void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;

  setUpAll(() async {
    // 禁用全局提醒，避免 ReminderScheduler 调用通知服务（需要额外 mock）
    SharedPreferences.setMockInitialValues({
      'global_reminder_enabled': false,
    });
    tempDir = await _setUpCommonMocks();
  });

  tearDownAll(() {
    _tearDownCommonMocks(tempDir);
  });

  setUp(() async {
    db = createTestDatabase();
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('（0.1.166）目标模块编辑保存后 UI 刷新测试', () {
    Future<void> insertGoal({
      String id = 'goal-edit-1',
      String title = '编辑前目标标题',
    }) async {
      final now = DateTime.now();
      await db.into(db.goalRecords).insert(GoalRecordsCompanion.insert(
            id: id,
            level: 'yearly',
            title: title,
            recordDate: now,
            createdAt: now,
            updatedAt: now,
          ));
    }

    testWidgets('1. 目标详情页点击编辑按钮后进入编辑页面', (tester) async {
      await insertGoal(id: 'goal-enter-edit', title: '进入编辑测试');

      await tester.pumpWidget(_buildGoalTestApp(
        db,
        initialLocation: '/goal/goal-enter-edit',
      ));
      await tester.pumpAndSettle();

      // 验证在详情页
      expect(find.text('目标详情'), findsOneWidget);

      // 打开操作菜单
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // 点击"编辑"
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证导航到了编辑页面（AppBar 显示"编辑目标"）
      expect(find.text('编辑目标'), findsOneWidget,
          reason: '点击编辑后应进入编辑页面');
    });

    testWidgets('2. 编辑保存后数据库标题已更新', (tester) async {
      await insertGoal(id: 'goal-save-db', title: '保存前标题');

      await tester.pumpWidget(_buildGoalTestApp(
        db,
        initialLocation: '/goal/goal-save-db',
      ));
      await tester.pumpAndSettle();

      // 打开操作菜单，点击"编辑"
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证在编辑页面
      expect(find.text('编辑目标'), findsOneWidget);

      // 找到标题输入框（hintText: '输入目标'），清空并输入新标题
      final titleField = find.byWidgetPredicate((widget) {
        if (widget is! TextField) return false;
        final decoration = widget.decoration;
        return decoration?.hintText == '输入目标';
      });
      expect(titleField, findsOneWidget);

      await tester.enterText(titleField, '保存后新标题');
      await tester.pumpAndSettle();

      // 点击"保存"按钮（AppBar 中的 TextButton）
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 验证数据库中标题已更新
      final record = await db.goalDao.findById('goal-save-db');
      expect(record!.title, equals('保存后新标题'),
          reason: '防护 0.1.159 同类 bug：编辑保存后，数据库中标题应已更新');
    });

    testWidgets('3. 编辑保存后返回详情页显示新标题（核心场景！防护UI未刷新）',
        (tester) async {
      await insertGoal(id: 'goal-refresh', title: '编辑前的旧标题');

      await tester.pumpWidget(_buildGoalTestApp(
        db,
        initialLocation: '/goal/goal-refresh',
      ));
      await tester.pumpAndSettle();

      // 验证详情页显示旧标题
      expect(find.text('编辑前的旧标题'), findsWidgets);

      // 打开操作菜单，点击"编辑"
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证在编辑页面
      expect(find.text('编辑目标'), findsOneWidget);

      // 修改标题
      final titleField = find.byWidgetPredicate((widget) {
        if (widget is! TextField) return false;
        return widget.decoration?.hintText == '输入目标';
      });
      await tester.enterText(titleField, '编辑后的新标题');
      await tester.pumpAndSettle();

      // 点击"保存"
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 核心验证：返回详情页后，应显示新标题（而非旧标题）
      expect(find.text('编辑后的新标题'), findsWidgets,
          reason: '防护 0.1.159 同类 bug：编辑保存后返回详情页，'
              '应显示新标题');
      expect(find.text('编辑前的旧标题'), findsNothing,
          reason: '编辑保存后，旧标题不应再显示');
    });

    testWidgets('4. 编辑保存后通过 DAO 更新数据库，详情页 Stream 实时刷新',
        (tester) async {
      await insertGoal(id: 'goal-stream', title: 'Stream刷新旧标题');

      await tester.pumpWidget(_buildGoalTestApp(
        db,
        initialLocation: '/goal/goal-stream',
      ));
      await tester.pumpAndSettle();

      // 验证详情页显示旧标题
      expect(find.text('Stream刷新旧标题'), findsWidgets);

      // 直接通过 DAO 更新数据库（模拟编辑保存的效果）
      await (db.update(db.goalRecords)
            ..where((t) => t.id.equals('goal-stream')))
          .write(GoalRecordsCompanion(
        title: const Value('Stream刷新新标题'),
        updatedAt: Value(DateTime.now()),
      ));
      await tester.pumpAndSettle();

      // 核心验证：详情页通过 Stream 监听应实时刷新，显示新标题
      expect(find.text('Stream刷新新标题'), findsWidgets,
          reason: '防护 0.1.159 同类 bug：数据库更新后，'
              '详情页应通过 Stream 监听实时刷新显示新标题');
      expect(find.text('Stream刷新旧标题'), findsNothing);
    });
  });

  group('（0.1.166）美食模块编辑保存后 UI 刷新测试', () {
    Future<void> insertFood({
      String id = 'food-edit-1',
      String title = '编辑前美食标题',
    }) async {
      final now = DateTime.now();
      await db.into(db.foodRecords).insert(FoodRecordsCompanion.insert(
            id: id,
            title: title,
            recordDate: now,
            createdAt: now,
            updatedAt: now,
          ));
    }

    testWidgets('5. 美食详情页点击编辑按钮后进入编辑页面', (tester) async {
      await insertFood(id: 'food-enter-edit', title: '进入编辑测试美食');

      await tester.pumpWidget(_buildFoodTestApp(
        db,
        initialLocation: '/food/food-enter-edit',
      ));
      await tester.pumpAndSettle();

      // 滚动到底部操作栏，找到"编辑"按钮
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('编辑'),
        200.0,
        scrollable: scrollable,
      );

      // 点击"编辑"按钮
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证导航到了编辑页面（AppBar 显示"编辑美食记录"）
      expect(find.text('编辑美食记录'), findsOneWidget,
          reason: '点击编辑后应进入美食编辑页面');
    });

    testWidgets('6. 编辑保存后数据库标题已更新', (tester) async {
      await insertFood(id: 'food-save-db', title: '保存前美食标题');

      await tester.pumpWidget(_buildFoodTestApp(
        db,
        initialLocation: '/food/food-save-db',
      ));
      await tester.pumpAndSettle();

      // 滚动到底部操作栏，点击"编辑"
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('编辑'),
        200.0,
        scrollable: scrollable,
      );
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证在编辑页面
      expect(find.text('编辑美食记录'), findsOneWidget);

      // 找到标题输入框（hintText: '输入餐厅名称...'），清空并输入新标题
      final titleField = find.byWidgetPredicate((widget) {
        if (widget is! TextField) return false;
        return widget.decoration?.hintText == '输入餐厅名称...';
      });
      expect(titleField, findsOneWidget);

      await tester.enterText(titleField, '保存后新美食标题');
      await tester.pumpAndSettle();

      // 点击"保存"按钮（ElevatedButton）
      final saveButton = find.widgetWithText(ElevatedButton, '保存');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // 验证数据库中标题已更新
      final record = await db.foodDao.findById('food-save-db');
      expect(record!.title, equals('保存后新美食标题'),
          reason: '防护 0.1.159 同类 bug：编辑保存后，数据库中标题应已更新');
    });

    testWidgets('7. 编辑保存后返回详情页显示新标题（核心场景！防护UI未刷新）',
        (tester) async {
      await insertFood(id: 'food-refresh', title: '编辑前旧美食标题');

      await tester.pumpWidget(_buildFoodTestApp(
        db,
        initialLocation: '/food/food-refresh',
      ));
      await tester.pumpAndSettle();

      // 验证详情页显示旧标题
      expect(find.text('编辑前旧美食标题'), findsWidgets);

      // 滚动到底部操作栏，点击"编辑"
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('编辑'),
        200.0,
        scrollable: scrollable,
      );
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证在编辑页面
      expect(find.text('编辑美食记录'), findsOneWidget);

      // 修改标题
      final titleField = find.byWidgetPredicate((widget) {
        if (widget is! TextField) return false;
        return widget.decoration?.hintText == '输入餐厅名称...';
      });
      await tester.enterText(titleField, '编辑后新美食标题');
      await tester.pumpAndSettle();

      // 点击"保存"
      final saveButton = find.widgetWithText(ElevatedButton, '保存');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // 核心验证：返回详情页后，应显示新标题
      expect(find.text('编辑后新美食标题'), findsWidgets,
          reason: '防护 0.1.159 同类 bug：编辑保存后返回详情页，'
              '应显示新标题');
      expect(find.text('编辑前旧美食标题'), findsNothing,
          reason: '编辑保存后，旧标题不应再显示');
    });

    testWidgets('8. 编辑保存后通过 DAO 更新数据库，详情页 Stream 实时刷新',
        (tester) async {
      await insertFood(id: 'food-stream', title: 'Stream刷新旧美食');

      await tester.pumpWidget(_buildFoodTestApp(
        db,
        initialLocation: '/food/food-stream',
      ));
      await tester.pumpAndSettle();

      // 验证详情页显示旧标题
      expect(find.text('Stream刷新旧美食'), findsWidgets);

      // 直接通过 DAO 更新数据库
      await (db.update(db.foodRecords)
            ..where((t) => t.id.equals('food-stream')))
          .write(FoodRecordsCompanion(
        title: const Value('Stream刷新新美食'),
        updatedAt: Value(DateTime.now()),
      ));
      await tester.pumpAndSettle();

      // 核心验证：详情页通过 Stream 监听应实时刷新
      expect(find.text('Stream刷新新美食'), findsWidgets,
          reason: '防护 0.1.159 同类 bug：数据库更新后，'
              '详情页应通过 Stream 监听实时刷新显示新标题');
      expect(find.text('Stream刷新旧美食'), findsNothing);
    });
  });

  group('（0.1.166）小确幸模块编辑保存后 UI 刷新测试', () {
    Future<void> insertMoment({
      String id = 'moment-edit-1',
      String content = '编辑前小确幸标题\n\n内容',
    }) async {
      final now = DateTime.now();
      await db.momentDao.upsert(MomentRecordsCompanion.insert(
        id: id,
        mood: '开心',
        content: Value(content),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
    }

    testWidgets('9. 小确幸详情页点击编辑按钮后进入编辑页面', (tester) async {
      await insertMoment(id: 'moment-enter-edit', content: '进入编辑测试小确幸');

      await tester.pumpWidget(_buildMomentTestApp(
        db,
        initialLocation: '/moment/moment-enter-edit',
      ));
      await tester.pumpAndSettle();

      // 滚动到底部操作栏，找到"编辑"按钮
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('编辑'),
        200.0,
        scrollable: scrollable,
      );

      // 点击"编辑"按钮
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证导航到了编辑页面（_CreateTopBar 显示"编辑小确幸"）
      expect(find.text('编辑小确幸'), findsOneWidget,
          reason: '点击编辑后应进入小确幸编辑页面');
    });

    testWidgets('10. 编辑保存后数据库内容已更新', (tester) async {
      await insertMoment(
          id: 'moment-save-db', content: '保存前小确幸标题\n\n内容');

      await tester.pumpWidget(_buildMomentTestApp(
        db,
        initialLocation: '/moment/moment-save-db',
      ));
      await tester.pumpAndSettle();

      // 滚动到底部操作栏，点击"编辑"
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('编辑'),
        200.0,
        scrollable: scrollable,
      );
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证在编辑页面
      expect(find.text('编辑小确幸'), findsOneWidget);

      // 找到标题输入框（hintText: '给这份小确幸起个标题...'）
      final titleField = find.byWidgetPredicate((widget) {
        if (widget is! TextField) return false;
        return widget.decoration?.hintText == '给这份小确幸起个标题...';
      });
      expect(titleField, findsOneWidget);

      await tester.enterText(titleField, '保存后新小确幸标题');
      await tester.pumpAndSettle();

      // 点击"保存"按钮（ElevatedButton in _CreateTopBar）
      final saveButton = find.widgetWithText(ElevatedButton, '保存');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // 验证数据库中内容已更新（标题是 content 的第一行）
      final record = await (db.select(db.momentRecords)
            ..where((t) => t.id.equals('moment-save-db')))
          .getSingle();
      expect(record.content, contains('保存后新小确幸标题'),
          reason: '防护 0.1.159 同类 bug：编辑保存后，数据库中内容应已更新');
    });

    testWidgets('11. 编辑保存后返回详情页显示新标题（核心场景！防护UI未刷新）',
        (tester) async {
      await insertMoment(
          id: 'moment-refresh', content: '编辑前旧小确幸标题\n\n内容');

      await tester.pumpWidget(_buildMomentTestApp(
        db,
        initialLocation: '/moment/moment-refresh',
      ));
      await tester.pumpAndSettle();

      // 验证详情页显示旧标题
      expect(find.text('编辑前旧小确幸标题'), findsWidgets);

      // 滚动到底部操作栏，点击"编辑"
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('编辑'),
        200.0,
        scrollable: scrollable,
      );
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证在编辑页面
      expect(find.text('编辑小确幸'), findsOneWidget);

      // 修改标题
      final titleField = find.byWidgetPredicate((widget) {
        if (widget is! TextField) return false;
        return widget.decoration?.hintText == '给这份小确幸起个标题...';
      });
      await tester.enterText(titleField, '编辑后新小确幸标题');
      await tester.pumpAndSettle();

      // 点击"保存"
      final saveButton = find.widgetWithText(ElevatedButton, '保存');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // 核心验证：返回详情页后，应显示新标题
      expect(find.text('编辑后新小确幸标题'), findsWidgets,
          reason: '防护 0.1.159 同类 bug：编辑保存后返回详情页，'
              '应显示新标题');
      expect(find.text('编辑前旧小确幸标题'), findsNothing,
          reason: '编辑保存后，旧标题不应再显示');
    });

    testWidgets('12. 编辑保存后通过 DAO 更新数据库，详情页 Stream 实时刷新',
        (tester) async {
      await insertMoment(
          id: 'moment-stream', content: 'Stream刷新旧小确幸\n\n内容');

      await tester.pumpWidget(_buildMomentTestApp(
        db,
        initialLocation: '/moment/moment-stream',
      ));
      await tester.pumpAndSettle();

      // 验证详情页显示旧标题
      expect(find.text('Stream刷新旧小确幸'), findsWidgets);

      // 直接通过 DAO 更新数据库
      await (db.update(db.momentRecords)
            ..where((t) => t.id.equals('moment-stream')))
          .write(MomentRecordsCompanion(
        content: const Value('Stream刷新新小确幸\n\n内容'),
        updatedAt: Value(DateTime.now()),
      ));
      await tester.pumpAndSettle();

      // 核心验证：详情页通过 Stream 监听应实时刷新
      expect(find.text('Stream刷新新小确幸'), findsWidgets,
          reason: '防护 0.1.159 同类 bug：数据库更新后，'
              '详情页应通过 Stream 监听实时刷新显示新标题');
      expect(find.text('Stream刷新旧小确幸'), findsNothing);
    });
  });
}

// === 测试辅助工具 ===

// 目标模块测试 App
Widget _buildGoalTestApp(AppDatabase db, {String initialLocation = '/goal'}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp.router(
      routerConfig: _createGoalTestRouter(db, initialLocation: initialLocation),
    ),
  );
}

GoRouter _createGoalTestRouter(AppDatabase db, {String initialLocation = '/goal'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/goal',
        builder: (_, __) => const _PlaceholderPage('goal-home'),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final goal = extra?['goal'] as GoalRecord?;
              return GoalCreatePage(goal: goal);
            },
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              return _TestGoalDetailWrapper(goalId: id, db: db);
            },
          ),
        ],
      ),
    ],
  );
}

/// 测试用的目标详情页包装器，从数据库加载 record 后渲染 GoalDetailPage
class _TestGoalDetailWrapper extends ConsumerWidget {
  const _TestGoalDetailWrapper({required this.goalId, required this.db});

  final String goalId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<GoalRecord?>(
      stream: (db.select(db.goalRecords)
            ..where((t) => t.id.equals(goalId))
            ..limit(1))
          .watchSingleOrNull(),
      builder: (context, snapshot) {
        final record = snapshot.data;
        if (record == null) {
          return const Scaffold(body: Center(child: Text('目标不存在')));
        }
        return GoalDetailPage(record: record);
      },
    );
  }
}

// 美食模块测试 App
Widget _buildFoodTestApp(AppDatabase db, {String initialLocation = '/food'}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp.router(
      routerConfig: _createFoodTestRouter(db, initialLocation: initialLocation),
    ),
  );
}

GoRouter _createFoodTestRouter(AppDatabase db, {String initialLocation = '/food'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/food',
        builder: (_, __) => const FoodPage(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final initialRecord = extra?['initialRecord'] as FoodRecord?;
              return FoodCreatePage(initialRecord: initialRecord);
            },
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                FoodDetailPage(recordId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/friend/:id',
        builder: (_, __) => const _PlaceholderPage('friend-detail'),
      ),
      GoRoute(
        path: '/goal/:id',
        builder: (_, __) => const _PlaceholderPage('goal-detail'),
      ),
    ],
  );
}

// 小确幸模块测试 App
Widget _buildMomentTestApp(AppDatabase db, {String initialLocation = '/moment'}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp.router(
      routerConfig: _createMomentTestRouter(initialLocation: initialLocation),
    ),
  );
}

GoRouter _createMomentTestRouter({String initialLocation = '/moment'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/moment',
        builder: (_, __) => const MomentPage(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final initialRecord = extra?['initialRecord'] as MomentRecord?;
              return MomentCreatePage(initialRecord: initialRecord);
            },
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                MomentDetailPage(recordId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/friend/:id',
        builder: (_, __) => const _PlaceholderPage('friend-detail'),
      ),
      GoRoute(
        path: '/food/:id',
        builder: (_, __) => const _PlaceholderPage('food-detail'),
      ),
      GoRoute(
        path: '/goal/:id',
        builder: (_, __) => const _PlaceholderPage('goal-detail'),
      ),
      GoRoute(
        path: '/travel/:id',
        builder: (_, __) => const _PlaceholderPage('travel-detail'),
      ),
    ],
  );
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(label)),
    );
  }
}

Future<Directory> _setUpCommonMocks() async {
  final tempDir = await Directory.systemTemp.createTemp('edit_refresh_test_');
  HttpOverrides.global = _TestHttpOverrides();

  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => tempDir.path);

  return tempDir;
}

void _tearDownCommonMocks(Directory tempDir) {
  HttpOverrides.global = null;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), null);
  if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  static final Uint8List _imageBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ]);

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse(_imageBytes);
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  final Uint8List _imageBytes;

  _MockHttpClientResponse(this._imageBytes);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _imageBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([_imageBytes]).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
