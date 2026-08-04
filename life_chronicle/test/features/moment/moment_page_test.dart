import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:life_chronicle/features/moment/presentation/moment_page.dart';

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

  group('MomentPage 搜索框清除按钮（修复点 C2）', () {
    testWidgets('输入文本后显示清除按钮，点击后清空', (tester) async {
      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 找到搜索框并输入文本
      await tester.enterText(find.byType(TextField).first, '测试搜索');
      await tester.pump();

      // 验证清除按钮出现
      expect(find.byIcon(Icons.close), findsOneWidget);

      // 点击清除按钮
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // 验证搜索框已清空
      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('无文本时不显示清除按钮', (tester) async {
      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 初始状态无文本，不应有清除按钮
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('MomentPage 列表卡片导航（修复点 A1）', () {
    testWidgets('点击卡片使用 push 导航到详情页', (tester) async {
      // 插入测试数据
      final now = DateTime.now();
      await db.momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'nav-test-moment-1',
        mood: '开心',
        content: const Value('测试标题\n\n测试内容'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 验证列表页显示了卡片
      expect(find.text('测试标题'), findsOneWidget);

      // 记录当前路由
      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      final initialLocation = router.routeInformationProvider.value.uri.path;

      // 点击卡片
      await tester.tap(find.text('测试标题'));
      await tester.pumpAndSettle();

      // 验证导航到了详情页（路由包含 /moment/nav-test-moment-1）
      final newLocation = router.routeInformationProvider.value.uri.path;
      expect(newLocation, contains('nav-test-moment-1'));
      expect(newLocation, isNot(equals(initialLocation)));
    });
  });

  group('MomentDetailPage 删除文案（修复点 D1）', () {
    testWidgets('删除提示包含"回收站"文案', (tester) async {
      // 插入测试数据
      final now = DateTime.now();
      await db.momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'del-test-moment-1',
        mood: '开心',
        content: const Value('删除测试\n\n内容'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      await tester.pumpWidget(_buildTestApp(
        db,
        initialLocation: '/moment/del-test-moment-1',
      ));
      await tester.pumpAndSettle();

      // 点击更多操作按钮（Icons.more_horiz）
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // 验证"删除此条小确幸"选项出现
      expect(find.text('删除此条小确幸'), findsOneWidget);

      // 验证文案包含"回收站"
      expect(find.textContaining('回收站'), findsOneWidget);
    });
  });

  group('MomentDetailPage 返回 fallback（修复点 A4）', () {
    testWidgets('详情页 AppBar 有返回按钮', (tester) async {
      final now = DateTime.now();
      await db.momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'back-test-moment-1',
        mood: '开心',
        content: const Value('返回测试\n\n内容'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      await tester.pumpWidget(_buildTestApp(
        db,
        initialLocation: '/moment/back-test-moment-1',
      ));
      await tester.pumpAndSettle();

      // 验证 AppBar 有返回按钮（arrow_back_ios_new）
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('点击返回按钮从详情页返回到列表页', (tester) async {
      final now = DateTime.now();
      await db.momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'back-test-moment-2',
        mood: '开心',
        content: const Value('返回测试2\n\n内容'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      // 从列表页开始
      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 点击卡片进入详情页
      await tester.tap(find.text('返回测试2'));
      await tester.pumpAndSettle();

      // 验证在详情页
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // 点击返回按钮
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // 验证回到了列表页（列表页有搜索框）
      expect(find.byType(TextField), findsWidgets);
    });
  });

  group('MomentDetailPage linkChips 可点击（修复点 C1）', () {
    testWidgets('有万物互联时显示 linkChips', (tester) async {
      final now = DateTime.now();
      const momentId = 'link-test-moment-1';
      const friendId = 'link-test-friend-1';

      await db.momentDao.upsert(MomentRecordsCompanion.insert(
        id: momentId,
        mood: '开心',
        content: const Value('关联测试\n\n内容'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      // 插入关联的好友
      await db.into(db.friendRecords).insert(FriendRecordsCompanion.insert(
            id: friendId,
            name: '测试好友',
            isDeleted: const Value(false),
            isFavorite: const Value(false),
            createdAt: now,
            updatedAt: now,
          ));

      // 创建 moment-friend 关联
      await db.into(db.entityLinks).insert(EntityLinksCompanion.insert(
            id: 'link-test-1',
            sourceType: 'moment',
            sourceId: momentId,
            targetType: 'friend',
            targetId: friendId,
            linkType: const Value('manual'),
            createdAt: now,
          ));

      await tester.pumpWidget(_buildTestApp(
        db,
        initialLocation: '/moment/$momentId',
      ));
      await tester.pumpAndSettle();

      // 验证 linkChip 显示（包含"关联羁绊"前缀和好友名）
      expect(find.textContaining('关联羁绊'), findsOneWidget);
      expect(find.textContaining('测试好友'), findsOneWidget);
    });
  });
}

// === 测试辅助工具 ===

Widget _buildTestApp(
  AppDatabase db, {
  String initialLocation = '/moment',
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp.router(
      routerConfig: _createTestGoRouter(initialLocation: initialLocation),
    ),
  );
}

GoRouter _createTestGoRouter({
  String initialLocation = '/moment',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/moment',
        builder: (_, __) => const _MomentListWrapper(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, __) => const _PlaceholderPage('moment-create'),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              return MomentDetailPage(recordId: id);
            },
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

/// MomentPage 的包装器，确保在测试中正确渲染
class _MomentListWrapper extends StatelessWidget {
  const _MomentListWrapper();

  @override
  Widget build(BuildContext context) {
    return const MomentPage();
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

// === Mock 工具（复用 profile_test_helpers 的模式）===

Future<Directory> _setUpCommonMocks() async {
  final tempDir = await Directory.systemTemp.createTemp('moment_test_');
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

/// 消化 Drift 数据库在 dispose 时调度的 0 时长 Timer
Future<void> settleDriftTimers(WidgetTester tester, {int cycles = 8}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  for (var i = 0; i < cycles; i++) {
    await tester.pump(Duration.zero);
  }
}
