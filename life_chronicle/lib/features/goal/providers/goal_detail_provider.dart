import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';

class GoalDetailState {
  const GoalDetailState({
    required this.goal,
    required this.reviews,
    required this.postponements,
    required this.quarterGoals,
    required this.dailyTasks,
  });

  final GoalRecord goal;
  final List<GoalReview> reviews;
  final List<GoalPostponement> postponements;
  final List<GoalRecord> quarterGoals;
  final List<GoalRecord> dailyTasks;

  static GoalDetailState? empty() => null;
}

final goalDetailProvider = StreamProvider.family<GoalDetailState?, String>((ref, goalId) async* {
  final db = ref.watch(appDatabaseProvider);

  final goalStream = (db.select(db.goalRecords)
        ..where((t) => t.isDeleted.equals(false))
        ..where((t) => t.id.equals(goalId))
        ..limit(1))
      .watchSingleOrNull();

  final reviewsStream = (db.select(db.goalReviews)
        ..where((t) => t.goalId.equals(goalId))
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .watch();

  final postponementsStream = (db.select(db.goalPostponements)
        ..where((t) => t.goalId.equals(goalId))
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .watch();

  final quarterGoalsStream = (db.select(db.goalRecords)
        ..where((t) => t.isDeleted.equals(false))
        ..where((t) => t.parentId.equals(goalId))
        ..where((t) => t.level.equals('quarter'))
        .watch());

  final dailyTasksStream = (db.select(db.goalRecords)
        ..where((t) => t.isDeleted.equals(false))
        ..where((t) => t.level.equals('daily')))
      .watch();

  await for (final combined in _combineLatest5(
    goalStream,
    reviewsStream,
    postponementsStream,
    quarterGoalsStream,
    dailyTasksStream,
  )) {
    final goal = combined.$1;
    if (goal == null) {
      yield null;
      continue;
    }
    yield GoalDetailState(
      goal: goal,
      reviews: combined.$2,
      postponements: combined.$3,
      quarterGoals: combined.$4,
      dailyTasks: combined.$5.where((t) {
        final parentId = t.parentId;
        if (parentId == null) return false;
        return combined.$4.any((q) => q.id == parentId);
      }).toList(),
    );
  }
});

Stream<(T1, T2, T3, T4, T5)> _combineLatest5<T1, T2, T3, T4, T5>(
  Stream<T1> s1,
  Stream<T2> s2,
  Stream<T3> s3,
  Stream<T4> s4,
  Stream<T5> s5,
) {
  T1? v1;
  T2? v2;
  T3? v3;
  T4? v4;
  T5? v5;
  var hasV1 = false;
  var hasV2 = false;
  var hasV3 = false;
  var hasV4 = false;
  var hasV5 = false;

  final controller = StreamController<(T1, T2, T3, T4, T5)>();

  void emit() {
    if (hasV1 && hasV2 && hasV3 && hasV4 && hasV5) {
      controller.add((v1 as T1, v2 as T2, v3 as T3, v4 as T4, v5 as T5));
    }
  }

  s1.listen((v) { v1 = v; hasV1 = true; emit(); }, onError: controller.addError, onDone: controller.close);
  s2.listen((v) { v2 = v; hasV2 = true; emit(); }, onError: controller.addError);
  s3.listen((v) { v3 = v; hasV3 = true; emit(); }, onError: controller.addError);
  s4.listen((v) { v4 = v; hasV4 = true; emit(); }, onError: controller.addError);
  s5.listen((v) { v5 = v; hasV5 = true; emit(); }, onError: controller.addError);

  return controller.stream;
}
