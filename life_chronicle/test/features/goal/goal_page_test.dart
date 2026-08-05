import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:life_chronicle/features/goal/presentation/goal_page.dart';

import '../../test_utils/test_utils.dart';

/// 使用 LiveTestWidgetsFlutterBinding 以避免 FakeAsync 与 Drift 的
/// StreamQueryStore.markAsClosed 调度的 0 时长 Timer 冲突。
void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;

  setUpAll(() async {
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

  /// 插入一条目标记录用于测试
  Future<GoalRecord> insertGoal({
    String id = 'test-goal-1',
    String title = '测试目标',
    bool isFavorite = false,
  }) async {
    final now = DateTime.now();
    await db.into(db.goalRecords).insert(GoalRecordsCompanion.insert(
          id: id,
          level: 'yearly',
          title: title,
          isFavorite: Value(isFavorite),
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ));
    return (db.select(db.goalRecords)..where((t) => t.id.equals(id))).getSingle();
  }

  group('GoalDetailPage 操作菜单导航（修复点5：push 替代 go）', () {
    testWidgets('点击"编辑"使用 push，返回后回到详情页', (tester) async {
      await insertGoal(id: 'nav-edit-1', title: '编辑导航测试目标');

      await tester.pumpWidget(_buildTestApp(db, initialLocation: '/goal/nav-edit-1'));
      await tester.pumpAndSettle();

      // 验证在详情页（标题栏显示"目标详情"）
      expect(find.text('目标详情'), findsOneWidget);

      // 点击右上角 more_vert 按钮打开操作菜单
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // 验证操作菜单出现"编辑"选项
      expect(find.text('编辑'), findsOneWidget);

      // 点击"编辑"
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证导航到了编辑页（PlaceholderPage 标识）
      expect(find.text('goal-create'), findsOneWidget);

      // 点击返回按钮
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 验证回到了详情页（而非目标首页）
      expect(find.text('目标详情'), findsOneWidget,
          reason: 'push 导航 pop 后应回到详情页，而非目标首页');
    });

    testWidgets('点击"拆解维护"使用 push，返回后回到详情页', (tester) async {
      await insertGoal(id: 'nav-maintain-1', title: '拆解维护导航测试');

      await tester.pumpWidget(_buildTestApp(db, initialLocation: '/goal/nav-maintain-1'));
      await tester.pumpAndSettle();

      // 验证在详情页
      expect(find.text('目标详情'), findsOneWidget);

      // 打开操作菜单
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // 点击"拆解维护"
      await tester.tap(find.text('拆解维护'));
      await tester.pumpAndSettle();

      // 验证导航到了拆解维护页
      expect(find.text('goal-breakdown'), findsOneWidget);

      // 返回
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 验证回到详情页
      expect(find.text('目标详情'), findsOneWidget,
          reason: 'push 导航 pop 后应回到详情页');
    });
  });

  group('GoalDetailPage 顺延计划按钮导航（修复点5）', () {
    testWidgets('点击"顺延计划"使用 push，返回后回到详情页', (tester) async {
      await insertGoal(id: 'nav-postpone-1', title: '顺延导航测试');

      await tester.pumpWidget(_buildTestApp(db, initialLocation: '/goal/nav-postpone-1'));
      await tester.pumpAndSettle();

      // 验证在详情页
      expect(find.text('目标详情'), findsOneWidget);

      // 滚动到底部操作栏，找到"顺延计划"按钮
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('顺延计划'),
        200.0,
        scrollable: scrollable,
      );

      // 点击"顺延计划"
      await tester.tap(find.text('顺延计划'));
      await tester.pumpAndSettle();

      // 验证导航到了顺延页
      expect(find.text('goal-postpone'), findsOneWidget);

      // 返回
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 验证回到详情页
      expect(find.text('目标详情'), findsOneWidget,
          reason: 'push 导航 pop 后应回到详情页');
    });
  });

  group('GoalDetailPage 收藏按钮（修复点6：改用 GoalDao.updateFavorite）', () {
    testWidgets('点击收藏按钮切换 isFavorite 状态并记录 ChangeLog', (tester) async {
      await insertGoal(id: 'fav-btn-1', title: '收藏按钮测试', isFavorite: false);

      await tester.pumpWidget(_buildTestApp(db, initialLocation: '/goal/fav-btn-1'));
      await tester.pumpAndSettle();

      // 验证在详情页
      expect(find.text('目标详情'), findsOneWidget);

      // 滚动到底部操作栏，找到收藏按钮
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byIcon(Icons.favorite_border),
        200.0,
        scrollable: scrollable,
      );

      // 验证初始状态：未收藏（favorite_border 图标 + "收藏"文字）
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);

      // 点击收藏按钮
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // 验证状态切换：已收藏（favorite 图标 + "已收藏"文字）
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('已收藏'), findsOneWidget);

      // 验证数据库中 isFavorite 已更新
      final record = await db.goalDao.findById('fav-btn-1');
      expect(record!.isFavorite, isTrue);

      // 验证 ChangeLog 已记录
      final logs = await (db.select(db.changeLogs)
            ..where((t) => t.entityType.equals('goal_records'))
            ..where((t) => t.entityId.equals('fav-btn-1'))
            ..where((t) => t.action.equals('update')))
          .get();
      expect(logs, isNotEmpty, reason: '收藏操作应通过 DAO 记录 ChangeLog');
      expect(logs.first.changedFields, contains('isFavorite'));
    });

    testWidgets('再次点击取消收藏，状态正确切换', (tester) async {
      await insertGoal(id: 'fav-btn-2', title: '取消收藏测试', isFavorite: true);

      await tester.pumpWidget(_buildTestApp(db, initialLocation: '/goal/fav-btn-2'));
      await tester.pumpAndSettle();

      // 验证初始状态：已收藏
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byIcon(Icons.favorite),
        200.0,
        scrollable: scrollable,
      );
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // 点击取消收藏
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      // 验证状态切换：未收藏
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);

      // 验证数据库中 isFavorite 已更新
      final record = await db.goalDao.findById('fav-btn-2');
      expect(record!.isFavorite, isFalse);
    });
  });
}

// === 测试辅助工具 ===

Widget _buildTestApp(
  AppDatabase db, {
  String initialLocation = '/goal',
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp.router(
      routerConfig: _createTestGoRouter(db, initialLocation: initialLocation),
    ),
  );
}

GoRouter _createTestGoRouter(
  AppDatabase db, {
  String initialLocation = '/goal',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/goal',
        builder: (_, __) => const _PlaceholderPage('goal-home'),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, __) => const _PlaceholderPage('goal-create', showBack: true),
          ),
          GoRoute(
            path: 'breakdown',
            builder: (_, __) => const _PlaceholderPage('goal-breakdown', showBack: true),
          ),
          GoRoute(
            path: 'postpone',
            builder: (_, __) => const _PlaceholderPage('goal-postpone', showBack: true),
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
    return FutureBuilder<GoalRecord?>(
      future: (db.select(db.goalRecords)
            ..where((t) => t.id.equals(goalId))
            ..limit(1))
          .getSingleOrNull(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final record = snapshot.data;
        if (record == null) {
          return const Scaffold(body: Center(child: Text('目标不存在')));
        }
        return GoalDetailPage(record: record);
      },
    );
  }
}

/// 占位页面，用于标识导航目标
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.label, {this.showBack = false});

  final String label;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBack
          ? AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()))
          : null,
      body: Center(child: Text(label)),
    );
  }
}

Future<Directory> _setUpCommonMocks() async {
  final tempDir = await Directory.systemTemp.createTemp('goal_test_');
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
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, __, ___) => true;
  }
}
