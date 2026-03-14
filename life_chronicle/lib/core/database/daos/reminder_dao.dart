part of '../app_database.dart';

@DriftAccessor(tables: [ReminderRecords])
class ReminderDao extends DatabaseAccessor<AppDatabase> with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Future<void> insertReminder(ReminderRecordsCompanion reminder) async {
    await into(reminderRecords).insert(reminder);
  }

  Future<void> updateReminder(String id, {bool? isRead, bool? isHandled, DateTime? triggeredAt}) async {
    await (update(reminderRecords)..where((t) => t.id.equals(id))).write(
      ReminderRecordsCompanion(
        isRead: isRead != null ? Value(isRead) : const Value.absent(),
        isHandled: isHandled != null ? Value(isHandled) : const Value.absent(),
        triggeredAt: triggeredAt != null ? Value(triggeredAt) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteReminder(String id) async {
    await (delete(reminderRecords)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteHandledReminders() async {
    await (delete(reminderRecords)..where((t) => t.isHandled.equals(true))).go();
  }

  Future<List<ReminderRecord>> getAllReminders() {
    return (select(reminderRecords)..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)])).get();
  }

  Stream<List<ReminderRecord>> watchAllReminders() {
    return (select(reminderRecords)..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)])).watch();
  }

  Stream<List<ReminderRecord>> watchUnreadReminders() {
    return (select(reminderRecords)
          ..where((t) => t.isRead.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
        .watch();
  }

  Stream<List<ReminderRecord>> watchUnhandledReminders() {
    final now = DateTime.now();
    return (select(reminderRecords)
          ..where((t) => t.isHandled.equals(false))
          ..where((t) => t.scheduledAt.isSmallerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
        .watch();
  }

  Future<List<ReminderRecord>> getUpcomingReminders({int limit = 10}) {
    final now = DateTime.now();
    return (select(reminderRecords)
          ..where((t) => t.isHandled.equals(false))
          ..where((t) => t.scheduledAt.isBiggerThanValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)])
          ..limit(limit))
        .get();
  }

  Future<int> getUnreadCount() async {
    final count = reminderRecords.id.count();
    final query = selectOnly(reminderRecords)..addColumns([count]);
    query.where(reminderRecords.isRead.equals(false));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Stream<int> watchUnreadCount() {
    final count = reminderRecords.id.count();
    final query = selectOnly(reminderRecords)..addColumns([count]);
    query.where(reminderRecords.isRead.equals(false));
    return query.map((row) => row.read(count)).watch().map((list) => list.first ?? 0);
  }

  Future<List<ReminderRecord>> getRemindersByType(String type) {
    return (select(reminderRecords)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
        .get();
  }

  Future<List<ReminderRecord>> getRemindersByEntity(String entityType, String entityId) {
    return (select(reminderRecords)
          ..where((t) => t.relatedEntityType.equals(entityType))
          ..where((t) => t.relatedEntityId.equals(entityId))
          ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
        .get();
  }

  Future<void> markAllAsRead() async {
    await (update(reminderRecords)..where((t) => t.isRead.equals(false)))
        .write(const ReminderRecordsCompanion(isRead: Value(true)));
  }

  Future<void> deleteRemindersByEntity(String entityType, String entityId) async {
    await (delete(reminderRecords)
          ..where((t) => t.relatedEntityType.equals(entityType))
          ..where((t) => t.relatedEntityId.equals(entityId)))
        .go();
  }
}
