import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables.dart';
import 'migration_steps.dart';

part 'app_database.g.dart';
part 'daos/food_dao.dart';
part 'daos/moment_dao.dart';
part 'daos/friend_dao.dart';
part 'daos/link_dao.dart';

@DriftDatabase(
  tables: [FoodRecords, MomentRecords, FriendRecords, TimelineEvents, EntityLinks, LinkLogs],
  daos: [FoodDao, MomentDao, FriendDao, LinkDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'life_chronicle.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
