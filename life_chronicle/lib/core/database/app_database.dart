import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db_connection_io.dart' if (dart.library.html) 'db_connection_web.dart' as dbconn;
import 'tables.dart';

part 'app_database.g.dart';
part 'daos/food_dao.dart';
part 'daos/moment_dao.dart';
part 'daos/friend_dao.dart';
part 'daos/link_dao.dart';

@DriftDatabase(
  tables: [FoodRecords, MomentRecords, FriendRecords, TravelRecords, Trips, TimelineEvents, EntityLinks, LinkLogs, UserProfiles],
  daos: [FoodDao, MomentDao, FriendDao, LinkDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(dbconn.openConnection());
  AppDatabase.connect(super.executor);

  @override
  int get schemaVersion => 7; // 升级到 7，触发全量检查

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

          Future<void> ensureColumn({
            required TableInfo<Table, dynamic> table,
            required GeneratedColumn column,
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
          await ensureTable(timelineEvents);
          await ensureTable(entityLinks);
          await ensureTable(linkLogs);
          await ensureTable(userProfiles);

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
}
