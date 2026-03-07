import 'package:drift/drift.dart' show OrderingMode, OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:rxdart/rxdart.dart';

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

final goalDetailProvider = StreamProvider.family.autoDispose<GoalDetailState?, String>((ref, goalId) {
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
        ..where((t) => t.level.equals('quarter')))
      .watch();

  final dailyTasksStream = (db.select(db.goalRecords)
        ..where((t) => t.isDeleted.equals(false))
        ..where((t) => t.level.equals('daily')))
      .watch();

  return Rx.combineLatest5(
    goalStream,
    reviewsStream,
    postponementsStream,
    quarterGoalsStream,
    dailyTasksStream,
    (goal, reviews, postponements, quarterGoals, dailyTasks) {
      if (goal == null) return null;
      return GoalDetailState(
        goal: goal,
        reviews: reviews,
        postponements: postponements,
        quarterGoals: quarterGoals,
        dailyTasks: dailyTasks.where((t) {
          final parentId = t.parentId;
          if (parentId == null) return false;
          return quarterGoals.any((q) => q.id == parentId);
        }).toList(),
      );
    },
  );
});
