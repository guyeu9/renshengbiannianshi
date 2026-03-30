import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/config/module_management_config.dart';
import 'package:life_chronicle/core/database/app_database.dart';

List<String> _parseMomentTagsForTest(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final value = raw.trim();
  if (value.startsWith('[')) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false);
      }
    } catch (_) {}
  }
  return value
      .split(RegExp(r'[,\s，、/]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
}

ModuleTag? _matchMomentTagForTest(ModuleConfig momentModule, String? rawTags) {
  final tags = _parseMomentTagsForTest(rawTags);
  if (tags.isEmpty) return null;
  for (final tagName in tags) {
    for (final tag in momentModule.tags) {
      if (tag.name == tagName) {
        return tag;
      }
    }
  }
  return null;
}

bool _isCompletedDailyGoalForTest(GoalRecord record) {
  return record.level == 'daily' && record.isCompleted && !record.isDeleted;
}

DateTime? _foodTimelineTimeForTest(FoodRecord record) {
  return record.recordDate;
}

String? _goalTimelineSubtitleForTest(GoalRecord goal) {
  if (goal.completedAt == null) return null;
  final completedAt = goal.completedAt!;
  return '完成于 ${completedAt.hour.toString().padLeft(2, '0')}:${completedAt.minute.toString().padLeft(2, '0')}';
}

void main() {
  group('home schedule logic', () {
    test('已完成 daily 目标才应进入首页日历链路', () {
      final baseTime = DateTime(2026, 3, 31, 9, 0);
      final completedDaily = GoalRecord(
        id: 'goal-1',
        parentId: 'quarter-1',
        level: 'daily',
        title: '完成晨跑',
        note: null,
        summary: null,
        category: null,
        tags: null,
        progress: 1,
        isCompleted: true,
        isPostponed: false,
        isFavorite: false,
        remindFrequency: null,
        targetYear: null,
        targetQuarter: null,
        targetMonth: null,
        dueDate: null,
        recordDate: baseTime,
        completedAt: baseTime,
        createdAt: baseTime,
        updatedAt: baseTime,
        isDeleted: false,
      );
      final pendingDaily = completedDaily.copyWith(id: 'goal-2', isCompleted: false);
      final completedYear = completedDaily.copyWith(id: 'goal-3', level: 'year');
      final deletedDaily = completedDaily.copyWith(id: 'goal-4', isDeleted: true);

      expect(_isCompletedDailyGoalForTest(completedDaily), isTrue);
      expect(_isCompletedDailyGoalForTest(pendingDaily), isFalse);
      expect(_isCompletedDailyGoalForTest(completedYear), isFalse);
      expect(_isCompletedDailyGoalForTest(deletedDaily), isFalse);
    });

    test('小确幸标签匹配兼容 JSON 数组与逗号串', () {
      final momentModule = ModuleConfig(
        key: 'moment',
        title: '小确幸',
        iconName: 'auto_awesome',
        tagTitle: '场景',
        showOnCalendar: true,
        tags: const [
          ModuleTag(id: 'tag-1', name: '散步', iconName: 'directions_walk', showOnCalendar: true),
          ModuleTag(id: 'tag-2', name: '咖啡', iconName: 'coffee', showOnCalendar: true),
        ],
      );

      expect(_matchMomentTagForTest(momentModule, '["散步","咖啡"]')?.name, '散步');
      expect(_matchMomentTagForTest(momentModule, '咖啡,散步')?.name, '咖啡');
      expect(_matchMomentTagForTest(momentModule, '未知标签'), isNull);
    });

    test('首页美食日程时间应使用记录时间而非创建时间', () {
      final recordDate = DateTime(2026, 3, 1, 8, 30);
      final food = FoodRecord(
        id: 'food-1',
        title: '补录早餐',
        content: '豆浆油条',
        images: null,
        tags: null,
        rating: null,
        pricePerPerson: null,
        link: null,
        latitude: null,
        longitude: null,
        poiName: null,
        poiAddress: null,
        city: null,
        country: null,
        mood: null,
        isWishlist: false,
        isFavorite: false,
        wishlistDone: false,
        recordDate: recordDate,
        createdAt: DateTime(2026, 3, 31, 22, 0),
        updatedAt: DateTime(2026, 3, 31, 22, 0),
        isDeleted: false,
      );

      expect(_foodTimelineTimeForTest(food), recordDate);
    });

    test('目标日程副标题展示完成时间', () {
      final completedAt = DateTime(2026, 3, 31, 21, 5);
      final goal = GoalRecord(
        id: 'goal-1',
        parentId: 'quarter-1',
        level: 'daily',
        title: '阅读 30 分钟',
        note: null,
        summary: null,
        category: null,
        tags: null,
        progress: 1,
        isCompleted: true,
        isPostponed: false,
        isFavorite: false,
        remindFrequency: null,
        targetYear: null,
        targetQuarter: null,
        targetMonth: null,
        dueDate: null,
        recordDate: DateTime(2026, 3, 31, 20, 0),
        completedAt: completedAt,
        createdAt: completedAt,
        updatedAt: completedAt,
        isDeleted: false,
      );
      final goalWithoutCompletedAt = GoalRecord(
        id: goal.id,
        parentId: goal.parentId,
        level: goal.level,
        title: goal.title,
        note: goal.note,
        summary: goal.summary,
        category: goal.category,
        tags: goal.tags,
        progress: goal.progress,
        isCompleted: goal.isCompleted,
        isPostponed: goal.isPostponed,
        isFavorite: goal.isFavorite,
        remindFrequency: goal.remindFrequency,
        targetYear: goal.targetYear,
        targetQuarter: goal.targetQuarter,
        targetMonth: goal.targetMonth,
        dueDate: goal.dueDate,
        recordDate: goal.recordDate,
        completedAt: null,
        createdAt: goal.createdAt,
        updatedAt: goal.updatedAt,
        isDeleted: goal.isDeleted,
      );

      expect(_goalTimelineSubtitleForTest(goal), '完成于 21:05');
      expect(_goalTimelineSubtitleForTest(goalWithoutCompletedAt), isNull);
    });
  });
}
