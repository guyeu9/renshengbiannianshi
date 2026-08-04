import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:life_chronicle/features/bond/presentation/bond_page.dart';

import '../../test_utils/test_utils.dart';

/// 使用 LiveTestWidgetsFlutterBinding 以避免 FakeAsync 与 Drift 的 Timer 冲突。
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

  /// 插入一条好友记录用于测试
  Future<void> _insertFriend({
    String id = 'test-friend-1',
    String name = '测试好友',
    bool isFavorite = false,
  }) async {
    final now = DateTime.now();
    await db.into(db.friendRecords).insert(FriendRecordsCompanion.insert(
          id: id,
          name: name,
          isFavorite: Value(isFavorite),
          createdAt: now,
          updatedAt: now,
        ));
  }

  group('BondPage 首页好友卡片跳转（go 导航）', () {
    testWidgets('点击好友卡片跳转到详情页', (tester) async {
      await _insertFriend(id: 'home-friend-1', name: '首页测试好友');

      await tester.pumpWidget(_buildTestApp(db, initialLocation: '/bond'));
      await tester.pumpAndSettle();

      // 验证首页显示好友名称
      expect(find.text('首页测试好友'), findsOneWidget);

      // 点击好友卡片
      await tester.tap(find.text('首页测试好友'));
      await tester.pumpAndSettle();

      // 验证导航到了好友详情页（标题"档案详情"）
      expect(find.text('档案详情'), findsOneWidget,
          reason: '点击好友卡片应跳转到好友详情页');
    });
  });

  group('FriendProfilePage 编辑按钮导航（修复点A：push 替代 go）', () {
    testWidgets('点击编辑使用 push，返回后回到详情页', (tester) async {
      await _insertFriend(id: 'edit-friend-1', name: '编辑测试好友');

      await tester.pumpWidget(_buildTestApp(db, initialLocation: '/bond/friend/edit-friend-1'));
      await tester.pumpAndSettle();

      // 验证在详情页
      expect(find.text('档案详情'), findsOneWidget);

      // 点击编辑按钮（文字"编辑档案"）
      await tester.tap(find.text('编辑档案'));
      await tester.pumpAndSettle();

      // 验证导航到了创建/编辑页（PlaceholderPage 标识）
      expect(find.text('friend-create'), findsOneWidget);

      // 点击返回按钮
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 验证回到了详情页（而非羁绊首页）
      expect(find.text('档案详情'), findsOneWidget,
          reason: 'push 导航 pop 后应回到详情页，而非羁绊首页');
    });
  });

  group('FriendProfilePage 收藏按钮（修复点：使用 FriendDao.updateFavorite）', () {
    testWidgets('点击收藏按钮切换 isFavorite 状态并记录 ChangeLog', (tester) async {
      await _insertFriend(id: 'fav-friend-1', name: '收藏测试好友', isFavorite: false);

      await tester.pumpWidget(_buildTestApp(db, initialLocation: '/bond/friend/fav-friend-1'));
      await tester.pumpAndSettle();

      // 验证在详情页
      expect(find.text('档案详情'), findsOneWidget);

      // 验证初始状态：未收藏（favorite_border 图标 + "收藏"文字）
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);

      // 点击收藏按钮
      await tester.tap(find.text('收藏'));
      await tester.pumpAndSettle();

      // 验证状态切换：已收藏（favorite 图标 + "已收藏"文字）
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('已收藏'), findsOneWidget);

      // 验证数据库中 isFavorite 已更新
      final record = await db.friendDao.findById('fav-friend-1');
      expect(record!.isFavorite, isTrue);

      // 验证 ChangeLog 已记录
      final logs = await (db.select(db.changeLogs)
            ..where((t) => t.entityType.equals('friend_records'))
            ..where((t) => t.entityId.equals('fav-friend-1'))
            ..where((t) => t.action.equals('update')))
          .get();
      expect(logs, isNotEmpty, reason: '收藏操作应通过 DAO 记录 ChangeLog');
      expect(logs.first.changedFields, contains('isFavorite'));
    });

    testWidgets('再次点击取消收藏，状态正确切换', (tester) async {
      await _insertFriend(id: 'fav-friend-2', name: '取消收藏测试', isFavorite: true);

      await tester.pumpWidget(_buildTestApp(db, initialLocation: '/bond/friend/fav-friend-2'));
      await tester.pumpAndSettle();

      // 验证初始状态：已收藏
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('已收藏'), findsOneWidget);

      // 点击取消收藏
      await tester.tap(find.text('已收藏'));
      await tester.pumpAndSettle();

      // 验证状态切换：未收藏
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);

      // 验证数据库中 isFavorite 已更新
      final record = await db.friendDao.findById('fav-friend-2');
      expect(record!.isFavorite, isFalse);
    });
  });

  group('FriendProfilePage 返回按钮', () {
    testWidgets('详情页返回按钮 pop 回到首页', (tester) async {
      await _insertFriend(id: 'back-friend-1', name: '返回测试好友');

      await tester.pumpWidget(_buildTestApp(db, initialLocation: '/bond'));
      await tester.pumpAndSettle();

      // 点击好友卡片进入详情页
      await tester.tap(find.text('返回测试好友'));
      await tester.pumpAndSettle();
      expect(find.text('档案详情'), findsOneWidget);

      // 点击返回按钮
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 验证回到首页（好友名称重新出现）
      expect(find.text('返回测试好友'), findsOneWidget,
          reason: '返回后应回到羁绊首页');
    });
  });
}

// === 测试辅助工具 ===

Widget _buildTestApp(
  AppDatabase db, {
  String initialLocation = '/bond',
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
  String initialLocation = '/bond',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/bond',
        builder: (_, __) => const BondPage(),
        routes: [
          GoRoute(
            path: 'friend/create',
            builder: (_, __) => const _PlaceholderPage('friend-create', showBack: true),
          ),
          GoRoute(
            path: 'friend/:id',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              return FriendProfilePage(friendId: id);
            },
          ),
        ],
      ),
    ],
  );
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
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Center(child: Text(label)),
    );
  }
}

Future<Directory> _setUpCommonMocks() async {
  final tempDir = await Directory.systemTemp.createTemp('bond_test_');
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
