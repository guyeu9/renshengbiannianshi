import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'backup/change_log_recorder.dart';
import '../../features/ai_historian/services/context_builder.dart';

class DeleteService {
  final AppDatabase db;
  final ChangeLogRecorder _changeLogRecorder;

  DeleteService(this.db) : _changeLogRecorder = ChangeLogRecorder(db);

  Future<void> deleteFood(String id) async {
    await db.transaction(() async {
      final now = DateTime.now();

      await _deleteLinksForEntity('food', id);

      await db.embeddingDao.deleteByEntity('food', id);

      await (db.update(db.foodRecords)..where((t) => t.id.equals(id))).write(
        FoodRecordsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await _changeLogRecorder.recordDelete(
        entityType: 'food_records',
        entityId: id,
      );
    });
    
    ContextBuilder.clearCache();
  }

  Future<void> hardDeleteMoment(String id) async {
    await db.transaction(() async {
      await _deleteLinksForEntity('moment', id);

      await db.embeddingDao.deleteByEntity('moment', id);

      await (db.delete(db.timelineEvents)
            ..where((t) => t.id.equals(id))
            ..where((t) => t.eventType.equals('moment')))
          .go();

      await (db.delete(db.momentRecords)..where((t) => t.id.equals(id))).go();

      await _changeLogRecorder.recordDelete(
        entityType: 'moment_records',
        entityId: id,
      );
    });
    
    ContextBuilder.clearCache();
  }

  Future<void> softDeleteMoment(String id) async {
    await db.transaction(() async {
      final now = DateTime.now();

      await _deleteLinksForEntity('moment', id);

      await db.embeddingDao.deleteByEntity('moment', id);

      await (db.update(db.momentRecords)..where((t) => t.id.equals(id))).write(
        MomentRecordsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await _changeLogRecorder.recordDelete(
        entityType: 'moment_records',
        entityId: id,
      );
    });
    
    ContextBuilder.clearCache();
  }

  Future<void> deleteGoal(String id) async {
    await db.transaction(() async {
      final now = DateTime.now();

      final allGoalIds = await _getAllDescendantGoalIds(id);
      allGoalIds.add(id);

      for (final goalId in allGoalIds) {
        await _deleteLinksForEntity('goal', goalId);
      }

      for (final goalId in allGoalIds) {
        await (db.delete(db.goalReviews)..where((t) => t.goalId.equals(goalId))).go();
      }

      for (final goalId in allGoalIds) {
        await (db.delete(db.goalPostponements)..where((t) => t.goalId.equals(goalId))).go();
      }

      for (final goalId in allGoalIds) {
        await db.embeddingDao.deleteByEntity('goal', goalId);
      }

      await (db.update(db.goalRecords)..where((t) => t.id.isIn(allGoalIds))).write(
        GoalRecordsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(now),
          ));

      for (final goalId in allGoalIds) {
        await _changeLogRecorder.recordDelete(
          entityType: 'goal_records',
          entityId: goalId,
        );
      }
    });
    
    ContextBuilder.clearCache();
  }

  Future<void> deleteGoalStage(String stageId) async {
    await db.transaction(() async {
      final now = DateTime.now();

      final tasks = await (db.select(db.goalRecords)
            ..where((t) => t.parentId.equals(stageId))
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      final allIds = [stageId, ...tasks.map((t) => t.id)];

      for (final id in allIds) {
        await _deleteLinksForEntity('goal', id);
      }

      for (final id in allIds) {
        await (db.delete(db.goalReviews)..where((t) => t.goalId.equals(id))).go();
      }

      for (final id in allIds) {
        await (db.delete(db.goalPostponements)..where((t) => t.goalId.equals(id))).go();
      }

      for (final id in allIds) {
        await db.embeddingDao.deleteByEntity('goal', id);
      }

      await (db.update(db.goalRecords)..where((t) => t.id.isIn(allIds))).write(
        GoalRecordsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(now),
          ));

      for (final id in allIds) {
        await _changeLogRecorder.recordDelete(
          entityType: 'goal_records',
          entityId: id,
        );
      }
    });
    
    ContextBuilder.clearCache();
  }

  Future<void> deleteTravel(String id) async {
    await db.transaction(() async {
      final now = DateTime.now();

      await _deleteLinksForEntity('travel', id);

      await db.embeddingDao.deleteByEntity('travel', id);

      await (db.update(db.travelRecords)..where((t) => t.id.equals(id))).write(
        TravelRecordsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await _changeLogRecorder.recordDelete(
        entityType: 'travel_records',
        entityId: id,
      );
    });
    
    ContextBuilder.clearCache();
  }

  Future<void> deleteTrip(String tripId) async {
    await db.transaction(() async {
      final now = DateTime.now();

      final records = await (db.select(db.travelRecords)
            ..where((t) => t.tripId.equals(tripId))
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      final recordIds = records.map((r) => r.id).toList();

      for (final recordId in recordIds) {
        await _deleteLinksForEntity('travel', recordId);
      }

      await (db.delete(db.checklistItems)..where((t) => t.tripId.equals(tripId))).go();

      for (final recordId in recordIds) {
        await db.embeddingDao.deleteByEntity('travel', recordId);
      }

      await (db.update(db.travelRecords)..where((t) => t.tripId.equals(tripId))).write(
        TravelRecordsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(now),
          ));

      for (final recordId in recordIds) {
        await _changeLogRecorder.recordDelete(
          entityType: 'travel_records',
          entityId: recordId,
        );
      }
    });
    
    ContextBuilder.clearCache();
  }

  Future<void> hardDeleteTravelJournal(String id) async {
    await db.transaction(() async {
      await _deleteLinksForEntity('travel', id);

      await (db.delete(db.timelineEvents)
            ..where((t) => t.id.equals(id))
            ..where((t) => t.eventType.equals('journal')))
          .go();

      await (db.delete(db.travelRecords)..where((t) => t.id.equals(id))).go();

      await _changeLogRecorder.recordDelete(
        entityType: 'travel_records',
        entityId: id,
      );
    });
    
    ContextBuilder.clearCache();
  }

  Future<void> deleteFriend(String id) async {
    await db.transaction(() async {
      final now = DateTime.now();

      await _deleteLinksForEntity('friend', id);

      await (db.delete(db.timelineEvents)
            ..where((t) => t.eventType.equals('encounter'))
            ..where((t) => t.id.equals(id)))
          .go();

      await (db.update(db.friendRecords)..where((t) => t.id.equals(id))).write(
        FriendRecordsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await _changeLogRecorder.recordDelete(
        entityType: 'friend_records',
        entityId: id,
      );
    });
    
    ContextBuilder.clearCache();
  }

  Future<void> deleteChatSession(String id) async {
    await db.transaction(() async {
      final now = DateTime.now();

      await (db.delete(db.chatMessages)..where((t) => t.sessionId.equals(id))).go();

      await (db.update(db.chatSessions)..where((t) => t.id.equals(id))).write(
        ChatSessionsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await _changeLogRecorder.recordDelete(
        entityType: 'chat_sessions',
        entityId: id,
      );
    });
  }

  Future<void> _deleteLinksForEntity(String entityType, String entityId) async {
    await db.linkDao.deleteLinksBySource(entityType, entityId);
  }

  Future<List<String>> _getAllDescendantGoalIds(String parentId) async {
    final children = await (db.select(db.goalRecords)
          ..where((t) => t.parentId.equals(parentId))
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    final ids = <String>[];
    for (final child in children) {
      ids.add(child.id);
      ids.addAll(await _getAllDescendantGoalIds(child.id));
    }
    return ids;
  }
}
