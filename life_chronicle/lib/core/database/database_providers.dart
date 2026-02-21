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
