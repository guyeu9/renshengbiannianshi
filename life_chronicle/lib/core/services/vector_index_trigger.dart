import 'vector_index_task_queue.dart';
import 'vector_index_service.dart';

class VectorIndexTrigger {
  final VectorIndexTaskQueue _taskQueue;
  final VectorIndexService _vectorIndexService;

  VectorIndexTrigger(this._taskQueue, this._vectorIndexService);

  Future<void> recordInsert({
    required String entityType,
    required String entityId,
    required String text,
  }) async {
    try {
      await _taskQueue.enqueue(
        entityType: entityType,
        entityId: entityId,
        text: text,
        action: VectorIndexTaskAction.create,
      );
    } catch (e) {}
  }

  Future<void> recordUpdate({
    required String entityType,
    required String entityId,
    required String text,
  }) async {
    try {
      await _taskQueue.enqueue(
        entityType: entityType,
        entityId: entityId,
        text: text,
        action: VectorIndexTaskAction.update,
      );
    } catch (e) {}
  }

  Future<void> recordDelete({
    required String entityType,
    required String entityId,
  }) async {
    try {
      await _vectorIndexService.deleteIndex(
        entityType: entityType,
        entityId: entityId,
      );
    } catch (e) {}
  }
}
