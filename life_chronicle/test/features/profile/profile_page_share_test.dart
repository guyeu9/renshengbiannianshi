import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';

import '../../test_utils/test_database.dart';
import '../../test_utils/test_data_factory.dart';
import 'helpers/profile_test_helpers.dart';
import 'helpers/mock_share_handler.dart';

void main() {
  // 使用 LiveTestWidgetsFlutterBinding 以避免 FakeAsync 与 Drift 的
  // StreamQueryStore.markAsClosed 调度的 0 时长 Timer 冲突。
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;
  late MockShareHandler shareHandler;

  setUpAll(() async {
    tempDir = await setUpCommonMocks();
    shareHandler = MockShareHandler();
  });

  tearDownAll(() {
    tearDownCommonMocks(tempDir);
  });

  setUp(() async {
    db = createTestDatabase();
    shareHandler.register();
    shareHandler.reset();
  });

  tearDown(() async {
    shareHandler.unregister();
    await closeTestDatabase(db);
  });

  Future<void> tapShareButton(WidgetTester tester) async {
    await tester.pumpWidget(buildProfileTestApp(db));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.share));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();
  }

  group('_shareProfile 分享功能', () {
    testWidgets('点击分享按钮触发 Share.share', (tester) async {
      await insertTestUserProfile(db);

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, isNotNull);
    });

    testWidgets('分享文本包含正确用户名', (tester) async {
      await insertTestUserProfile(db, displayName: '李四');

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, contains('用户名：李四'));
    });

    testWidgets('无用户名时分享文本显示"未设置"', (tester) async {
      await insertTestUserProfile(db, displayName: '');

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, contains('用户名：未设置'));
    });

    testWidgets('分享文本包含正确记录天数', (tester) async {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      await insertTestUserProfile(db, createdAt: thirtyDaysAgo);

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, contains('已记录人生：'));
    });

    testWidgets('分享文本包含正确美食记录数（排除软删除）', (tester) async {
      await insertTestUserProfile(db);

      await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: '美食1'));
      await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: '美食2'));
      final deletedFood = TestDataFactory.createFoodRecord(title: '已删除美食');
      await db.foodDao.upsert(deletedFood);
      await db.foodDao.softDeleteById(deletedFood.id.value, now: DateTime.now());

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, contains('美食记录：2条'));
    });

    testWidgets('分享文本包含正确旅行记录数', (tester) async {
      await insertTestUserProfile(db);

      await db.into(db.travelRecords).insert(TestDataFactory.createTravelRecord(title: '旅行1'));
      await db.into(db.travelRecords).insert(TestDataFactory.createTravelRecord(title: '旅行2'));
      await db.into(db.travelRecords).insert(TestDataFactory.createTravelRecord(title: '旅行3'));

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, contains('旅行记录：3条'));
    });

    testWidgets('分享文本包含正确小确幸记录数', (tester) async {
      await insertTestUserProfile(db);

      await db.into(db.momentRecords).insert(TestDataFactory.createMomentRecord(content: '小确幸1'));
      await db.into(db.momentRecords).insert(TestDataFactory.createMomentRecord(content: '小确幸2'));

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, contains('小确幸记录：2条'));
    });

    testWidgets('分享文本包含正确相遇记录数（仅 encounter 类型）', (tester) async {
      await insertTestUserProfile(db);

      await db.into(db.timelineEvents).insert(
            TestDataFactory.createTimelineEvent(eventType: 'encounter', title: '相遇1'),
          );
      await db.into(db.timelineEvents).insert(
            TestDataFactory.createTimelineEvent(eventType: 'encounter', title: '相遇2'),
          );
      await db.into(db.timelineEvents).insert(
            TestDataFactory.createTimelineEvent(eventType: 'moment', title: '小确幸事件'),
          );

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, contains('相遇记录：2条'));
    });

    testWidgets('分享文本包含正确目标记录数', (tester) async {
      await insertTestUserProfile(db);

      await db.into(db.goalRecords).insert(TestDataFactory.createGoalRecord(title: '目标1'));

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, contains('目标记录：1条'));
    });

    testWidgets('无任何记录时分享文本显示 0', (tester) async {
      await insertTestUserProfile(db);

      await tapShareButton(tester);

      final text = shareHandler.lastSharedText!;
      expect(text, contains('美食记录：0条'));
      expect(text, contains('旅行记录：0条'));
      expect(text, contains('小确幸记录：0条'));
      expect(text, contains('相遇记录：0条'));
      expect(text, contains('目标记录：0条'));
    });

    testWidgets('分享文本包含 subject 参数', (tester) async {
      await insertTestUserProfile(db);

      await tapShareButton(tester);

      expect(shareHandler.lastSharedSubject, equals('人生编年史 - 个人中心'));
    });

    testWidgets('分享文本包含固定签名和来源', (tester) async {
      await insertTestUserProfile(db);

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, contains('我频繁的记录着，我热烈的分享着'));
      expect(shareHandler.lastSharedText, contains('你要知道诗人的一生也可能非常普通'));
      expect(shareHandler.lastSharedText, contains('来自【人生编年史】App'));
    });

    testWidgets('分享文本包含标题头', (tester) async {
      await insertTestUserProfile(db);

      await tapShareButton(tester);

      expect(shareHandler.lastSharedText, contains('【人生编年史 - 个人中心】'));
    });
  });
}
