import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:life_chronicle/features/profile/presentation/profile_page.dart';
import 'package:life_chronicle/features/profile/presentation/reminder_settings_page.dart';
import 'package:life_chronicle/features/profile/presentation/ai_model_management_page.dart';
import 'package:life_chronicle/features/profile/presentation/data_management_page.dart';
import 'package:life_chronicle/features/profile/presentation/backup_log_page.dart';
import 'package:life_chronicle/features/profile/presentation/amap_log_page.dart';
import 'package:life_chronicle/features/profile/presentation/system_log_page.dart';

import '../../../test_utils/test_data_factory.dart';

const _kRouteHome = '/';
const _kRouteProfile = '/profile';
const _kRouteChronicleConfig = '/profile/chronicle-config';
const _kRouteFavorites = '/profile/favorites';
const _kRouteChronicleManage = '/profile/chronicle-manage';
const _kRouteAnnualReports = '/profile/annual-reports';
const _kRouteDataManagement = '/profile/data-management';
const _kRouteModuleManagement = '/profile/module-management';
const _kRouteUniversalLink = '/profile/universal-link';
const _kRouteAiModels = '/profile/ai-models';
const _kRoutePersonal = '/profile/personal';
const _kRouteReminder = '/profile/reminder';
const _kRoutePrivacy = '/profile/privacy';
const _kRouteHelp = '/profile/help';
const _kRouteBackupLog = '/profile/backup-log';
const _kRouteAmapLog = '/profile/amap-log';
const _kRouteSystemLog = '/profile/system-log';

GoRouter createTestGoRouter({
  String initialLocation = _kRouteProfile,
  List<NavigatorObserver>? observers,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    observers: observers ?? [],
    routes: [
      GoRoute(path: _kRouteHome, builder: (_, __) => const _PlaceholderPage('home')),
      GoRoute(path: _kRouteProfile, builder: (_, __) => const ProfilePage()),
      GoRoute(path: _kRouteChronicleConfig, builder: (_, __) => const _PlaceholderPage('chronicle-config')),
      GoRoute(path: _kRouteFavorites, builder: (_, __) => const _PlaceholderPage('favorites')),
      GoRoute(path: _kRouteChronicleManage, builder: (_, __) => const _PlaceholderPage('chronicle-manage')),
      GoRoute(path: _kRouteAnnualReports, builder: (_, __) => const _PlaceholderPage('annual-reports')),
      GoRoute(path: _kRouteDataManagement, builder: (_, __) => const DataManagementPage()),
      GoRoute(path: _kRouteModuleManagement, builder: (_, __) => const _PlaceholderPage('module-management')),
      GoRoute(path: _kRouteUniversalLink, builder: (_, __) => const _PlaceholderPage('universal-link')),
      GoRoute(path: _kRouteAiModels, builder: (_, __) => const AiModelManagementPage()),
      GoRoute(path: _kRoutePersonal, builder: (_, __) => const _PlaceholderPage('personal-profile')),
      GoRoute(path: _kRouteReminder, builder: (_, __) => const ReminderSettingsPage()),
      GoRoute(path: _kRoutePrivacy, builder: (_, __) => const _PlaceholderPage('privacy-security')),
      GoRoute(path: _kRouteHelp, builder: (_, __) => const _PlaceholderPage('help-feedback')),
      GoRoute(path: _kRouteBackupLog, builder: (_, __) => const BackupLogPage()),
      GoRoute(path: _kRouteAmapLog, builder: (_, __) => const AmapLogPage()),
      GoRoute(path: _kRouteSystemLog, builder: (_, __) => const SystemLogPage()),
    ],
  );
}

Widget buildProfileTestApp(
  AppDatabase db, {
  String initialLocation = _kRouteProfile,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      ...overrides,
    ],
    child: MaterialApp.router(
      routerConfig: createTestGoRouter(initialLocation: initialLocation),
    ),
  );
}

Future<void> insertTestUserProfile(
  AppDatabase db, {
  String id = 'me',
  String displayName = '测试用户',
  String? signature,
  DateTime? createdAt,
}) async {
  final now = DateTime.now();
  await db.into(db.userProfiles).insert(
        UserProfilesCompanion.insert(
          id: id,
          displayName: displayName,
          signature: Value(signature),
          createdAt: createdAt ?? now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrReplace,
      );
}

Future<void> insertTestStatisticsData(AppDatabase db) async {
  await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: '美食1'));
  await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: '美食2'));

  await db.into(db.travelRecords).insert(TestDataFactory.createTravelRecord(title: '旅行1'));

  await db.into(db.momentRecords).insert(TestDataFactory.createMomentRecord(content: '小确幸1'));

  await db.into(db.timelineEvents).insert(
        TestDataFactory.createTimelineEvent(eventType: 'encounter', title: '相遇1'),
      );

  await db.into(db.goalRecords).insert(TestDataFactory.createGoalRecord(title: '目标1'));
}

Future<Directory> setUpCommonMocks() async {
  final tempDir = await Directory.systemTemp.createTemp('profile_test_');
  HttpOverrides.global = _TestHttpOverrides();

  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => tempDir.path);

  return tempDir;
}

void tearDownCommonMocks(Directory tempDir) {
  HttpOverrides.global = null;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), null);
  if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
}

/// 消化 Drift 数据库在 dispose 时调度的 0 时长 Timer（StreamQueryStore.markAsClosed）。
///
/// TestWidgetsFlutterBinding 基于 FakeAsync，Timer.run 不会自动执行，
/// 导致测试结束时出现 "A Timer is still pending" 断言失败。
///
/// 根因：Drift 的 QueryStream 在 StreamBuilder 取消订阅时会通过 `Timer.run`
/// 延迟调度 `markAsClosed`。该 Timer 在 widget tree 被 dispose 时才被调度，
/// 而 flutter_test 的 `_verifyInvariants` 紧接着检查 `!timersPending`，
/// 此时 Timer 仍处于 pending 状态，断言失败。
///
/// 解决：在测试结尾主动把 widget tree 替换为空 SizedBox，触发 StreamBuilder
/// dispose（drift 此时调度 Timer），再多次 pump(Duration.zero) 让 FakeAsync
/// 队列中的 Timer 依次执行。
Future<void> settleDriftTimers(WidgetTester tester, {int cycles = 8}) async {
  // 主动 unmount 当前 widget tree，触发 drift Stream 取消订阅
  await tester.pumpWidget(const SizedBox.shrink());
  // 消化 drift 调度的 0 时长 Timer 链
  for (var i = 0; i < cycles; i++) {
    await tester.pump(Duration.zero);
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
