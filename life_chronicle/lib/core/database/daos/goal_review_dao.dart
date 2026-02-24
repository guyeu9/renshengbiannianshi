part of '../app_database.dart';

@DriftAccessor(tables: [GoalReviews])
class GoalReviewDao extends DatabaseAccessor<AppDatabase> with _$GoalReviewDaoMixin {
  GoalReviewDao(super.db);

  Future<void> insert(GoalReviewsCompanion entry) async {
    await into(db.goalReviews).insert(entry);
  }

  Future<void> upsert(GoalReviewsCompanion entry) async {
    await into(db.goalReviews).insertOnConflictUpdate(entry);
  }

  Future<void> updateReview(String id, {required String title, String? content, required DateTime reviewDate, required DateTime now}) async {
    await (update(db.goalReviews)..where((t) => t.id.equals(id))).write(
      GoalReviewsCompanion(
        title: Value(title),
        content: Value(content),
        reviewDate: Value(reviewDate),
        createdAt: Value(now),
      ),
    );
  }

  Future<void> deleteById(String id) async {
    await (delete(db.goalReviews)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteByGoalId(String goalId) async {
    await (delete(db.goalReviews)..where((t) => t.goalId.equals(goalId))).go();
  }

  Future<GoalReview?> findById(String id) {
    return (select(db.goalReviews)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<GoalReview>> watchByGoalId(String goalId) {
    return (select(db.goalReviews)
          ..where((t) => t.goalId.equals(goalId))
          ..orderBy([(t) => OrderingTerm.desc(t.reviewDate)]))
        .watch();
  }

  Future<List<GoalReview>> listByGoalId(String goalId) {
    return (select(db.goalReviews)
          ..where((t) => t.goalId.equals(goalId))
          ..orderBy([(t) => OrderingTerm.desc(t.reviewDate)]))
        .get();
  }
}
