import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import 'data_consistency_checker.dart';

class CleanupResult {
  int foodRecordsDeleted = 0;
  int momentRecordsDeleted = 0;
  int friendRecordsDeleted = 0;
  int travelRecordsDeleted = 0;
  int goalRecordsDeleted = 0;
  int chatSessionsDeleted = 0;
  int orphanedLinksRemoved = 0;
  int orphanedReviewsRemoved = 0;
  int orphanedPostponementsRemoved = 0;
  int orphanedEmbeddingsRemoved = 0;
  int orphanedChatMessagesRemoved = 0;
  DateTime completedAt = DateTime.now();

  int get totalFixed =>
      foodRecordsDeleted +
      momentRecordsDeleted +
      friendRecordsDeleted +
      travelRecordsDeleted +
      goalRecordsDeleted +
      chatSessionsDeleted +
      orphanedLinksRemoved +
      orphanedReviewsRemoved +
      orphanedPostponementsRemoved +
      orphanedEmbeddingsRemoved +
      orphanedChatMessagesRemoved;

  Map<String, dynamic> toJson() => {
        'food_records_deleted': foodRecordsDeleted,
        'moment_records_deleted': momentRecordsDeleted,
        'friend_records_deleted': friendRecordsDeleted,
        'travel_records_deleted': travelRecordsDeleted,
        'goal_records_deleted': goalRecordsDeleted,
        'chat_sessions_deleted': chatSessionsDeleted,
        'orphaned_links_removed': orphanedLinksRemoved,
        'orphaned_reviews_removed': orphanedReviewsRemoved,
        'orphaned_postponements_removed': orphanedPostponementsRemoved,
        'orphaned_embeddings_removed': orphanedEmbeddingsRemoved,
        'orphaned_chat_messages_removed': orphanedChatMessagesRemoved,
        'total_fixed': totalFixed,
        'completed_at': completedAt.toIso8601String(),
      };
}

class DataCleanupService {
  final AppDatabase db;

  DataCleanupService(this.db);

  Future<CleanupResult> cleanupSoftDeletedData({int retentionDays = 30}) async {
    final result = CleanupResult();
    final cutoffDate =
        DateTime.now().subtract(Duration(days: retentionDays));

    await db.transaction(() async {
      result.foodRecordsDeleted = await (db.delete(db.foodRecords))
          .where((t) => t.isDeleted.equals(true))
          .where((t) => t.updatedAt.isSmallerThanValue(cutoffDate))
          .go();

      result.momentRecordsDeleted = await (db.delete(db.momentRecords))
          .where((t) => t.isDeleted.equals(true))
          .where((t) => t.updatedAt.isSmallerThanValue(cutoffDate))
          .go();

      result.friendRecordsDeleted = await (db.delete(db.friendRecords))
          .where((t) => t.isDeleted.equals(true))
          .where((t) => t.updatedAt.isSmallerThanValue(cutoffDate))
          .go();

      result.travelRecordsDeleted = await (db.delete(db.travelRecords))
          .where((t) => t.isDeleted.equals(true))
          .where((t) => t.updatedAt.isSmallerThanValue(cutoffDate))
          .go();

      result.goalRecordsDeleted = await (db.delete(db.goalRecords))
          .where((t) => t.isDeleted.equals(true))
          .where((t) => t.updatedAt.isSmallerThanValue(cutoffDate))
          .go();

      result.chatSessionsDeleted = await (db.delete(db.chatSessions))
          .where((t) => t.isDeleted.equals(true))
          .where((t) => t.updatedAt.isSmallerThanValue(cutoffDate))
          .go();
    });

    return result;
  }

  Future<CleanupResult> cleanupOrphanedData() async {
    final result = CleanupResult();
    final checker = DataConsistencyChecker(db);

    final orphanedLinks = await checker.checkOrphanedLinks();
    for (final issue in orphanedLinks) {
      await (db.delete(db.entityLinks)
            ..where((t) => t.id.equals(issue.entityId)))
          .go();
      result.orphanedLinksRemoved++;
    }

    final orphanedReviews = await checker.checkOrphanedGoalReviews();
    for (final issue in orphanedReviews) {
      await (db.delete(db.goalReviews)
            ..where((t) => t.id.equals(issue.entityId)))
          .go();
      result.orphanedReviewsRemoved++;
    }

    final orphanedPostponements =
        await checker.checkOrphanedGoalPostponements();
    for (final issue in orphanedPostponements) {
      await (db.delete(db.goalPostponements)
            ..where((t) => t.id.equals(issue.entityId)))
          .go();
      result.orphanedPostponementsRemoved++;
    }

    final orphanedEmbeddings = await checker.checkOrphanedEmbeddings();
    for (final issue in orphanedEmbeddings) {
      await (db.delete(db.recordEmbeddings)
            ..where((t) => t.id.equals(issue.entityId)))
          .go();
      result.orphanedEmbeddingsRemoved++;
    }

    final orphanedMessages = await checker.checkOrphanedChatMessages();
    for (final issue in orphanedMessages) {
      await (db.delete(db.chatMessages)
            ..where((t) => t.id.equals(issue.entityId)))
          .go();
      result.orphanedChatMessagesRemoved++;
    }

    return result;
  }

  Future<int> cleanupOldChangeLogs({int retentionDays = 90}) async {
    final cutoffDate =
        DateTime.now().subtract(Duration(days: retentionDays));

    return await (db.delete(db.changeLogs))
        .where((t) => t.timestamp.isSmallerThanValue(cutoffDate))
        .where((t) => t.synced.equals(true))
        .go();
  }

  Future<int> cleanupOldLinkLogs({int retentionDays = 90}) async {
    final cutoffDate =
        DateTime.now().subtract(Duration(days: retentionDays));

    return await (db.delete(db.linkLogs)
        .where((t) => t.createdAt.isSmallerThanValue(cutoffDate)))
        .go();
  }

  Future<Map<String, dynamic>> getStorageStats() async {
    final stats = <String, dynamic>{};

    stats['food_records_total'] =
        await (db.selectOnly(db.foodRecords)..addColumns([db.foodRecords.id]))
            .get()
            .then((r) => r.length);
    stats['food_records_deleted'] = await (db.select(db.foodRecords)
            ..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);

    stats['moment_records_total'] =
        await (db.selectOnly(db.momentRecords)..addColumns([db.momentRecords.id]))
            .get()
            .then((r) => r.length);
    stats['moment_records_deleted'] = await (db.select(db.momentRecords)
            ..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);

    stats['friend_records_total'] =
        await (db.selectOnly(db.friendRecords)..addColumns([db.friendRecords.id]))
            .get()
            .then((r) => r.length);
    stats['friend_records_deleted'] = await (db.select(db.friendRecords)
            ..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);

    stats['travel_records_total'] =
        await (db.selectOnly(db.travelRecords)..addColumns([db.travelRecords.id]))
            .get()
            .then((r) => r.length);
    stats['travel_records_deleted'] = await (db.select(db.travelRecords)
            ..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);

    stats['goal_records_total'] =
        await (db.selectOnly(db.goalRecords)..addColumns([db.goalRecords.id]))
            .get()
            .then((r) => r.length);
    stats['goal_records_deleted'] = await (db.select(db.goalRecords)
            ..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);

    stats['chat_sessions_total'] =
        await (db.selectOnly(db.chatSessions)..addColumns([db.chatSessions.id]))
            .get()
            .then((r) => r.length);
    stats['chat_sessions_deleted'] = await (db.select(db.chatSessions)
            ..where((t) => t.isDeleted.equals(true)))
        .get()
        .then((r) => r.length);

    stats['entity_links_total'] =
        await (db.selectOnly(db.entityLinks)..addColumns([db.entityLinks.id]))
            .get()
            .then((r) => r.length);

    stats['change_logs_total'] =
        await (db.selectOnly(db.changeLogs)..addColumns([db.changeLogs.id]))
            .get()
            .then((r) => r.length);

    stats['record_embeddings_total'] =
        await (db.selectOnly(db.recordEmbeddings)..addColumns([db.recordEmbeddings.id]))
            .get()
            .then((r) => r.length);

    return stats;
  }
}
