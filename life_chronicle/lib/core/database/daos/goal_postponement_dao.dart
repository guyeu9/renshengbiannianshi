part of '../app_database.dart';

@DriftAccessor(tables: [GoalPostponements])
class GoalPostponementDao extends DatabaseAccessor<AppDatabase> with _$GoalPostponementDaoMixin {
  GoalPostponementDao(super.db);

  Future<void> insert(GoalPostponementsCompanion entry) async {
    await into(db.goalPostponements).insert(entry);
  }

  Future<void> upsert(GoalPostponementsCompanion entry) async {
    await into(db.goalPostponements).insertOnConflictUpdate(entry);
  }

  Future<void> deleteById(String id) async {
    await (delete(db.goalPostponements)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteByGoalId(String goalId) async {
    await (delete(db.goalPostponements)..where((t) => t.goalId.equals(goalId))).go();
  }

  Future<GoalPostponement?> findById(String id) {
    return (select(db.goalPostponements)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<GoalPostponement>> watchByGoalId(String goalId) {
    return (select(db.goalPostponements)
          ..where((t) => t.goalId.equals(goalId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<GoalPostponement>> listByGoalId(String goalId) {
    return (select(db.goalPostponements)
          ..where((t) => t.goalId.equals(goalId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }
}
