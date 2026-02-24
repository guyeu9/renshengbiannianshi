import 'dart:convert';
import 'package:drift/drift.dart';
import '../../database/app_database.dart';

class ChangeLogRecorder {
  final AppDatabase db;

  ChangeLogRecorder(this.db);

  Future<void> recordInsert({
    required String entityType,
    required String entityId,
    Map<String, dynamic>? data,
  }) async {
    await db.changeLogDao.insert(
      ChangeLogsCompanion(
        entityType: Value(entityType),
        entityId: Value(entityId),
        action: const Value('insert'),
        changedFields: data != null ? Value(jsonEncode(data)) : const Value(null),
        timestamp: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }

  Future<void> recordUpdate({
    required String entityType,
    required String entityId,
    List<String>? changedFields,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    final fieldsJson = changedFields != null ? jsonEncode(changedFields) : null;
    await db.changeLogDao.insert(
      ChangeLogsCompanion(
        entityType: Value(entityType),
        entityId: Value(entityId),
        action: const Value('update'),
        changedFields: fieldsJson != null ? Value(fieldsJson) : const Value(null),
        timestamp: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }

  Future<void> recordDelete({
    required String entityType,
    required String entityId,
    Map<String, dynamic>? oldData,
  }) async {
    await db.changeLogDao.insert(
      ChangeLogsCompanion(
        entityType: Value(entityType),
        entityId: Value(entityId),
        action: const Value('delete'),
        changedFields: oldData != null ? Value(jsonEncode(oldData)) : const Value(null),
        timestamp: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }
}
