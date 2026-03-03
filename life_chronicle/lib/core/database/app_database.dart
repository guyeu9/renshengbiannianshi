import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'db_connection_io.dart' if (dart.library.html) 'db_connection_web.dart' as dbconn;
import 'tables.dart';
import '../services/backup/change_log_recorder.dart';

part 'app_database.g.dart';
part 'daos/food_dao.dart';
part 'daos/moment_dao.dart';
part 'daos/friend_dao.dart';
part 'daos/link_dao.dart';
part 'daos/ai_provider_dao.dart';
part 'daos/change_log_dao.dart';
part 'daos/sync_state_dao.dart';
part 'daos/checklist_dao.dart';
part 'daos/goal_postponement_dao.dart';
part 'daos/goal_review_dao.dart';
part 'daos/backup_log_dao.dart';
part 'daos/annual_review_dao.dart';

@DriftDatabase(
  tables: [FoodRecords, MomentRecords, FriendRecords, TravelRecords, Trips, GoalRecords, TimelineEvents, EntityLinks, LinkLogs, UserProfiles, AiProviders, ChangeLogs, SyncState, ChecklistItems, GoalPostponements, GoalReviews, BackupLogs, AnnualReviews],
  daos: [FoodDao, MomentDao, FriendDao, LinkDao, AiProviderDao, ChangeLogDao, SyncStateDao, ChecklistDao, GoalPostponementDao, GoalReviewDao, BackupLogDao, AnnualReviewDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(dbconn.openConnection());
  AppDatabase.connect(super.executor);

  @override
  int get schemaVersion => 19;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onUpgrade: (m, from, to) async {
          Future<bool> tableExists(String name) async {
            final rows = await customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
              variables: [Variable.withString(name)],
            ).get();
            return rows.isNotEmpty;
          }

          Future<bool> columnExists(String table, String column) async {
            final rows = await customSelect('PRAGMA table_info("$table")').get();
            return rows.any((r) => r.data['name'] == column);
          }

          Future<void> ensureTable(TableInfo<Table, dynamic> table) async {
            final name = table.actualTableName;
            if (!await tableExists(name)) {
              await m.createTable(table);
            }
          }

          Future<void> ensureColumn<T extends Object>({
            required TableInfo<Table, dynamic> table,
            required GeneratedColumn<T> column,
          }) async {
            if (!await columnExists(table.actualTableName, column.name)) {
              await m.addColumn(table, column);
            }
          }

          await ensureTable(foodRecords);
          await ensureTable(momentRecords);
          await ensureTable(friendRecords);
          await ensureTable(travelRecords);
          await ensureTable(trips);
          await ensureTable(goalRecords);
          await ensureTable(timelineEvents);
          await ensureTable(entityLinks);
          await ensureTable(linkLogs);
          await ensureTable(userProfiles);

          await ensureTable(aiProviders);
          await ensureTable(changeLogs);
          await ensureTable(syncState);
          await ensureTable(checklistItems);
          await ensureTable(goalPostponements);
          await ensureTable(goalReviews);
          await ensureTable(backupLogs);
          await ensureTable(annualReviews);

          await ensureColumn(table: foodRecords, column: foodRecords.isFavorite);
          await ensureColumn(table: momentRecords, column: momentRecords.isFavorite);
          await ensureColumn(table: friendRecords, column: friendRecords.isFavorite);
          await ensureColumn(table: travelRecords, column: travelRecords.isFavorite);

          await ensureColumn(table: foodRecords, column: foodRecords.poiName);
          await ensureColumn(table: foodRecords, column: foodRecords.poiAddress);

          await ensureColumn(table: momentRecords, column: momentRecords.poiName);
          await ensureColumn(table: momentRecords, column: momentRecords.poiAddress);
          await ensureColumn(table: momentRecords, column: momentRecords.latitude);
          await ensureColumn(table: momentRecords, column: momentRecords.longitude);

          await ensureColumn(table: travelRecords, column: travelRecords.poiName);
          await ensureColumn(table: travelRecords, column: travelRecords.poiAddress);
          await ensureColumn(table: travelRecords, column: travelRecords.latitude);
          await ensureColumn(table: travelRecords, column: travelRecords.longitude);

          await ensureColumn(table: timelineEvents, column: timelineEvents.poiName);
          await ensureColumn(table: timelineEvents, column: timelineEvents.poiAddress);
          await ensureColumn(table: timelineEvents, column: timelineEvents.latitude);
          await ensureColumn(table: timelineEvents, column: timelineEvents.longitude);

          if (await columnExists('food_records', 'poi_address') && await columnExists('food_records', 'city')) {
            await customStatement('UPDATE food_records SET poi_address = city WHERE poi_address IS NULL AND city IS NOT NULL');
          }
          if (await columnExists('food_records', 'poi_name') && await columnExists('food_records', 'city')) {
            await customStatement('UPDATE food_records SET poi_name = city WHERE poi_name IS NULL AND city IS NOT NULL');
          }
          if (await columnExists('moment_records', 'poi_name') && await columnExists('moment_records', 'city')) {
            await customStatement('UPDATE moment_records SET poi_name = city WHERE poi_name IS NULL AND city IS NOT NULL');
          }
          if (await columnExists('travel_records', 'poi_name') && await columnExists('travel_records', 'destination')) {
            await customStatement('UPDATE travel_records SET poi_name = destination WHERE poi_name IS NULL AND destination IS NOT NULL');
          }

          await ensureColumn(table: travelRecords, column: travelRecords.tags);
          await ensureColumn(table: timelineEvents, column: timelineEvents.tags);

          if (await columnExists('travel_records', 'tags') && await columnExists('travel_records', 'destination')) {
            await customStatement(
              "UPDATE travel_records SET tags = json_array(destination) WHERE tags IS NULL AND destination IS NOT NULL AND destination != ''",
            );
          }
          if (await columnExists('timeline_events', 'tags') && await columnExists('timeline_events', 'note')) {
            await customStatement(
              "UPDATE timeline_events SET tags = json_array(substr(note, instr(note, '分类：') + 9)) WHERE tags IS NULL AND note LIKE '%分类：%'",
            );
          }

          await ensureColumn(table: travelRecords, column: travelRecords.isJournal);

          await ensureColumn(table: foodRecords, column: foodRecords.country);
          await ensureColumn(table: travelRecords, column: travelRecords.country);

          await ensureColumn(table: goalRecords, column: goalRecords.tags);

          await ensureColumn(table: goalRecords, column: goalRecords.isFavorite);
          await ensureColumn(table: timelineEvents, column: timelineEvents.isFavorite);

          if (await columnExists('moment_records', 'scene_tag')) {
            await customStatement(
              "UPDATE moment_records SET scene_tag = json_array(scene_tag) WHERE scene_tag IS NOT NULL AND scene_tag != '' AND json_valid(scene_tag) = 0",
            );
            await customStatement('ALTER TABLE moment_records RENAME COLUMN scene_tag TO tags');
          }
        },
      );

  Future<List<TimelineEvent>> listEventsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return (select(timelineEvents)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.startAt, nulls: NullsOrder.last)]))
        .get();
  }

  Stream<List<TimelineEvent>> watchEventsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return (select(timelineEvents)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.startAt, nulls: NullsOrder.last)]))
        .watch();
  }

  Stream<List<TravelRecord>> watchAllActiveTravelRecords() {
    return (select(travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<TravelRecord?> watchTravelById(String id) {
    return (select(travelRecords)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Stream<List<TravelRecord>> watchTravelTrips() {
    return (select(travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isJournal.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<TravelRecord>> watchTravelJournals(String tripId) {
    return (select(travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isJournal.equals(true))
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<TravelRecord>> watchTravelRecordsByRange(DateTime start, DateTime endExclusive) {
    return (select(travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(endExclusive))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<TimelineEvent>> watchEventsForMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    return (select(timelineEvents)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end)))
        .watch();
  }

  Stream<List<TimelineEvent>> watchEncounterEvents() {
    return (select(timelineEvents)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.eventType.equals('encounter'))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch();
  }

  Stream<List<GoalRecord>> watchAllActiveGoalRecords() {
    return (select(goalRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<GoalRecord>> watchUncompletedYearGoals() {
    return (select(goalRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.level.equals('year'))
          ..where((t) => t.isCompleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<TimelineEvent>> watchEncountersForFriend(String friendId) {
    final query = select(timelineEvents).join([
      innerJoin(
        entityLinks,
        entityLinks.sourceId.equalsExp(timelineEvents.id) &
            entityLinks.sourceType.equals('encounter') &
            entityLinks.targetType.equals('friend') &
            entityLinks.targetId.equals(friendId),
      )
    ]);

    query.where(timelineEvents.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(timelineEvents.recordDate)]);

    return query.map((row) => row.readTable(timelineEvents)).watch();
  }

  Future<void> updateGoalFavorite(String id, {required bool isFavorite, required DateTime now}) async {
    await (update(goalRecords)..where((t) => t.id.equals(id))).write(
      GoalRecordsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updateEncounterFavorite(String id, {required bool isFavorite, required DateTime now}) async {
    await (update(timelineEvents)..where((t) => t.id.equals(id))).write(
      TimelineEventsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(now),
      ),
    );
  }

  Stream<List<FoodRecord>> watchFoodRecordsWithFriends() async* {
    final links = await (select(entityLinks)
          ..where((t) => t.sourceType.equals('food') & t.targetType.equals('friend')))
        .get();
    final foodIds = links.map((l) => l.sourceId).toSet().toList();
    if (foodIds.isEmpty) {
      yield const <FoodRecord>[];
      return;
    }
    yield* (select(foodRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.id.isIn(foodIds))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch();
  }

  Stream<List<MomentRecord>> watchMomentRecordsWithFriends() async* {
    final links = await (select(entityLinks)
          ..where((t) => t.sourceType.equals('moment') & t.targetType.equals('friend')))
        .get();
    final momentIds = links.map((l) => l.sourceId).toSet().toList();
    if (momentIds.isEmpty) {
      yield const <MomentRecord>[];
      return;
    }
    yield* (select(momentRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.id.isIn(momentIds))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch();
  }

  Stream<List<TravelRecord>> watchTravelRecordsWithFriends() async* {
    final links = await (select(entityLinks)
          ..where((t) => t.sourceType.equals('travel') & t.targetType.equals('friend')))
        .get();
    final travelIds = links.map((l) => l.sourceId).toSet().toList();
    if (travelIds.isEmpty) {
      yield const <TravelRecord>[];
      return;
    }
    yield* (select(travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.id.isIn(travelIds))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch();
  }
}
