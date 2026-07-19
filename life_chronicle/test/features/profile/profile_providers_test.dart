import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';

import '../../test_utils/test_database.dart';
import '../../test_utils/test_data_factory.dart';
import 'helpers/profile_test_helpers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = createTestDatabase();
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await closeTestDatabase(db);
  });

  group('userDisplayNameProvider', () {
    test('有 displayName 时返回实际用户名', () async {
      await insertTestUserProfile(db, displayName: '张三');

      final name = await container.read(userDisplayNameProvider.future);

      expect(name, equals('张三'));
    });

    test('displayName 为空字符串时返回"未设置"', () async {
      await insertTestUserProfile(db, displayName: '');

      final name = await container.read(userDisplayNameProvider.future);

      expect(name, equals('未设置'));
    });

    test('displayName 为纯空白字符时返回"未设置"', () async {
      await insertTestUserProfile(db, displayName: '   ');

      final name = await container.read(userDisplayNameProvider.future);

      expect(name, equals('未设置'));
    });

    test('user_profiles 不存在时返回"未设置"', () async {
      final name = await container.read(userDisplayNameProvider.future);

      expect(name, equals('未设置'));
    });

    test('profileRevisionProvider 变化后重新查询', () async {
      await insertTestUserProfile(db, displayName: '旧名字');

      final name1 = await container.read(userDisplayNameProvider.future);
      expect(name1, equals('旧名字'));

      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              id: 'me',
              displayName: '新名字',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );

      container.read(profileRevisionProvider.notifier).state++;

      final name2 = await container.read(userDisplayNameProvider.future);
      expect(name2, equals('新名字'));
    });
  });

  group('userRecordDaysProvider', () {
    test('有 createdAt 时返回正确天数差', () async {
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      await insertTestUserProfile(db, createdAt: tenDaysAgo);

      final days = await container.read(userRecordDaysProvider.future);

      expect(days, greaterThanOrEqualTo(10));
    });

    test('无任何记录时返回 0', () async {
      final days = await container.read(userRecordDaysProvider.future);

      expect(days, equals(0));
    });

    test('有多类记录时正确找到最早日期', () async {
      final veryOldDate = DateTime.now().subtract(const Duration(days: 100));
      await insertTestUserProfile(db, createdAt: veryOldDate);

      await db.foodDao.upsert(TestDataFactory.createFoodRecord(
        recordDate: DateTime.now().subtract(const Duration(days: 3)),
      ));
      await db.into(db.momentRecords).insert(TestDataFactory.createMomentRecord(
            recordDate: DateTime.now().subtract(const Duration(days: 5)),
          ));
      await db.into(db.travelRecords).insert(TestDataFactory.createTravelRecord(
            recordDate: DateTime.now().subtract(const Duration(days: 7)),
          ));

      final days = await container.read(userRecordDaysProvider.future);

      expect(days, greaterThanOrEqualTo(100));
    });

    test('软删除的记录不计入计算', () async {
      final recentDate = DateTime.now().subtract(const Duration(days: 3));
      await insertTestUserProfile(db, createdAt: recentDate);

      final foodCompanion = TestDataFactory.createFoodRecord(
        recordDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      await db.foodDao.upsert(foodCompanion);
      final foodId = foodCompanion.id.value;
      await db.foodDao.softDeleteById(foodId, now: DateTime.now());

      await db.into(db.momentRecords).insert(TestDataFactory.createMomentRecord(
            recordDate: recentDate,
          ));

      final days = await container.read(userRecordDaysProvider.future);

      expect(days, lessThan(30));
    });

    test('无 user_profiles 时基于其他表最早记录计算', () async {
      final olderRecordDate = DateTime.now().subtract(const Duration(days: 500));
      await db.into(db.momentRecords).insert(TestDataFactory.createMomentRecord(
            recordDate: olderRecordDate,
          ));

      await db.foodDao.upsert(TestDataFactory.createFoodRecord(
        recordDate: DateTime.now().subtract(const Duration(days: 3)),
      ));

      final days = await container.read(userRecordDaysProvider.future);

      expect(days, greaterThanOrEqualTo(500));
    });
  });

  group('userSignatureProvider', () {
    test('有单行 signature 时返回单元素列表', () async {
      await insertTestUserProfile(db, signature: '这是签名');

      final lines = await container.read(userSignatureProvider.future);

      expect(lines, equals(['这是签名']));
    });

    test('有多行 signature 时按换行符分割', () async {
      await insertTestUserProfile(db, signature: '第一行\n第二行');

      final lines = await container.read(userSignatureProvider.future);

      expect(lines, equals(['第一行', '第二行']));
    });

    test('signature 为空时返回默认签名', () async {
      await insertTestUserProfile(db, signature: null);

      final lines = await container.read(userSignatureProvider.future);

      expect(lines, equals([
        '我频繁的记录着，我热烈的分享着',
        '你要知道诗人的一生也可能非常普通',
      ]));
    });

    test('signature 为空白时返回默认签名', () async {
      await insertTestUserProfile(db, signature: '   ');

      final lines = await container.read(userSignatureProvider.future);

      expect(lines, equals([
        '我频繁的记录着，我热烈的分享着',
        '你要知道诗人的一生也可能非常普通',
      ]));
    });

    test('user_profiles 不存在时返回默认签名', () async {
      final lines = await container.read(userSignatureProvider.future);

      expect(lines, equals([
        '我频繁的记录着，我热烈的分享着',
        '你要知道诗人的一生也可能非常普通',
      ]));
    });
  });

  group('profileRevisionProvider', () {
    test('初始值为 0', () {
      final revision = container.read(profileRevisionProvider);

      expect(revision, equals(0));
    });

    test('修改值后触发依赖 provider 重新计算', () async {
      await insertTestUserProfile(db, displayName: '旧名字');

      final name1 = await container.read(userDisplayNameProvider.future);
      expect(name1, equals('旧名字'));

      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              id: 'me',
              displayName: '新名字',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );

      container.read(profileRevisionProvider.notifier).state++;

      final name2 = await container.read(userDisplayNameProvider.future);
      expect(name2, equals('新名字'));
    });
  });
}
