import 'package:life_chronicle/core/database/app_database.dart';
import 'vector_index_service.dart';
import 'vector_index_task_queue.dart';
import 'vector_index_trigger.dart';
import 'embedding_service.dart';

class VectorIndexManager {
  final AppDatabase db;
  final VectorIndexService vectorIndexService;
  final VectorIndexTaskQueue taskQueue;
  final VectorIndexTrigger trigger;

  VectorIndexManager._(this.db, this.vectorIndexService, this.taskQueue, this.trigger);

  factory VectorIndexManager(AppDatabase db, EmbeddingServiceBase? Function() embeddingServiceGetter) {
    final service = VectorIndexService(db, embeddingServiceGetter);
    final queue = VectorIndexTaskQueue(service);
    final trig = VectorIndexTrigger(queue, service);
    return VectorIndexManager._(db, service, queue, trig);
  }

  Future<void> initialize() async {
    await taskQueue.loadPendingTasks();
  }

  Future<void> recordInsert({
    required String entityType,
    required String entityId,
    required String text,
  }) async {
    await trigger.recordInsert(
      entityType: entityType,
      entityId: entityId,
      text: text,
    );
  }

  Future<void> recordUpdate({
    required String entityType,
    required String entityId,
    required String text,
  }) async {
    await trigger.recordUpdate(
      entityType: entityType,
      entityId: entityId,
      text: text,
    );
  }

  Future<void> recordDelete({
    required String entityType,
    required String entityId,
  }) async {
    await trigger.recordDelete(
      entityType: entityType,
      entityId: entityId,
    );
  }
}
