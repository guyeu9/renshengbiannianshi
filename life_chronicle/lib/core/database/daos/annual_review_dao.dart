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

  Future<List<AnnualReview>> listAll() {
    return (select(db.annualReviews)
          ..orderBy([(t) => OrderingTerm.desc(t.year), (t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<AnnualReview>> watchAll() {
    return (select(db.annualReviews)
          ..orderBy([(t) => OrderingTerm.desc(t.year), (t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<AnnualReview?> findById(String id) {
    return (select(db.annualReviews)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<AnnualReview?> watchById(String id) {
    return (select(db.annualReviews)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<void> updateTitle(String id, String title) async {
    await (update(db.annualReviews)..where((t) => t.id.equals(id)))
        .write(AnnualReviewsCompanion(title: Value(title), updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteById(String id) async {
    await (delete(db.annualReviews)..where((t) => t.id.equals(id))).go();
  }
}
