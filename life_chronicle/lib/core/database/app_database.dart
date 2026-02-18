import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db_connection_io.dart' if (dart.library.html) 'db_connection_web.dart' as dbconn;
import 'tables.dart';
import 'migration_steps.dart';

part 'app_database.g.dart';
part 'daos/food_dao.dart';
part 'daos/moment_dao.dart';
part 'daos/friend_dao.dart';
part 'daos/link_dao.dart';

@DriftDatabase(
  tables: [FoodRecords, MomentRecords, FriendRecords, TravelRecords, Trips, TimelineEvents, EntityLinks, LinkLogs],
  daos: [FoodDao, MomentDao, FriendDao, LinkDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(dbconn.openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onUpgrade: (m, from, to) async {
          final steps = <int, MigrationStep>{
            2: (m) async {
              await m.createTable(foodRecords);
              await m.createTable(momentRecords);
              await m.createTable(friendRecords);
            },
            3: (m) async {
              await m.createTable(travelRecords);
              await m.createTable(trips);
            },
            4: (m) async {
              await m.addColumn(foodRecords, foodRecords.isFavorite);
              await m.addColumn(momentRecords, momentRecords.isFavorite);
              await m.addColumn(friendRecords, friendRecords.isFavorite);
              await m.addColumn(travelRecords, travelRecords.isFavorite);
            },
          };
          await runMigrationSteps(m, from, to, steps: steps);
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
}
