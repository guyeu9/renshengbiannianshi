// 0.1.166 UI层操作后刷新可靠性测试
// 防护 0.1.159 同类 bug：UI 组件在用户操作后必须正确刷新
//
// 0.1.159 修复场景：首页通知红色小数字角标点击"全部已读"后不消失。
// 根因：reminder_dao.dart 的 watchUnreadCount 使用 selectOnly+count 聚合查询，
// Stream 监听在表数据变化时不可靠地发出新值，导致 UI 角标不刷新；
// 同时 reminder_list_page.dart 的 _markAllAsRead 未强制刷新 Provider。
//
// 本测试在 UI 层面验证：用户操作后，首页通知图标红点必须正确刷新。

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:life_chronicle/features/home_schedule/presentation/home_schedule_page.dart';
import 'package:life_chronicle/features/home_schedule/presentation/reminder_list_page.dart';

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

  /// 插入未读 reminder（scheduledAt 设为明天，避免触发首页 _TodayReminder 显示）
  Future<void> insertUnreadReminder({
    String id = 'test-reminder-1',
    String title = '测试提醒',
    String type = 'contact',
    DateTime? scheduledAt,
  }) async {
    final now = DateTime.now();
    await db.reminderDao.insertReminder(
      ReminderRecordsCompanion.insert(
        id: id,
        type: type,
        title: title,
        scheduledAt: scheduledAt ?? now.add(const Duration(days: 1)),
        createdAt: now,
      ),
    );
  }

  /// 查找首页通知图标上的红点（_GlassHeader 中 8x8 红色圆形 Container）
  Finder findHomeNotificationRedDot() {
    return find.byWidgetPredicate((widget) {
      if (widget is! Container) return false;
      final decoration = widget.decoration;
      if (decoration is! BoxDecoration) return false;
      if (decoration.color != const Color(0xFFEF4444)) return false;
      if (decoration.shape != BoxShape.circle) return false;
      // 首页 _HeaderIconButton 红点：8x8，白色 border
      final border = decoration.border;
      if (border is! Border) return false;
      return border.top.color == Colors.white;
    });
  }

  group('（0.1.166）首页通知角标刷新测试 - 防护 0.1.159 同类 bug', () {
    testWidgets('1. 初始状态首页通知图标无红点', (tester) async {
      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 验证通知图标存在
      expect(find.byIcon(Icons.notifications), findsWidgets);

      // 验证无红点
      expect(findHomeNotificationRedDot(), findsNothing,
          reason: '初始无未读提醒时，首页通知图标不应显示红点');
    });

    testWidgets('2. 插入未读 reminder 后首页通知图标显示红点', (tester) async {
      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 初始无红点
      expect(findHomeNotificationRedDot(), findsNothing);

      // 插入未读 reminder
      await insertUnreadReminder(id: 'unread-1', title: '未读提醒1');
      await tester.pumpAndSettle();

      // 验证红点出现
      expect(findHomeNotificationRedDot(), findsOneWidget,
          reason: '插入未读 reminder 后，首页通知图标应显示红点');
    });

    testWidgets('3. 点击通知图标进入提醒列表页，显示未读提醒', (tester) async {
      await insertUnreadReminder(
          id: 'list-reminder-1', title: '列表中的提醒', type: 'contact');
      await insertUnreadReminder(
          id: 'list-reminder-2', title: '列表中的提醒2', type: 'birthday');

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 点击通知图标（_GlassHeader 中的 IconButton）
      final notificationIcon = find.byIcon(Icons.notifications);
      await tester.tap(notificationIcon.first);
      await tester.pumpAndSettle();

      // 验证进入了提醒列表页（标题"提醒"）
      expect(find.text('提醒'), findsOneWidget);

      // 验证未读提醒显示在列表中
      expect(find.text('列表中的提醒'), findsOneWidget);
      expect(find.text('列表中的提醒2'), findsOneWidget);
    });

    testWidgets('4. 点击"全部已读"按钮后，列表中所有提醒标记为已读', (tester) async {
      await insertUnreadReminder(
          id: 'mark-all-1', title: '待已读提醒1', type: 'contact');
      await insertUnreadReminder(
          id: 'mark-all-2', title: '待已读提醒2', type: 'birthday');

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 进入提醒列表页
      await tester.tap(find.byIcon(Icons.notifications).first);
      await tester.pumpAndSettle();

      // 验证初始有未读提醒
      expect(find.text('待已读提醒1'), findsOneWidget);
      expect(find.text('待已读提醒2'), findsOneWidget);

      // 点击"全部已读"按钮
      await tester.tap(find.text('全部已读'));
      await tester.pumpAndSettle();

      // 验证数据库中所有 reminder 都已读
      final reminders = await db.reminderDao.getAllReminders();
      expect(reminders.every((r) => r.isRead), isTrue,
          reason: '点击"全部已读"后，数据库中所有提醒应标记为已读');
    });

    testWidgets('5. 点击"全部已读"后返回首页，通知图标红点消失（核心场景！0.1.159修复的bug）',
        (tester) async {
      // 插入多个未读 reminder
      await insertUnreadReminder(
          id: 'core-1', title: '核心场景提醒1', type: 'contact');
      await insertUnreadReminder(
          id: 'core-2', title: '核心场景提醒2', type: 'birthday');
      await insertUnreadReminder(
          id: 'core-3', title: '核心场景提醒3', type: 'goal');

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 验证初始有红点
      expect(findHomeNotificationRedDot(), findsOneWidget,
          reason: '有未读提醒时，首页通知图标应显示红点');

      // 点击通知图标进入提醒列表页
      await tester.tap(find.byIcon(Icons.notifications).first);
      await tester.pumpAndSettle();

      // 验证在提醒列表页
      expect(find.text('提醒'), findsOneWidget);

      // 点击"全部已读"按钮
      await tester.tap(find.text('全部已读'));
      await tester.pumpAndSettle();

      // 返回首页（点击返回按钮）
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // 核心验证：首页通知图标红点应消失
      expect(findHomeNotificationRedDot(), findsNothing,
          reason: '防护 0.1.159 同类 bug：点击"全部已读"返回首页后，'
              '通知图标红点必须消失');
    });

    testWidgets('6. 单条标记已读后，首页通知图标红点仍显示（还有其他未读）',
        (tester) async {
      // 插入 2 个未读 reminder
      await insertUnreadReminder(
          id: 'single-1', title: '单条已读测试1', type: 'contact');
      await insertUnreadReminder(
          id: 'single-2', title: '单条已读测试2', type: 'birthday');

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 验证初始有红点
      expect(findHomeNotificationRedDot(), findsOneWidget);

      // 进入提醒列表页
      await tester.tap(find.byIcon(Icons.notifications).first);
      await tester.pumpAndSettle();

      // 直接通过 DAO 单条标记已读（模拟点击单条提醒卡片标记已读的效果）
      await db.reminderDao.updateReminder('single-1', isRead: true);
      await tester.pumpAndSettle();

      // 返回首页
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // 验证首页通知图标红点仍显示（因为还有 single-2 未读）
      expect(findHomeNotificationRedDot(), findsOneWidget,
          reason: '单条标记已读后，若仍有其他未读提醒，红点应继续显示');
    });

    testWidgets('7. 所有提醒都标记已读后，首页通知图标红点消失', (tester) async {
      // 插入 2 个未读 reminder
      await insertUnreadReminder(
          id: 'all-1', title: '全部已读测试1', type: 'contact');
      await insertUnreadReminder(
          id: 'all-2', title: '全部已读测试2', type: 'birthday');

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 验证初始有红点
      expect(findHomeNotificationRedDot(), findsOneWidget);

      // 通过 DAO 将所有 reminder 标记已读
      await db.reminderDao.markAllAsRead();
      await tester.pumpAndSettle();

      // 验证红点消失
      expect(findHomeNotificationRedDot(), findsNothing,
          reason: '所有提醒都标记已读后，首页通知图标红点应消失');
    });

    testWidgets('8. 列表页提醒项的红点状态正确显示（未读时显示红点）', (tester) async {
      // 插入未读和已读 reminder
      await insertUnreadReminder(
          id: 'unread-display-1', title: '未读提醒显示', type: 'contact');
      await insertUnreadReminder(
          id: 'read-display-1', title: '已读提醒显示', type: 'contact');

      // 将第二个标记为已读
      await db.reminderDao.updateReminder('read-display-1', isRead: true);

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 进入提醒列表页
      await tester.tap(find.byIcon(Icons.notifications).first);
      await tester.pumpAndSettle();

      // 验证两条提醒都显示
      expect(find.text('未读提醒显示'), findsOneWidget);
      expect(find.text('已读提醒显示'), findsOneWidget);

      // 列表页 _ReminderCard 中的未读红点是 6x6 红色 circle（无 border）
      final cardRedDot = find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) return false;
        if (decoration.color != Colors.red) return false;
        return decoration.shape == BoxShape.circle;
      });
      // 至少有一个未读红点
      expect(cardRedDot, findsWidgets,
          reason: '未读提醒的卡片应显示红点状态');
    });

    testWidgets('9. 列表页"全部已读"按钮在有未读时可点击', (tester) async {
      await insertUnreadReminder(
          id: 'clickable-1', title: '可点击测试', type: 'contact');

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 进入提醒列表页
      await tester.tap(find.byIcon(Icons.notifications).first);
      await tester.pumpAndSettle();

      // 验证"全部已读"按钮存在且可点击
      final markAllButton = find.text('全部已读');
      expect(markAllButton, findsOneWidget);

      final textButton = tester.widget<TextButton>(find.ancestor(
        of: markAllButton,
        matching: find.byType(TextButton),
      ));
      expect(textButton.onPressed, isNotNull,
          reason: '有未读提醒时，"全部已读"按钮应可点击');
    });

    testWidgets('10. 列表页"全部已读"按钮点击后未读数量徽章消失', (tester) async {
      await insertUnreadReminder(
          id: 'zero-1', title: '归零测试1', type: 'contact');
      await insertUnreadReminder(
          id: 'zero-2', title: '归零测试2', type: 'birthday');
      // 使用 goal 类型，避免与 contact/birthday 分组计数冲突
      await insertUnreadReminder(
          id: 'zero-3', title: '归零测试3', type: 'goal');

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 进入提醒列表页
      await tester.tap(find.byIcon(Icons.notifications).first);
      await tester.pumpAndSettle();

      // 验证未读数量徽章存在（AppBar 中红色背景的徽章）
      // AppBar 中的徽章是红色背景 + 白色文字，使用 find.descendant 精确匹配
      final appBarBadge = find.descendant(
        of: find.byType(AppBar),
        matching: find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          if (decoration is! BoxDecoration) return false;
          return decoration.color == Colors.red;
        }),
      );
      expect(appBarBadge, findsOneWidget, reason: '初始应有未读数量徽章');

      // 点击"全部已读"
      await tester.tap(find.text('全部已读'));
      await tester.pumpAndSettle();

      // 验证 AppBar 中的未读数量徽章消失
      expect(appBarBadge, findsNothing,
          reason: '点击"全部已读"后，AppBar 中的未读数量徽章应消失');

      // 同时验证数据库中所有 reminder 都已读
      final reminders = await db.reminderDao.getAllReminders();
      expect(reminders.every((r) => r.isRead), isTrue);
    });

    testWidgets('11. 新增未读提醒后首页红点实时刷新出现（Stream 监听可靠性）',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 初始无红点
      expect(findHomeNotificationRedDot(), findsNothing);

      // 插入未读 reminder
      await insertUnreadReminder(id: 'stream-1', title: '流式刷新测试');
      await tester.pumpAndSettle();

      // 验证红点实时出现（无需重新渲染页面）
      expect(findHomeNotificationRedDot(), findsOneWidget,
          reason: 'Stream 监听应可靠：插入未读 reminder 后，'
              '首页通知图标红点应实时刷新出现');
    });

    testWidgets('12. 直接通过DAO标记全部已读后首页红点实时刷新消失',
        (tester) async {
      // 插入未读 reminder
      await insertUnreadReminder(id: 'realtime-1', title: '实时刷新测试1');
      await insertUnreadReminder(id: 'realtime-2', title: '实时刷新测试2');

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      // 验证初始有红点
      expect(findHomeNotificationRedDot(), findsOneWidget);

      // 直接通过 DAO 标记全部已读
      await db.reminderDao.markAllAsRead();
      await tester.pumpAndSettle();

      // 验证红点实时消失（无需重新进入页面）
      expect(findHomeNotificationRedDot(), findsNothing,
          reason: 'Stream 监听应可靠：标记全部已读后，'
              '首页通知图标红点应实时刷新消失');
    });
  });
}

// === 测试辅助工具 ===

Widget _buildTestApp(AppDatabase db) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp.router(
      routerConfig: _createTestGoRouter(db),
    ),
  );
}

GoRouter _createTestGoRouter(AppDatabase db) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeSchedulePage(),
      ),
      GoRoute(
        path: '/reminders',
        builder: (_, __) => const ReminderListPage(),
      ),
      GoRoute(
        path: '/flashback',
        builder: (_, __) => const _PlaceholderPage('flashback'),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const _PlaceholderPage('profile'),
      ),
    ],
  );
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

Future<Directory> _setUpCommonMocks() async {
  final tempDir = await Directory.systemTemp.createTemp('home_notif_test_');
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
