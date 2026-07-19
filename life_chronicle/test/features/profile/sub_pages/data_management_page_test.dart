import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/features/profile/presentation/data_management_page.dart';

import '../../../test_utils/test_database.dart';
import '../helpers/profile_test_helpers.dart';

// flutter_secure_storage 的 MethodChannel，DataManagementPage 在 _loadConfig
// 中会通过 WebDavConfigService 读取 rememberPassword 等字段，需要 mock 避免
// MissingPluginException。
const _secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

void main() {
  // 使用 LiveTestWidgetsFlutterBinding 以避免 FakeAsync 与 Drift 的
  // StreamQueryStore.markAsClosed 调度的 0 时长 Timer 冲突。
  // 详见 helpers/profile_test_helpers.dart 中 settleDriftTimers 的注释。
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await setUpCommonMocks();
    // mock flutter_secure_storage：read 返回 null（无已保存配置），
    // write/delete 返回 null 即可。
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async {
      return null;
    });
  });

  tearDownAll(() {
    tearDownCommonMocks(tempDir);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
  });

  setUp(() async {
    db = createTestDatabase();
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('DataManagementPage 基本渲染', () {
    testWidgets('AppBar 标题与返回按钮正确显示', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/data-management'),
      );
      await tester.pumpAndSettle();

      expect(find.text('数据管理'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      expect(find.byType(DataManagementPage), findsOneWidget);
    });

    testWidgets('初始空状态显示"从未备份"占位', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/data-management'),
      );
      await tester.pumpAndSettle();

      expect(find.text('上次备份时间'), findsOneWidget);
      expect(find.text('从未备份'), findsOneWidget);
    });

    testWidgets('数据统计区域显示模块标签', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/data-management'),
      );
      await tester.pumpAndSettle();

      expect(find.text('数据统计'), findsOneWidget);
      expect(find.text('总记录数'), findsOneWidget);
      expect(find.text('🍜 美食记录'), findsOneWidget);
      expect(find.text('✨ 小确幸'), findsOneWidget);
      expect(find.text('✈️ 旅行'), findsOneWidget);
      expect(find.text('🎯 目标'), findsOneWidget);
      expect(find.text('⏳ 时间线'), findsOneWidget);
      expect(find.text('媒体文件'), findsOneWidget);
      expect(find.text('数据库大小'), findsOneWidget);
    });

    testWidgets('数据导出区域显示四种导出格式', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/data-management'),
      );
      await tester.pumpAndSettle();

      expect(find.text('数据导出'), findsOneWidget);
      expect(find.text('JSON 全量导出'), findsOneWidget);
      expect(find.text('Excel 导出'), findsOneWidget);
      expect(find.text('PDF 导出'), findsOneWidget);
      expect(find.text('Markdown 导出'), findsOneWidget);
    });

    testWidgets('WebDAV 备份配置区域显示字段标签与按钮', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/data-management'),
      );
      await tester.pumpAndSettle();

      // WebDAV 区域位于 ListView 中后段，需要滚动到可见位置。
      await tester.scrollUntilVisible(
        find.text('WebDAV 备份配置'),
        200.0,
      );
      await tester.pumpAndSettle();

      expect(find.text('WebDAV 备份配置'), findsOneWidget);
      expect(find.text('服务器地址'), findsOneWidget);
      expect(find.text('账户名称'), findsOneWidget);
      expect(find.text('账户密码'), findsOneWidget);
      expect(find.text('测试连接'), findsOneWidget);
      expect(find.text('保存配置'), findsOneWidget);
    });

    testWidgets('本地备份区域显示"立即本地备份"和"管理备份文件"按钮', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/data-management'),
      );
      await tester.pumpAndSettle();

      // 滚动到本地备份区域，确保按钮可见。
      await tester.scrollUntilVisible(
        find.text('立即本地备份'),
        200.0,
      );
      await tester.pumpAndSettle();

      expect(find.text('立即本地备份'), findsOneWidget);
      expect(find.text('管理备份文件'), findsOneWidget);
      expect(find.byIcon(Icons.backup), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsWidgets);
    });

    testWidgets('底部操作栏显示"查看日志"、"立即备份"按钮和"地图诊断日志"链接', (tester) async {
      await tester.pumpWidget(
        buildProfileTestApp(db, initialLocation: '/profile/data-management'),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('查看日志'));
      await tester.pumpAndSettle();

      expect(find.text('查看日志'), findsOneWidget);
      expect(find.text('立即备份'), findsOneWidget);
      expect(find.text('地图诊断日志'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    });
  });
}
