part of '../app_database.dart';

@DriftAccessor(tables: [AiProviders])
class AiProviderDao extends DatabaseAccessor<AppDatabase> with _$AiProviderDaoMixin {
  AiProviderDao(super.db);

  Future<void> upsert(AiProvidersCompanion entry) async {
    await into(db.aiProviders).insertOnConflictUpdate(entry);
  }

  Future<void> deleteById(String id) async {
    await (delete(db.aiProviders)..where((t) => t.id.equals(id))).go();
  }

  Future<AiProvider?> findById(String id) {
    return (select(db.aiProviders)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<AiProvider>> watchAll() {
    return (select(db.aiProviders)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<AiProvider>> watchByServiceType(String serviceType) {
    return (select(db.aiProviders)
          ..where((t) => t.serviceType.equals(serviceType))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<AiProvider?> getActiveProvider(String serviceType) async {
    return (select(db.aiProviders)
          ..where((t) => t.serviceType.equals(serviceType))
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<AiProvider?> watchActiveProvider(String serviceType) {
    return (select(db.aiProviders)
          ..where((t) => t.serviceType.equals(serviceType))
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<void> setActiveProvider(String id, String serviceType, {required DateTime now}) async {
    await batch(() async {
      await (update(db.aiProviders)..where((t) => t.serviceType.equals(serviceType))).write(
        AiProvidersCompanion(
          isActive: const Value(false),
          updatedAt: Value(now),
        ),
      );
      await (update(db.aiProviders)..where((t) => t.id.equals(id))).write(
        AiProvidersCompanion(
          isActive: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }
}
