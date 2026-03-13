import 'package:flutter/foundation.dart';

import '../database/app_database.dart';

enum ConsistencyIssueSeverity { low, medium, high }

class ConsistencyIssue {
  final String type;
  final ConsistencyIssueSeverity severity;
  final String entityType;
  final String entityId;
  final String description;
  final Map<String, dynamic> details;
  final String suggestedFix;

  ConsistencyIssue({
    required this.type,
    required this.severity,
    required this.entityType,
    required this.entityId,
    required this.description,
    required this.details,
    required this.suggestedFix,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'severity': severity.name,
    'entity_type': entityType,
    'entity_id': entityId,
    'description': description,
    'details': details,
    'suggested_fix': suggestedFix,
  };
}

class ConsistencyReport {
  final List<ConsistencyIssue> issues = [];
  DateTime checkedAt = DateTime.now();

  bool get hasIssues => issues.isNotEmpty;

  int get highSeverityCount =>
      issues.where((i) => i.severity == ConsistencyIssueSeverity.high).length;

  int get mediumSeverityCount =>
      issues.where((i) => i.severity == ConsistencyIssueSeverity.medium).length;

  int get lowSeverityCount =>
      issues.where((i) => i.severity == ConsistencyIssueSeverity.low).length;

  Map<String, dynamic> toJson() => {
    'checked_at': checkedAt.toIso8601String(),
    'total_issues': issues.length,
    'high_severity': highSeverityCount,
    'medium_severity': mediumSeverityCount,
    'low_severity': lowSeverityCount,
    'issues': issues.map((i) => i.toJson()).toList(),
  };
}

class DataConsistencyChecker {
  final AppDatabase db;

  DataConsistencyChecker(this.db);

  Future<ConsistencyReport> checkAll() async {
    final report = ConsistencyReport();

    report.issues.addAll(await checkOrphanedLinks());
    report.issues.addAll(await checkOrphanedGoalReviews());
    report.issues.addAll(await checkOrphanedGoalPostponements());
    report.issues.addAll(await checkOrphanedEmbeddings());
    report.issues.addAll(await checkOrphanedChatMessages());
    report.issues.addAll(await checkMissingChangeLogs());

    return report;
  }

  Future<List<ConsistencyIssue>> checkOrphanedLinks() async {
    final issues = <ConsistencyIssue>[];
    final links = await db.select(db.entityLinks).get();

    for (final link in links) {
      final sourceExists = await _checkEntityExists(
        link.sourceType,
        link.sourceId,
      );
      final targetExists = await _checkEntityExists(
        link.targetType,
        link.targetId,
      );

      if (!sourceExists || !targetExists) {
        issues.add(ConsistencyIssue(
          type: 'orphaned_link',
          severity: ConsistencyIssueSeverity.high,
          entityType: 'entity_links',
          entityId: link.id,
          description: '链接指向已删除实体',
          details: {
            'source_type': link.sourceType,
            'source_id': link.sourceId,
            'target_type': link.targetType,
            'target_id': link.targetId,
            'source_exists': sourceExists,
            'target_exists': targetExists,
          },
          suggestedFix: '删除此孤立链接',
        ));
      }
    }

    return issues;
  }

  Future<List<ConsistencyIssue>> checkOrphanedGoalReviews() async {
    final issues = <ConsistencyIssue>[];
    final reviews = await db.select(db.goalReviews).get();

    for (final review in reviews) {
      final goalExists = await _checkEntityExists('goal', review.goalId);
      if (!goalExists) {
        issues.add(ConsistencyIssue(
          type: 'orphaned_goal_review',
          severity: ConsistencyIssueSeverity.medium,
          entityType: 'goal_reviews',
          entityId: review.id,
          description: '复盘记录关联的目标不存在',
          details: {'goal_id': review.goalId},
          suggestedFix: '删除此孤立复盘记录',
        ));
      }
    }

    return issues;
  }

  Future<List<ConsistencyIssue>> checkOrphanedGoalPostponements() async {
    final issues = <ConsistencyIssue>[];
    final postponements = await db.select(db.goalPostponements).get();

    for (final postponement in postponements) {
      final goalExists = await _checkEntityExists('goal', postponement.goalId);
      if (!goalExists) {
        issues.add(ConsistencyIssue(
          type: 'orphaned_goal_postponement',
          severity: ConsistencyIssueSeverity.medium,
          entityType: 'goal_postponements',
          entityId: postponement.id,
          description: '延期记录关联的目标不存在',
          details: {'goal_id': postponement.goalId},
          suggestedFix: '删除此孤立延期记录',
        ));
      }
    }

    return issues;
  }

  Future<List<ConsistencyIssue>> checkOrphanedEmbeddings() async {
    final issues = <ConsistencyIssue>[];
    final embeddings = await db.select(db.recordEmbeddings).get();

    for (final embedding in embeddings) {
      final exists = await _checkEntityExists(
        embedding.entityType,
        embedding.entityId,
      );
      if (!exists) {
        issues.add(ConsistencyIssue(
          type: 'orphaned_embedding',
          severity: ConsistencyIssueSeverity.medium,
          entityType: 'record_embeddings',
          entityId: embedding.id,
          description: '向量索引关联的实体不存在',
          details: {
            'entity_type': embedding.entityType,
            'entity_id': embedding.entityId,
          },
          suggestedFix: '删除此孤立向量索引',
        ));
      }
    }

    return issues;
  }

  Future<List<ConsistencyIssue>> checkOrphanedChatMessages() async {
    final issues = <ConsistencyIssue>[];
    final messages = await db.select(db.chatMessages).get();
    final sessionIds = messages.map((m) => m.sessionId).toSet();

    for (final sessionId in sessionIds) {
      final session = await (db.select(db.chatSessions)
            ..where((t) => t.id.equals(sessionId))
            ..limit(1))
          .getSingleOrNull();
      if (session == null || session.isDeleted) {
        final orphanedMessages =
            messages.where((m) => m.sessionId == sessionId);
        for (final msg in orphanedMessages) {
          issues.add(ConsistencyIssue(
            type: 'orphaned_chat_message',
            severity: ConsistencyIssueSeverity.low,
            entityType: 'chat_messages',
            entityId: msg.id,
            description: '消息关联的会话不存在或已删除',
            details: {'session_id': sessionId},
            suggestedFix: '删除此孤立消息',
          ));
        }
      }
    }

    return issues;
  }

  Future<void> fixIssue(ConsistencyIssue issue) async {
    switch (issue.type) {
      case 'orphaned_link':
        await (db.delete(db.entityLinks)..where((t) => t.id.equals(issue.entityId))).go();
        break;
      case 'orphaned_goal_review':
        await (db.delete(db.goalReviews)..where((t) => t.id.equals(issue.entityId))).go();
        break;
      case 'orphaned_goal_postponement':
        await (db.delete(db.goalPostponements)..where((t) => t.id.equals(issue.entityId))).go();
        break;
      case 'orphaned_embedding':
        await (db.delete(db.recordEmbeddings)..where((t) => t.id.equals(issue.entityId))).go();
        break;
      case 'orphaned_chat_message':
        await (db.delete(db.chatMessages)..where((t) => t.id.equals(issue.entityId))).go();
        break;
      case 'missing_changelog':
        await db.into(db.changeLogs).insert(
          ChangeLogsCompanion.insert(
            entityType: issue.entityType,
            entityId: issue.entityId,
            action: 'delete',
            timestamp: DateTime.now(),
          ),
        );
        break;
    }
  }

  Future<int> fixAllIssues(ConsistencyReport report) async {
    int fixedCount = 0;
    for (final issue in report.issues) {
      try {
        await fixIssue(issue);
        fixedCount++;
      } catch (e) {
        debugPrint('Failed to fix issue: $e');
      }
    }
    return fixedCount;
  }

  Future<List<ConsistencyIssue>> checkMissingChangeLogs() async {
    final issues = <ConsistencyIssue>[];

    final softDeletedGoals = await (db.select(db.goalRecords)
          ..where((t) => t.isDeleted.equals(true)))
        .get();

    for (final goal in softDeletedGoals) {
      final hasChangeLog = await _hasDeleteChangeLog(
        'goal_records',
        goal.id,
      );
      if (!hasChangeLog) {
        issues.add(ConsistencyIssue(
          type: 'missing_changelog',
          severity: ConsistencyIssueSeverity.high,
          entityType: 'goal_records',
          entityId: goal.id,
          description: '软删除记录缺少变更日志',
          details: {'deleted_at': goal.updatedAt.toIso8601String()},
          suggestedFix: '补录变更日志',
        ));
      }
    }

    return issues;
  }

  Future<bool> _checkEntityExists(String entityType, String entityId) async {
    switch (entityType) {
      case 'food':
        final record = await (db.select(db.foodRecords)
              ..where((t) => t.id.equals(entityId))
              ..limit(1))
            .getSingleOrNull();
        return record != null && !record.isDeleted;
      case 'moment':
        final record = await (db.select(db.momentRecords)
              ..where((t) => t.id.equals(entityId))
              ..limit(1))
            .getSingleOrNull();
        return record != null && !record.isDeleted;
      case 'friend':
        final record = await (db.select(db.friendRecords)
              ..where((t) => t.id.equals(entityId))
              ..limit(1))
            .getSingleOrNull();
        return record != null && !record.isDeleted;
      case 'travel':
        final record = await (db.select(db.travelRecords)
              ..where((t) => t.id.equals(entityId))
              ..limit(1))
            .getSingleOrNull();
        return record != null && !record.isDeleted;
      case 'goal':
        final record = await (db.select(db.goalRecords)
              ..where((t) => t.id.equals(entityId))
              ..limit(1))
            .getSingleOrNull();
        return record != null && !record.isDeleted;
      default:
        return false;
    }
  }

  Future<bool> _hasDeleteChangeLog(String entityType, String entityId) async {
    final logs = await (db.select(db.changeLogs)
          ..where((t) => t.entityType.equals(entityType))
          ..where((t) => t.entityId.equals(entityId))
          ..where((t) => t.action.equals('delete'))
          ..limit(1))
        .get();
    return logs.isNotEmpty;
  }
}
