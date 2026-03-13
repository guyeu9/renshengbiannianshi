import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'vector_index_service.dart';

enum VectorIndexTaskStatus { pending, processing, failed }

enum VectorIndexTaskAction { create, update, delete }

class VectorIndexTask {
  final String id;
  final String entityType;
  final String entityId;
  final String text;
  final VectorIndexTaskAction action;
  final int retryCount;
  final DateTime createdAt;
  final VectorIndexTaskStatus status;

  VectorIndexTask({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.text,
    required this.action,
    this.retryCount = 0,
    required this.createdAt,
    this.status = VectorIndexTaskStatus.pending,
  });

  VectorIndexTask copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? text,
    VectorIndexTaskAction? action,
    int? retryCount,
    DateTime? createdAt,
    VectorIndexTaskStatus? status,
  }) {
    return VectorIndexTask(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      text: text ?? this.text,
      action: action ?? this.action,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'text': text,
      'action': action.name,
      'retryCount': retryCount,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory VectorIndexTask.fromJson(Map<String, dynamic> json) {
    return VectorIndexTask(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      text: json['text'] as String,
      action: VectorIndexTaskAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => VectorIndexTaskAction.create,
      ),
      retryCount: json['retryCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: VectorIndexTaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VectorIndexTaskStatus.pending,
      ),
    );
  }
}

class VectorIndexTaskQueue {
  final VectorIndexService _vectorIndexService;
  final List<VectorIndexTask> _pendingTasks = [];
  bool _isProcessing = false;
  static const String _storageKey = 'vector_index_tasks';
  static const int _maxRetries = 3;
  static const List<int> _retryIntervals = [1000, 2000, 4000];

  VectorIndexTaskQueue(this._vectorIndexService);

  Future<void> loadPendingTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_storageKey);
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _pendingTasks.clear();
      _pendingTasks.addAll(
        decoded.map((json) => VectorIndexTask.fromJson(json as Map<String, dynamic>)),
      );
      unawaited(processQueue());
    }
  }

  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String text,
    required VectorIndexTaskAction action,
  }) async {
    final task = VectorIndexTask(
      id: const Uuid().v4(),
      entityType: entityType,
      entityId: entityId,
      text: text,
      action: action,
      createdAt: DateTime.now(),
    );
    _pendingTasks.add(task);
    await _saveTasks();
    unawaited(processQueue());
  }

  Future<void> processQueue() async {
    if (_isProcessing || _pendingTasks.isEmpty) return;
    _isProcessing = true;
    try {
      while (_pendingTasks.isNotEmpty) {
        final task = _pendingTasks.first;
        await _processTask(task);
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processTask(VectorIndexTask task) async {
    debugPrint('向量索引任务开始: ${task.id}, 操作: ${task.action}, 实体: ${task.entityType}/${task.entityId}');
    try {
      _pendingTasks.removeWhere((t) => t.id == task.id);
      final updatedTask = task.copyWith(status: VectorIndexTaskStatus.processing);
      _pendingTasks.insert(0, updatedTask);
      await _saveTasks();

      await _executeTask(task);
      debugPrint('向量索引任务成功: ${task.id}');

      _pendingTasks.removeWhere((t) => t.id == task.id);
      await _saveTasks();
    } catch (e) {
      debugPrint('向量索引任务失败: ${task.id}, 错误: $e');
      await _handleTaskFailure(task);
    }
  }

  Future<void> _executeTask(VectorIndexTask task) async {
    switch (task.action) {
      case VectorIndexTaskAction.create:
        await _vectorIndexService.indexRecord(
          entityType: task.entityType,
          entityId: task.entityId,
          text: task.text,
        );
        break;
      case VectorIndexTaskAction.update:
        await _vectorIndexService.updateIndex(
          entityType: task.entityType,
          entityId: task.entityId,
          text: task.text,
        );
        break;
      case VectorIndexTaskAction.delete:
        await _vectorIndexService.deleteIndex(
          entityType: task.entityType,
          entityId: task.entityId,
        );
        break;
    }
  }

  Future<void> _handleTaskFailure(VectorIndexTask task) async {
    if (task.retryCount >= _maxRetries) {
      _pendingTasks.removeWhere((t) => t.id == task.id);
      await _saveTasks();
      return;
    }

    final interval = _retryIntervals[task.retryCount];
    await Future.delayed(Duration(milliseconds: interval));

    final updatedTask = task.copyWith(
      retryCount: task.retryCount + 1,
      status: VectorIndexTaskStatus.pending,
    );
    _pendingTasks.removeWhere((t) => t.id == task.id);
    _pendingTasks.add(updatedTask);
    await _saveTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(_pendingTasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, tasksJson);
  }
}
