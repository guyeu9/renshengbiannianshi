// 0.1.166 Provider层状态同步可靠性测试
// 防护 0.1.159 同类 bug：Provider 在 DAO 数据变化后必须正确刷新
// 此文件测试 FutureProvider 通过 profileRevisionProvider 触发重新查询的同步机制，
// 验证 DAO 数据变化 + revision 递增后 Provider 返回新值。
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import '../test_utils/test_database.dart';
import '../test_utils/test_data_factory.dart';

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

  // 构造 UserProfilesCompanion.insert 的辅助方法
  Future<void> insertUserProfile({
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
            signature: signature != null ? Value(signature) : const Value.absent(),
            createdAt: createdAt ?? now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  // ==================== userDisplayNameProvider ====================
  group('userDisplayNameProvider（0.1.166 Provider层状态同步可靠性测试）', () {
    // dp-stream-name-A: 初始状态返回"未设置"
    test('dp-stream-name-A 初始状态返回"未设置"', () async {
      final name = await container.read(userDisplayNameProvider.future);
      expect(name, equals('未设置'));
    });

    // dp-stream-name-B: 插入user_profiles后返回实际用户名
    test('dp-stream-name-B 插入user_profiles后返回实际用户名', () async {
      await insertUserProfile(displayName: '张三');

      final name = await container.read(userDisplayNameProvider.future);
      expect(name, equals('张三'));
    });

    // dp-stream-name-C: profileRevisionProvider变化后重新查询
    test('dp-stream-name-C profileRevisionProvider变化后重新查询', () async {
      await insertUserProfile(displayName: '旧名字');
      final name1 = await container.read(userDisplayNameProvider.future);
      expect(name1, equals('旧名字'));

      // 更新 DAO 数据
      await insertUserProfile(displayName: '新名字');

      // 触发重新查询
      container.read(profileRevisionProvider.notifier).state++;

      final name2 = await container.read(userDisplayNameProvider.future);
      expect(name2, equals('新名字'));
    });

    // dp-stream-name-edge1: displayName为空时返回"未设置"
    test('dp-stream-name-edge1 displayName为空时返回"未设置"', () async {
      await insertUserProfile(displayName: '');

      final name = await container.read(userDisplayNameProvider.future);
      expect(name, equals('未设置'));
    });
  });

  // ==================== userRecordDaysProvider ====================
  group('userRecordDaysProvider（0.1.166 Provider层状态同步可靠性测试）', () {
    // dp-stream-days-A: 初始状态返回0
    test('dp-stream-days-A 初始状态返回0', () async {
      final days = await container.read(userRecordDaysProvider.future);
      expect(days, equals(0));
    });

    // dp-stream-days-B: 插入user_profiles后返回正确天数
    test('dp-stream-days-B 插入user_profiles后返回正确天数', () async {
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      await insertUserProfile(createdAt: tenDaysAgo);

      final days = await container.read(userRecordDaysProvider.future);
      expect(days, greaterThanOrEqualTo(10));
    });

    // dp-stream-days-edge1: 无user_profiles但有其他记录时返回最早记录天数
    test('dp-stream-days-edge1 无user_profiles但有其他记录时返回最早记录天数', () async {
      final olderRecordDate = DateTime.now().subtract(const Duration(days: 500));
      await db.into(db.momentRecords).insert(
            TestDataFactory.createMomentRecord(recordDate: olderRecordDate),
          );
      await db.foodDao.upsert(
        TestDataFactory.createFoodRecord(
            recordDate: DateTime.now().subtract(const Duration(days: 3))),
      );

      final days = await container.read(userRecordDaysProvider.future);
      expect(days, greaterThanOrEqualTo(500));
    });
  });

  // ==================== userSignatureProvider ====================
  group('userSignatureProvider（0.1.166 Provider层状态同步可靠性测试）', () {
    // dp-stream-sig-A: 初始状态返回默认签名
    test('dp-stream-sig-A 初始状态返回默认签名', () async {
      final lines = await container.read(userSignatureProvider.future);
      expect(lines, equals([
        '我频繁的记录着，我热烈的分享着',
        '你要知道诗人的一生也可能非常普通',
      ]));
    });

    // dp-stream-sig-B: 插入user_profiles后返回实际签名
    test('dp-stream-sig-B 插入user_profiles后返回实际签名', () async {
      await insertUserProfile(signature: '这是我的签名');

      final lines = await container.read(userSignatureProvider.future);
      expect(lines, equals(['这是我的签名']));
    });

    // dp-stream-sig-C: profileRevisionProvider变化后重新查询
    test('dp-stream-sig-C profileRevisionProvider变化后重新查询', () async {
      await insertUserProfile(signature: '旧签名');
      final lines1 = await container.read(userSignatureProvider.future);
      expect(lines1, equals(['旧签名']));

      // 更新 DAO 数据
      await insertUserProfile(signature: '新签名');

      // 触发重新查询
      container.read(profileRevisionProvider.notifier).state++;

      final lines2 = await container.read(userSignatureProvider.future);
      expect(lines2, equals(['新签名']));
    });

    // dp-stream-sig-edge1: signature为空时返回默认签名
    test('dp-stream-sig-edge1 signature为空时返回默认签名', () async {
      await insertUserProfile(signature: null);

      final lines = await container.read(userSignatureProvider.future);
      expect(lines, equals([
        '我频繁的记录着，我热烈的分享着',
        '你要知道诗人的一生也可能非常普通',
      ]));
    });
  });

  // ==================== profileRevisionProvider ====================
  group('profileRevisionProvider（0.1.166 Provider层状态同步可靠性测试）', () {
    // dp-stream-rev-A: 初始值为0
    test('dp-stream-rev-A 初始值为0', () {
      expect(container.read(profileRevisionProvider), equals(0));
    });

    // dp-stream-rev-B: 修改值后触发依赖provider重新计算
    test('dp-stream-rev-B 修改值后触发依赖provider重新计算', () async {
      await insertUserProfile(displayName: '旧名字');
      final name1 = await container.read(userDisplayNameProvider.future);
      expect(name1, equals('旧名字'));

      await insertUserProfile(displayName: '新名字');

      // 递增 revision 触发重新查询
      container.read(profileRevisionProvider.notifier).state++;

      final name2 = await container.read(userDisplayNameProvider.future);
      expect(name2, equals('新名字'));
    });
  });
}
