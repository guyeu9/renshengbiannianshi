import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';

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

  group('BackupLogPage 基本渲染', () {
    testWidgets('页面标题和 3 个筛选 Chip 正确显示', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/backup-log'));
      await tester.pumpAndSettle();

      expect(find.text('备份日志'), findsOneWidget);
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('本地'), findsOneWidget);
      expect(find.text('云端'), findsOneWidget);
    });

    testWidgets('无日志时显示空状态', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/backup-log'));
      await tester.pumpAndSettle();

      expect(find.text('暂无备份记录'), findsOneWidget);
      expect(find.text('完成备份后记录将显示在这里'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('返回按钮可见', (tester) async {
      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/backup-log'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });
  });

  group('备份日志列表', () {
    testWidgets('有日志时显示日志卡片', (tester) async {
      final now = DateTime.now();
      await db.backupLogDao.insert(BackupLogsCompanion.insert(
        id: 'log-1',
        backupType: 'full',
        storageType: 'local',
        fileName: 'local_backup.zip',
        fileSize: const Value(1024),
        status: 'completed',
        recordCount: const Value(10),
        mediaCount: const Value(5),
        startedAt: now,
        completedAt: Value(now),
        createdAt: now,
      ));

      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/backup-log'));
      await tester.pumpAndSettle();

      // 文件名通过 _buildInfoItem 显示为 "文件名: local_backup.zip"
      expect(find.textContaining('local_backup.zip'), findsOneWidget);
      // 类型标签：full + local = 本地全量
      expect(find.text('本地全量'), findsOneWidget);
      // 状态标签：completed = 成功
      expect(find.text('成功'), findsOneWidget);
    });

    testWidgets('筛选"本地"只显示本地日志', (tester) async {
      final now = DateTime.now();
      await db.backupLogDao.insert(BackupLogsCompanion.insert(
        id: 'log-local',
        backupType: 'full',
        storageType: 'local',
        fileName: 'local_only.zip',
        fileSize: const Value(2048),
        status: 'completed',
        startedAt: now,
        completedAt: Value(now),
        createdAt: now,
      ));
      await db.backupLogDao.insert(BackupLogsCompanion.insert(
        id: 'log-cloud',
        backupType: 'full',
        storageType: 'webdav',
        fileName: 'cloud_only.zip',
        fileSize: const Value(4096),
        status: 'completed',
        startedAt: now,
        completedAt: Value(now),
        createdAt: now,
      ));

      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/backup-log'));
      await tester.pumpAndSettle();

      // 默认 "全部" 筛选下，两条日志都可见
      expect(find.textContaining('local_only.zip'), findsOneWidget);
      expect(find.textContaining('cloud_only.zip'), findsOneWidget);
      expect(find.text('本地全量'), findsOneWidget);
      expect(find.text('云端全量'), findsOneWidget);

      // 点击 "本地" 筛选
      await tester.tap(find.text('本地'));
      await tester.pumpAndSettle();

      // 只显示本地日志
      expect(find.textContaining('local_only.zip'), findsOneWidget);
      expect(find.textContaining('cloud_only.zip'), findsNothing);
      expect(find.text('本地全量'), findsOneWidget);
      expect(find.text('云端全量'), findsNothing);
    });

    testWidgets('筛选"云端"只显示云端日志', (tester) async {
      final now = DateTime.now();
      await db.backupLogDao.insert(BackupLogsCompanion.insert(
        id: 'log-local-2',
        backupType: 'incremental',
        storageType: 'local',
        fileName: 'local_inc.zip',
        status: 'completed',
        startedAt: now,
        completedAt: Value(now),
        createdAt: now,
      ));
      await db.backupLogDao.insert(BackupLogsCompanion.insert(
        id: 'log-cloud-2',
        backupType: 'incremental',
        storageType: 'webdav',
        fileName: 'cloud_inc.zip',
        status: 'failed',
        errorMessage: const Value('网络超时'),
        startedAt: now,
        createdAt: now,
      ));

      await tester.pumpWidget(buildProfileTestApp(db, initialLocation: '/profile/backup-log'));
      await tester.pumpAndSettle();

      // 点击 "云端" 筛选
      await tester.tap(find.text('云端'));
      await tester.pumpAndSettle();

      // 只显示云端日志
      expect(find.textContaining('cloud_inc.zip'), findsOneWidget);
      expect(find.textContaining('local_inc.zip'), findsNothing);
      // incremental + webdav = 云端增量
      expect(find.text('云端增量'), findsOneWidget);
      // failed = 失败
      expect(find.text('失败'), findsOneWidget);
      // 错误信息
      expect(find.text('网络超时'), findsOneWidget);
    });
  });
}
