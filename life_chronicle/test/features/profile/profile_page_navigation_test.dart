import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';

import '../../test_utils/test_database.dart';
import 'helpers/profile_test_helpers.dart';

void main() {
  // 使用 LiveTestWidgetsFlutterBinding 以避免 FakeAsync 与 Drift 的
  // StreamQueryStore.markAsClosed 调度的 0 时长 Timer 冲突。
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

  Future<void> tapAndVerify(WidgetTester tester, Finder tapTarget, String expectedText) async {
    await tester.pumpWidget(buildProfileTestApp(db));
    await tester.pumpAndSettle();

    await tester.ensureVisible(tapTarget);
    await tester.pumpAndSettle();
    await tester.tap(tapTarget);
    await tester.pumpAndSettle();

    expect(find.text(expectedText), findsOneWidget);
  }

  group('ProfilePage 路由导航', () {
    testWidgets('点击返回按钮导航到 home', (tester) async {
      await tapAndVerify(tester, find.byIcon(Icons.arrow_back_ios_new), 'home');
    });

    testWidgets('点击收藏中心导航到 favorites', (tester) async {
      await tapAndVerify(tester, find.text('收藏中心'), 'favorites');
    });

    testWidgets('点击编年史管理导航到 chronicle-manage', (tester) async {
      await tapAndVerify(tester, find.text('编年史管理'), 'chronicle-manage');
    });

    testWidgets('点击年度报告导航到 annual-reports', (tester) async {
      await tapAndVerify(tester, find.text('年度报告'), 'annual-reports');
    });

    testWidgets('点击模块管理导航到 module-management', (tester) async {
      await tapAndVerify(tester, find.text('模块管理'), 'module-management');
    });

    testWidgets('点击万物互联导航到 universal-link', (tester) async {
      await tapAndVerify(tester, find.text('万物互联'), 'universal-link');
    });

    testWidgets('点击个人资料导航到 personal', (tester) async {
      await tapAndVerify(tester, find.text('个人资料'), 'personal-profile');
    });

    testWidgets('点击隐私与安全导航到 privacy', (tester) async {
      await tapAndVerify(tester, find.text('隐私与安全'), 'privacy-security');
    });

    testWidgets('点击帮助与反馈导航到 help', (tester) async {
      await tapAndVerify(tester, find.text('帮助与反馈'), 'help-feedback');
    });
  });
}
