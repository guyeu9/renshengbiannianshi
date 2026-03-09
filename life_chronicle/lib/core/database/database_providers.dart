import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final profileRevisionProvider = StateProvider<int>((ref) => 0);
final moduleManagementRevisionProvider = StateProvider<int>((ref) => 0);

final userDisplayNameProvider = FutureProvider<String>((ref) async {
  ref.watch(profileRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final row = await (db.select(db.userProfiles)..where((t) => t.id.equals('me'))).getSingleOrNull();
  final name = (row?.displayName ?? '').trim();
  return name.isEmpty ? '林晓梦' : name;
});

final userRecordDaysProvider = FutureProvider<int>((ref) async {
  ref.watch(profileRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  
  final profile = await (db.select(db.userProfiles)..where((t) => t.id.equals('me'))).getSingleOrNull();
  
  if (profile?.createdAt != null) {
    return DateTime.now().difference(profile!.createdAt).inDays;
  }
  
  final allDates = <DateTime>[];
  
  final foods = await db.foodDao.watchAllActive().first;
  for (final f in foods) {
    allDates.add(f.recordDate);
  }
  
  final moments = await db.momentDao.watchAllActive().first;
  for (final m in moments) {
    allDates.add(m.recordDate);
  }
  
  final travels = await (db.select(db.travelRecords)..where((t) => t.isDeleted.equals(false))).get();
  for (final t in travels) {
    allDates.add(t.recordDate);
  }
  
  final events = await (db.select(db.timelineEvents)..where((t) => t.isDeleted.equals(false))).get();
  for (final e in events) {
    allDates.add(e.recordDate);
  }
  
  final friends = await db.friendDao.watchAllActive().first;
  for (final f in friends) {
    allDates.add(f.updatedAt);
  }
  
  if (allDates.isEmpty) return 0;
  
  allDates.sort();
  return DateTime.now().difference(allDates.first).inDays;
});
