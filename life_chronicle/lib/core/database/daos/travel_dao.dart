part of '../app_database.dart';

@DriftAccessor(tables: [TravelRecords, Trips, EntityLinks, LinkLogs])
class TravelDao extends DatabaseAccessor<AppDatabase> with _$TravelDaoMixin {
  TravelDao(super.db);

  late final ChangeLogRecorder _changeLogRecorder = ChangeLogRecorder(db);
  late final Uuid _uuid = const Uuid();

  Future<void> upsert(TravelRecordsCompanion entry) async {
    await into(db.travelRecords).insertOnConflictUpdate(entry);
    await _changeLogRecorder.recordInsert(
      entityType: 'travel_records',
      entityId: entry.id.value,
    );
    final textParts = <String>[];
    if (entry.title.present && entry.title.value != null) {
      textParts.add(entry.title.value!);
    }
    if (entry.content.present && entry.content.value != null) {
      textParts.add(entry.content.value!);
    }
    if (entry.destination.present && entry.destination.value != null) {
      textParts.add(entry.destination.value!);
    }
    final text = textParts.join(' ');
    if (text.isNotEmpty && db.vectorIndexManager != null) {
      await db.vectorIndexManager!.recordInsert(
        entityType: 'travel',
        entityId: entry.id.value,
        text: text,
      );
    }
  }

  Future<void> softDeleteById(String id, {required DateTime now}) async {
    await transaction(() async {
      await (delete(db.entityLinks)
            ..where((t) => t.sourceType.equals('travel'))
            ..where((t) => t.sourceId.equals(id)))
          .go();

      await (delete(db.entityLinks)
            ..where((t) => t.targetType.equals('travel'))
            ..where((t) => t.targetId.equals(id)))
          .go();

      await (update(db.travelRecords)..where((t) => t.id.equals(id))).write(
        TravelRecordsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await _changeLogRecorder.recordDelete(
        entityType: 'travel_records',
        entityId: id,
      );

      if (db.vectorIndexManager != null) {
        await db.vectorIndexManager!.recordDelete(
          entityType: 'travel',
          entityId: id,
        );
      }
    });
  }

  Future<void> updateFavorite(String id, {required bool isFavorite, required DateTime now}) async {
    await (update(db.travelRecords)..where((t) => t.id.equals(id))).write(
      TravelRecordsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordUpdate(
      entityType: 'travel_records',
      entityId: id,
      changedFields: ['isFavorite'],
    );
  }

  Future<void> updateWishlistStatus(String id, {required bool isWishlist, required bool wishlistDone, required DateTime now}) async {
    await (update(db.travelRecords)..where((t) => t.id.equals(id))).write(
      TravelRecordsCompanion(
        isWishlist: Value(isWishlist),
        wishlistDone: Value(wishlistDone),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordUpdate(
      entityType: 'travel_records',
      entityId: id,
      changedFields: ['isWishlist', 'wishlistDone'],
    );
  }

  Future<TravelRecord?> findById(String id) {
    return (select(db.travelRecords)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<TravelRecord?> watchById(String id) {
    return (select(db.travelRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<TravelRecord>> watchAllActive() {
    return (select(db.travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<TravelRecord>> watchTrips() {
    return (select(db.travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isJournal.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<TravelRecord>> watchJournals(String tripId) {
    return (select(db.travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isJournal.equals(true))
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<TravelRecord>> watchByRecordDateRange(DateTime start, DateTime endExclusive) {
    return (select(db.travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(endExclusive))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<TravelRecord>> searchTravel(String query) async {
    if (query.trim().isEmpty) return [];

    final rows = await customSelect(
      '''
      SELECT tr.* FROM travel_records tr
      JOIN travel_records_fts fts ON tr.rowid = fts.rowid
      WHERE travel_records_fts MATCH ? AND tr.is_deleted = 0
      ORDER BY tr.record_date DESC
      ''',
      variables: [Variable.withString(query)],
      readsFrom: {travelRecords},
    ).get();

    return rows.map((row) => db.travelRecords.map(row.data)).toList();
  }

  Stream<Trip?> watchTripById(String id) {
    return (select(db.trips)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<Trip?> findTripById(String id) {
    return (select(db.trips)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertTrip(TripsCompanion entry) async {
    await into(db.trips).insertOnConflictUpdate(entry);
  }

  Future<void> softDeleteTripById(String tripId, {required DateTime now}) async {
    await transaction(() async {
      final travelRecords = await (select(db.travelRecords)
            ..where((t) => t.tripId.equals(tripId))
            ..where((t) => t.isDeleted.equals(false)))
          .get();

      await (update(db.travelRecords)
            ..where((t) => t.tripId.equals(tripId)))
          .write(
            TravelRecordsCompanion(
              isDeleted: const Value(true),
              updatedAt: Value(now),
            ),
          );

      for (final record in travelRecords) {
        await (delete(db.entityLinks)
              ..where((t) => t.sourceType.equals('travel'))
              ..where((t) => t.sourceId.equals(record.id)))
            .go();

        await (delete(db.entityLinks)
              ..where((t) => t.targetType.equals('travel'))
              ..where((t) => t.targetId.equals(record.id)))
            .go();

        await _changeLogRecorder.recordDelete(
          entityType: 'travel_records',
          entityId: record.id,
        );

        if (db.vectorIndexManager != null) {
          await db.vectorIndexManager!.recordDelete(
            entityType: 'travel',
            entityId: record.id,
          );
        }
      }
    });
  }

  Stream<List<TravelRecord>> watchTripsOnly() {
    return (select(db.travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isJournal.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<TravelRecord>> getAllTripsOnly() {
    return (select(db.travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isJournal.equals(false)))
        .get();
  }
}
