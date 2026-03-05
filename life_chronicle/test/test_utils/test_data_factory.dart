import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:life_chronicle/core/database/app_database.dart';

class TestDataFactory {
  static FoodRecordsCompanion createFoodRecord({
    String? id,
    String? title,
    String? content,
    double? rating,
    String? city,
    DateTime? recordDate,
  }) {
    final now = DateTime.now();
    return FoodRecordsCompanion.insert(
      id: id ?? 'test-food-${now.microsecondsSinceEpoch}',
      title: title ?? 'Test Food',
      content: Value(content),
      rating: Value(rating ?? 4.0),
      city: Value(city),
      recordDate: recordDate ?? now,
      createdAt: now,
      updatedAt: now,
    );
  }

  static MomentRecordsCompanion createMomentRecord({
    String? id,
    String? content,
    String? mood,
    String? city,
    DateTime? recordDate,
  }) {
    final now = DateTime.now();
    return MomentRecordsCompanion.insert(
      id: id ?? 'test-moment-${now.microsecondsSinceEpoch}',
      content: Value(content),
      mood: mood ?? '开心',
      city: Value(city),
      recordDate: recordDate ?? now,
      createdAt: now,
      updatedAt: now,
    );
  }

  static FriendRecordsCompanion createFriendRecord({
    String? id,
    String? name,
    String? groupName,
    String? impressionTags,
    DateTime? meetDate,
  }) {
    final now = DateTime.now();
    return FriendRecordsCompanion.insert(
      id: id ?? 'test-friend-${now.microsecondsSinceEpoch}',
      name: name ?? 'Test Friend',
      groupName: Value(groupName),
      impressionTags: Value(impressionTags),
      meetDate: Value(meetDate),
      createdAt: now,
      updatedAt: now,
    );
  }

  static TravelRecordsCompanion createTravelRecord({
    String? id,
    String? tripId,
    String? title,
    String? content,
    String? city,
    DateTime? recordDate,
  }) {
    final now = DateTime.now();
    return TravelRecordsCompanion.insert(
      id: id ?? 'test-travel-${now.microsecondsSinceEpoch}',
      tripId: tripId ?? 'test-trip-${now.microsecondsSinceEpoch}',
      title: Value(title ?? 'Test Travel'),
      content: Value(content),
      city: Value(city),
      recordDate: recordDate ?? now,
      createdAt: now,
      updatedAt: now,
    );
  }

  static GoalRecordsCompanion createGoalRecord({
    String? id,
    String? title,
    String? category,
    String? note,
    int? targetYear,
    DateTime? recordDate,
  }) {
    final now = DateTime.now();
    return GoalRecordsCompanion.insert(
      id: id ?? 'test-goal-${now.microsecondsSinceEpoch}',
      level: 'yearly',
      title: title ?? 'Test Goal',
      category: Value(category ?? '学习'),
      note: Value(note),
      targetYear: Value(targetYear ?? now.year),
      recordDate: recordDate ?? now,
      createdAt: now,
      updatedAt: now,
    );
  }

  static TimelineEventsCompanion createTimelineEvent({
    String? id,
    String? title,
    String? eventType,
    String? note,
    DateTime? startAt,
  }) {
    final now = DateTime.now();
    return TimelineEventsCompanion.insert(
      id: id ?? 'test-event-${now.microsecondsSinceEpoch}',
      title: title ?? 'Test Event',
      eventType: eventType ?? 'moment',
      note: Value(note),
      startAt: Value(startAt ?? now),
      recordDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  static EntityLinksCompanion createEntityLink({
    String? id,
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    String? linkType,
  }) {
    final now = DateTime.now();
    return EntityLinksCompanion.insert(
      id: id ?? 'test-link-${now.microsecondsSinceEpoch}',
      sourceType: sourceType,
      sourceId: sourceId,
      targetType: targetType,
      targetId: targetId,
      linkType: Value(linkType ?? 'manual'),
      createdAt: now,
    );
  }

  static TripsCompanion createTrip({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    return TripsCompanion.insert(
      id: id ?? 'test-trip-${now.microsecondsSinceEpoch}',
      name: name ?? 'Test Trip',
      startDate: Value(startDate),
      endDate: Value(endDate),
      createdAt: now,
      updatedAt: now,
    );
  }
}
