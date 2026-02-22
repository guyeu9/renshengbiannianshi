part of '../app_database.dart';

@DriftAccessor(tables: [EntityLinks, LinkLogs])
class LinkDao extends DatabaseAccessor<AppDatabase> with _$LinkDaoMixin {
  LinkDao(super.db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  Future<bool> linkExists({
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
  }) async {
    final row = await (select(db.entityLinks)
          ..where((t) => t.sourceType.equals(sourceType))
          ..where((t) => t.sourceId.equals(sourceId))
          ..where((t) => t.targetType.equals(targetType))
          ..where((t) => t.targetId.equals(targetId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> createLink({
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    String linkType = 'manual',
    required DateTime now,
  }) async {
    final linkId = _uuid.v4();
    final logId = _uuid.v4();

    await transaction(() async {
      await into(db.entityLinks).insert(
        EntityLinksCompanion.insert(
          id: linkId,
          sourceType: sourceType,
          sourceId: sourceId,
          targetType: targetType,
          targetId: targetId,
          linkType: Value(linkType),
          createdAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );

      await into(db.linkLogs).insert(
        LinkLogsCompanion.insert(
          id: logId,
          sourceType: sourceType,
          sourceId: sourceId,
          targetType: targetType,
          targetId: targetId,
          action: 'create',
          linkType: Value(linkType),
          createdAt: now,
        ),
      );
    });
  }

  Future<void> deleteLink({
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    String? linkType,
    required DateTime now,
  }) async {
    final logId = _uuid.v4();

    await transaction(() async {
      await (delete(db.entityLinks)
            ..where((t) => t.sourceType.equals(sourceType))
            ..where((t) => t.sourceId.equals(sourceId))
            ..where((t) => t.targetType.equals(targetType))
            ..where((t) => t.targetId.equals(targetId)))
          .go();

      await into(db.linkLogs).insert(
        LinkLogsCompanion.insert(
          id: logId,
          sourceType: sourceType,
          sourceId: sourceId,
          targetType: targetType,
          targetId: targetId,
          action: 'delete',
          linkType: Value(linkType),
          createdAt: now,
        ),
      );
    });
  }

  Stream<List<EntityLink>> watchLinksForEntity({
    required String entityType,
    required String entityId,
  }) {
    final query = select(db.entityLinks)
      ..where(
        (t) =>
            (t.sourceType.equals(entityType) & t.sourceId.equals(entityId)) |
            (t.targetType.equals(entityType) & t.targetId.equals(entityId)),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<List<EntityLink>> listLinksForEntity({
    required String entityType,
    required String entityId,
  }) {
    final query = select(db.entityLinks)
      ..where(
        (t) =>
            (t.sourceType.equals(entityType) & t.sourceId.equals(entityId)) |
            (t.targetType.equals(entityType) & t.targetId.equals(entityId)),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    return query.get();
  }
}
