import 'package:drift/drift.dart';

import '../database/app_database.dart';

class RestoreService {
  final AppDatabase db;

  RestoreService(this.db);

  Future<void> restoreFood(String id) async {
    await (db.update(db.foodRecords)..where((t) => t.id.equals(id))).write(
      FoodRecordsCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreMoment(String id) async {
    await (db.update(db.momentRecords)..where((t) => t.id.equals(id))).write(
      MomentRecordsCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreTravel(String id) async {
    await (db.update(db.travelRecords)..where((t) => t.id.equals(id))).write(
      TravelRecordsCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreGoal(String id) async {
    await (db.update(db.goalRecords)..where((t) => t.id.equals(id))).write(
      GoalRecordsCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreFriend(String id) async {
    await (db.update(db.friendRecords)..where((t) => t.id.equals(id))).write(
      FriendRecordsCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreRecord(String type, String id) async {
    switch (type) {
      case 'food':
        await restoreFood(id);
        break;
      case 'moment':
        await restoreMoment(id);
        break;
      case 'travel':
        await restoreTravel(id);
        break;
      case 'goal':
        await restoreGoal(id);
        break;
      case 'friend':
        await restoreFriend(id);
        break;
    }
  }

  Future<void> restoreMultiple(List<({String type, String id})> records) async {
    for (final record in records) {
      await restoreRecord(record.type, record.id);
    }
  }

  Future<List<DeletedRecord>> getAllDeletedRecords() async {
    final records = <DeletedRecord>[];

    final deletedFoods = await (db.select(db.foodRecords)
          ..where((t) => t.isDeleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    for (final f in deletedFoods) {
      records.add(DeletedRecord(
        id: f.id,
        type: 'food',
        typeName: '美食',
        title: f.title,
        deletedAt: f.updatedAt,
      ));
    }

    final deletedMoments = await (db.select(db.momentRecords)
          ..where((t) => t.isDeleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    for (final m in deletedMoments) {
      records.add(DeletedRecord(
        id: m.id,
        type: 'moment',
        typeName: '小确幸',
        title: m.content?.replaceAll(RegExp(r'\n'), ' ').substring(0, m.content!.length > 30 ? 30 : m.content!.length) ?? '无内容',
        deletedAt: m.updatedAt,
      ));
    }

    final deletedTravels = await (db.select(db.travelRecords)
          ..where((t) => t.isDeleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    for (final t in deletedTravels) {
      records.add(DeletedRecord(
        id: t.id,
        type: 'travel',
        typeName: '旅行',
        title: t.title ?? t.destination ?? '未命名旅行',
        deletedAt: t.updatedAt,
      ));
    }

    final deletedGoals = await (db.select(db.goalRecords)
          ..where((t) => t.isDeleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    for (final g in deletedGoals) {
      records.add(DeletedRecord(
        id: g.id,
        type: 'goal',
        typeName: '目标',
        title: g.title,
        deletedAt: g.updatedAt,
      ));
    }

    final deletedFriends = await (db.select(db.friendRecords)
          ..where((t) => t.isDeleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    for (final f in deletedFriends) {
      records.add(DeletedRecord(
        id: f.id,
        type: 'friend',
        typeName: '朋友',
        title: f.name,
        deletedAt: f.updatedAt,
      ));
    }

    records.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
    return records;
  }

  Future<int> getDeletedCount() async {
    int count = 0;

    count += await (db.select(db.foodRecords)..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);
    count += await (db.select(db.momentRecords)..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);
    count += await (db.select(db.travelRecords)..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);
    count += await (db.select(db.goalRecords)..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);
    count += await (db.select(db.friendRecords)..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);

    return count;
  }

  Future<int> permanentlyDelete(String type, String id) async {
    switch (type) {
      case 'food':
        return await (db.delete(db.foodRecords)..where((t) => t.id.equals(id))).go();
      case 'moment':
        return await (db.delete(db.momentRecords)..where((t) => t.id.equals(id))).go();
      case 'travel':
        return await (db.delete(db.travelRecords)..where((t) => t.id.equals(id))).go();
      case 'goal':
        return await (db.delete(db.goalRecords)..where((t) => t.id.equals(id))).go();
      case 'friend':
        return await (db.delete(db.friendRecords)..where((t) => t.id.equals(id))).go();
      default:
        return 0;
    }
  }

  Future<int> emptyTrash() async {
    int count = 0;

    count += await (db.delete(db.foodRecords)..where((t) => t.isDeleted.equals(true))).go();
    count += await (db.delete(db.momentRecords)..where((t) => t.isDeleted.equals(true))).go();
    count += await (db.delete(db.travelRecords)..where((t) => t.isDeleted.equals(true))).go();
    count += await (db.delete(db.goalRecords)..where((t) => t.isDeleted.equals(true))).go();
    count += await (db.delete(db.friendRecords)..where((t) => t.isDeleted.equals(true))).go();

    return count;
  }
}

class DeletedRecord {
  final String id;
  final String type;
  final String typeName;
  final String title;
  final DateTime deletedAt;

  DeletedRecord({
    required this.id,
    required this.type,
    required this.typeName,
    required this.title,
    required this.deletedAt,
  });
}
