import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/features/goal/providers/goal_detail_provider.dart';

void main() {
  group('GoalDetailState', () {
    late GoalDetailState state;
    late GoalRecord testGoal;
    late List<GoalReview> testReviews;
    late List<GoalPostponement> testPostponements;
    late List<GoalRecord> testQuarterGoals;
    late List<GoalRecord> testDailyTasks;

    setUp(() {
      final now = DateTime.now();

      testGoal = GoalRecord(
        id: 'yearly-goal-1',
        title: '年度目标：学习 Flutter',
        level: 'yearly',
        isDeleted: false,
        isFavorite: true,
        isCompleted: false,
        isPostponed: false,
        progress: 0.5,
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      );

      testReviews = [
        GoalReview(
          id: 'review-1',
          goalId: 'yearly-goal-1',
          title: '第一季度回顾',
          content: '第一季度进度良好',
          reviewDate: now,
          createdAt: now,
        ),
        GoalReview(
          id: 'review-2',
          goalId: 'yearly-goal-1',
          title: '第二季度回顾',
          content: '第二季度需要加快进度',
          reviewDate: now.add(const Duration(days: 90)),
          createdAt: now.add(const Duration(days: 90)),
        ),
      ];

      testPostponements = [
        GoalPostponement(
          id: 'postpone-1',
          goalId: 'yearly-goal-1',
          reason: '工作太忙',
          newDueDate: now.add(const Duration(days: 365)),
          createdAt: now,
        ),
      ];

      testQuarterGoals = [
        GoalRecord(
          id: 'quarter-goal-1',
          parentId: 'yearly-goal-1',
          title: 'Q1：学习 Dart 基础',
          level: 'quarter',
          isDeleted: false,
          isFavorite: false,
          isCompleted: true,
          isPostponed: false,
          progress: 1.0,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
        GoalRecord(
          id: 'quarter-goal-2',
          parentId: 'yearly-goal-1',
          title: 'Q2：学习 Flutter Widget',
          level: 'quarter',
          isDeleted: false,
          isFavorite: false,
          isCompleted: false,
          isPostponed: false,
          progress: 0.3,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testDailyTasks = [
        GoalRecord(
          id: 'daily-task-1',
          parentId: 'quarter-goal-1',
          title: '每日学习 1 小时',
          level: 'daily',
          isDeleted: false,
          isFavorite: false,
          isCompleted: true,
          isPostponed: false,
          progress: 1.0,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
        GoalRecord(
          id: 'daily-task-2',
          parentId: 'quarter-goal-2',
          title: '每日练习 2 小时',
          level: 'daily',
          isDeleted: false,
          isFavorite: false,
          isCompleted: false,
          isPostponed: false,
          progress: 0.0,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      state = GoalDetailState(
        goal: testGoal,
        reviews: testReviews,
        postponements: testPostponements,
        quarterGoals: testQuarterGoals,
        dailyTasks: testDailyTasks,
      );
    });

    test('empty() should return null', () {
      expect(GoalDetailState.empty(), isNull);
    });

    test('should retain all provided data', () {
      expect(state.goal, equals(testGoal));
      expect(state.reviews, equals(testReviews));
      expect(state.postponements, equals(testPostponements));
      expect(state.quarterGoals, equals(testQuarterGoals));
      expect(state.dailyTasks, equals(testDailyTasks));
    });

    test('should have correct goal data', () {
      expect(state.goal.id, equals('yearly-goal-1'));
      expect(state.goal.title, equals('年度目标：学习 Flutter'));
      expect(state.goal.level, equals('yearly'));
      expect(state.goal.progress, equals(0.5));
      expect(state.goal.isCompleted, isFalse);
    });

    test('should have correct number of reviews', () {
      expect(state.reviews.length, equals(2));
    });

    test('should have correct review data', () {
      expect(state.reviews[0].id, equals('review-1'));
      expect(state.reviews[0].title, equals('第一季度回顾'));
      expect(state.reviews[0].content, equals('第一季度进度良好'));
      expect(state.reviews[1].id, equals('review-2'));
      expect(state.reviews[1].title, equals('第二季度回顾'));
      expect(state.reviews[1].content, equals('第二季度需要加快进度'));
    });

    test('should have correct number of postponements', () {
      expect(state.postponements.length, equals(1));
    });

    test('should have correct postponement data', () {
      expect(state.postponements[0].id, equals('postpone-1'));
      expect(state.postponements[0].reason, equals('工作太忙'));
    });

    test('should have correct number of quarter goals', () {
      expect(state.quarterGoals.length, equals(2));
    });

    test('should have correct quarter goal data', () {
      expect(state.quarterGoals[0].id, equals('quarter-goal-1'));
      expect(state.quarterGoals[0].title, equals('Q1：学习 Dart 基础'));
      expect(state.quarterGoals[0].level, equals('quarter'));
      expect(state.quarterGoals[0].parentId, equals('yearly-goal-1'));
      expect(state.quarterGoals[0].isCompleted, isTrue);
    });

    test('should have correct number of daily tasks', () {
      expect(state.dailyTasks.length, equals(2));
    });

    test('should have correct daily task data', () {
      expect(state.dailyTasks[0].id, equals('daily-task-1'));
      expect(state.dailyTasks[0].title, equals('每日学习 1 小时'));
      expect(state.dailyTasks[0].level, equals('daily'));
      expect(state.dailyTasks[0].parentId, equals('quarter-goal-1'));
    });
  });
}
