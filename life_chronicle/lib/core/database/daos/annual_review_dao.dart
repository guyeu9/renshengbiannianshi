part of '../app_database.dart';

@DriftAccessor(tables: [AnnualReviews])
class AnnualReviewDao extends DatabaseAccessor<AppDatabase> with _$AnnualReviewDaoMixin {
  AnnualReviewDao(super.db);

  Future<void> upsert(AnnualReviewsCompanion entry) async {
    await into(db.annualReviews).insertOnConflictUpdate(entry);
  }

  Future<AnnualReview?> findByYear(int year) {
    return (select(db.annualReviews)..where((t) => t.year.equals(year)))
        .getSingleOrNull();
  }

  Stream<AnnualReview?> watchByYear(int year) {
    return (select(db.annualReviews)..where((t) => t.year.equals(year)))
        .watchSingleOrNull();
  }

  Future<void> deleteByYear(int year) async {
    await (delete(db.annualReviews)..where((t) => t.year.equals(year))).go();
  }
}
