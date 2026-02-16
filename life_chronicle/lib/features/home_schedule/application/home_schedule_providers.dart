import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final eventsForSelectedDateProvider = StreamProvider<List<TimelineEvent>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final date = ref.watch(selectedDateProvider);
  return db.watchEventsForDate(date);
});
