part of '../app_database.dart';

@DriftAccessor(tables: [ChatSessions, ChatMessages])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  late final ChangeLogRecorder _changeLogRecorder = ChangeLogRecorder(db);

  Future<void> upsertSession(ChatSessionsCompanion entry) async {
    await into(db.chatSessions).insertOnConflictUpdate(entry);
  }

  Future<void> upsertMessage(ChatMessagesCompanion entry) async {
    await into(db.chatMessages).insertOnConflictUpdate(entry);
  }

  Future<void> softDeleteSession(String id, {required DateTime now}) async {
    await transaction(() async {
      await (delete(db.chatMessages)..where((t) => t.sessionId.equals(id))).go();

      await (update(db.chatSessions)..where((t) => t.id.equals(id))).write(
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

  Future<void> updateSessionTitle(String id, String title, {required DateTime now}) async {
    await (update(db.chatSessions)..where((t) => t.id.equals(id))).write(
      ChatSessionsCompanion(
        title: Value(title),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updateSessionLastMessageAt(String id, {required DateTime now}) async {
    await (update(db.chatSessions)..where((t) => t.id.equals(id))).write(
      ChatSessionsCompanion(
        lastMessageAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<ChatSession?> findSessionById(String id) {
    return (select(db.chatSessions)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<ChatSession?> watchSessionById(String id) {
    return (select(db.chatSessions)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<ChatSession>> watchAllActiveSessions() {
    return (select(db.chatSessions)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.lastMessageAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<ChatSession>> watchActiveSessionsByModuleType(String? moduleType) {
    final query = select(db.chatSessions)
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.isArchived.equals(false));
    
    if (moduleType != null && moduleType.isNotEmpty) {
      query.where((t) => t.moduleType.equals(moduleType));
    } else {
      query.where((t) => t.moduleType.isNull() | t.moduleType.equals(''));
    }
    
    query.orderBy([(t) => OrderingTerm(expression: t.lastMessageAt, mode: OrderingMode.desc)]);
    
    return query.watch();
  }

  Future<List<ChatSession>> getActiveSessionsByModuleType(String? moduleType) {
    final query = select(db.chatSessions)
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.isArchived.equals(false));
    
    if (moduleType != null && moduleType.isNotEmpty) {
      query.where((t) => t.moduleType.equals(moduleType));
    } else {
      query.where((t) => t.moduleType.isNull() | t.moduleType.equals(''));
    }
    
    query.orderBy([(t) => OrderingTerm(expression: t.lastMessageAt, mode: OrderingMode.desc)]);
    
    return query.get();
  }

  Stream<List<ChatMessage>> watchMessagesBySessionId(String sessionId) {
    return (select(db.chatMessages)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc)]))
        .watch();
  }

  Future<List<ChatMessage>> getMessagesBySessionId(String sessionId) {
    return (select(db.chatMessages)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc)]))
        .get();
  }

  Future<void> deleteMessagesBySessionId(String sessionId) async {
    await (delete(db.chatMessages)..where((t) => t.sessionId.equals(sessionId))).go();
  }
}
