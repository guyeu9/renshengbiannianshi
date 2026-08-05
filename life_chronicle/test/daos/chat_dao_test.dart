import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late ChatDao chatDao;

  setUp(() async {
    db = createTestDatabase();
    chatDao = ChatDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('ChatDao CRUD Operations', () {
    test('should upsert a chat session', () async {
      final now = DateTime.now();
      final entry = ChatSessionsCompanion.insert(
        id: 'test-session-1',
        createdAt: now,
        updatedAt: now,
      );

      await chatDao.upsertSession(entry);

      final found = await chatDao.findSessionById('test-session-1');
      expect(found, isNotNull);
      expect(found!.id, equals('test-session-1'));
    });

    test('should update session title', () async {
      final now = DateTime.now();
      final entry = ChatSessionsCompanion.insert(
        id: 'test-session-2',
        createdAt: now,
        updatedAt: now,
      );

      await chatDao.upsertSession(entry);
      await chatDao.updateSessionTitle('test-session-2', '新标题', now: now);

      final found = await chatDao.findSessionById('test-session-2');
      expect(found!.title, equals('新标题'));
    });

    test('should soft delete a chat session', () async {
      final now = DateTime.now();
      final entry = ChatSessionsCompanion.insert(
        id: 'test-session-3',
        createdAt: now,
        updatedAt: now,
      );

      await chatDao.upsertSession(entry);
      await chatDao.softDeleteSession('test-session-3', now: now);

      final found = await chatDao.findSessionById('test-session-3');
      expect(found!.isDeleted, isTrue);
    });

    test('should upsert a chat message', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'test-msg-session-1',
        createdAt: now,
        updatedAt: now,
      ));

      final msgEntry = ChatMessagesCompanion.insert(
        id: 'test-msg-1',
        sessionId: 'test-msg-session-1',
        role: 'user',
        content: 'Hello',
        timestamp: now,
        createdAt: now,
      );

      await chatDao.upsertMessage(msgEntry);

      final msgs = await chatDao.getMessagesBySessionId('test-msg-session-1');
      expect(msgs.length, equals(1));
      expect(msgs.first.content, equals('Hello'));
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('ChatDao Stream Reliability - watchSessionById（0.1.160）', () {
    test('A: 初始状态（不存在的 id）应返回 null', () async {
      final result = await chatDao.watchSessionById('non-existent').first;
      expect(result, isNull);
    });

    test('B: 插入数据后流应发出新值', () async {
      final now = DateTime.now();
      final stream = chatDao.watchSessionById('cs-stream-byid-1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNull,
          isNotNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-byid-1',
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出新值', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-byid-2',
        createdAt: now,
        updatedAt: now,
      ));
      final stream = chatDao.watchSessionById('cs-stream-byid-2');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((ChatSession? s) => s?.title == '新对话'),
          predicate((ChatSession? s) => s?.title == '更新后标题'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.updateSessionTitle('cs-stream-byid-2', '更新后标题', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除后流应发出 null（watchSessionById 过滤 isDeleted）', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-byid-3',
        createdAt: now,
        updatedAt: now,
      ));
      final stream = chatDao.watchSessionById('cs-stream-byid-3');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNotNull,
          isNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.softDeleteSession('cs-stream-byid-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不存在的 id 返回 null', () async {
      final result = await chatDao.watchSessionById('').first;
      expect(result, isNull);
    });

    test('边界2: softDelete 后返回 null', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-byid-4',
        createdAt: now,
        updatedAt: now,
      ));
      await chatDao.softDeleteSession('cs-stream-byid-4', now: now);
      final result = await chatDao.watchSessionById('cs-stream-byid-4').first;
      expect(result, isNull);
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('ChatDao Stream Reliability - watchAllActiveSessions（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await chatDao.watchAllActiveSessions().first;
      expect(result, isEmpty);
    });

    test('B: 插入数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = chatDao.watchAllActiveSessions();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<ChatSession> list) => list.any((s) => s.id == 'cs-stream-all-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-all-1',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出包含更新后记录的列表', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-all-2',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
      ));
      final stream = chatDao.watchAllActiveSessions();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<ChatSession> list) => list.firstWhere((s) => s.id == 'cs-stream-all-2').title == '新对话'),
          predicate((List<ChatSession> list) => list.firstWhere((s) => s.id == 'cs-stream-all-2').title == '更新标题'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.updateSessionTitle('cs-stream-all-2', '更新标题', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除后流应发出不包含已删除记录的列表', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-all-3',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
      ));
      final stream = chatDao.watchAllActiveSessions();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<ChatSession> list) => list.any((s) => s.id == 'cs-stream-all-3')),
          predicate((List<ChatSession> list) => !list.any((s) => s.id == 'cs-stream-all-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.softDeleteSession('cs-stream-all-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: lastMessageAt 降序排序', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-order-1',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now.subtract(const Duration(hours: 2))),
      ));
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-order-2',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
      ));
      final result = await chatDao.watchAllActiveSessions().first;
      expect(result.first.id, equals('cs-stream-order-2'));
      expect(result.last.id, equals('cs-stream-order-1'));
    });

    test('边界2: isArchived=true 不返回', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-archived-1',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
        isArchived: const Value(true),
      ));
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-active-1',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
        isArchived: const Value(false),
      ));
      final result = await chatDao.watchAllActiveSessions().first;
      expect(result.any((s) => s.id == 'cs-stream-archived-1'), isFalse);
      expect(result.any((s) => s.id == 'cs-stream-active-1'), isTrue);
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('ChatDao Stream Reliability - watchActiveSessionsByModuleType（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await chatDao.watchActiveSessionsByModuleType('chat').first;
      expect(result, isEmpty);
    });

    test('B: 插入匹配 moduleType 的数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = chatDao.watchActiveSessionsByModuleType('goal');
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<ChatSession> list) => list.any((s) => s.id == 'cs-stream-mod-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-mod-1',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
        moduleType: const Value('goal'),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: null moduleType 只匹配 moduleType 为 null 或空', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-mod-null-1',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
      ));
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-mod-empty-1',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
        moduleType: const Value(''),
      ));
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-mod-chat-1',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
        moduleType: const Value('chat'),
      ));
      final result = await chatDao.watchActiveSessionsByModuleType(null).first;
      expect(result.any((s) => s.id == 'cs-stream-mod-null-1'), isTrue);
      expect(result.any((s) => s.id == 'cs-stream-mod-empty-1'), isTrue);
      expect(result.any((s) => s.id == 'cs-stream-mod-chat-1'), isFalse);
    });

    test('边界2: 不同 moduleType 不返回', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-mod-2',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
        moduleType: const Value('travel'),
      ));
      final result = await chatDao.watchActiveSessionsByModuleType('goal').first;
      expect(result.any((s) => s.id == 'cs-stream-mod-2'), isFalse);
    });

    test('边界3: softDelete 后不返回', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cs-stream-mod-3',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: Value(now),
        moduleType: const Value('chat'),
      ));
      await chatDao.softDeleteSession('cs-stream-mod-3', now: now);
      final result = await chatDao.watchActiveSessionsByModuleType('chat').first;
      expect(result.any((s) => s.id == 'cs-stream-mod-3'), isFalse);
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('ChatDao Stream Reliability - watchMessagesBySessionId（0.1.160）', () {
    test('A: 初始状态（无消息）应返回空列表', () async {
      final result = await chatDao.watchMessagesBySessionId('no-session').first;
      expect(result, isEmpty);
    });

    test('B: 插入消息后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cm-stream-session-b1',
        createdAt: now,
        updatedAt: now,
      ));
      final stream = chatDao.watchMessagesBySessionId('cm-stream-session-b1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<ChatMessage> list) => list.any((m) => m.id == 'cm-stream-msg-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.upsertMessage(ChatMessagesCompanion.insert(
        id: 'cm-stream-msg-1',
        sessionId: 'cm-stream-session-b1',
        role: 'user',
        content: 'Hello',
        timestamp: now,
        createdAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 插入多条消息后流应按 timestamp 升序发出', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cm-stream-session-c1',
        createdAt: now,
        updatedAt: now,
      ));
      final stream = chatDao.watchMessagesBySessionId('cm-stream-session-c1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<ChatMessage> list) => list.length == 1 && list.first.content == 'First'),
          predicate((List<ChatMessage> list) => list.length == 2 && list.last.content == 'Second'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.upsertMessage(ChatMessagesCompanion.insert(
        id: 'cm-stream-c-msg1',
        sessionId: 'cm-stream-session-c1',
        role: 'user',
        content: 'First',
        timestamp: now,
        createdAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.upsertMessage(ChatMessagesCompanion.insert(
        id: 'cm-stream-c-msg2',
        sessionId: 'cm-stream-session-c1',
        role: 'assistant',
        content: 'Second',
        timestamp: now.add(const Duration(seconds: 1)),
        createdAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 删除会话消息后流应发出空列表', () async {
      final now = DateTime.now();
      await chatDao.upsertSession(ChatSessionsCompanion.insert(
        id: 'cm-stream-session-del',
        createdAt: now,
        updatedAt: now,
      ));
      await chatDao.upsertMessage(ChatMessagesCompanion.insert(
        id: 'cm-stream-del-msg1',
        sessionId: 'cm-stream-session-del',
        role: 'user',
        content: 'Will delete',
        timestamp: now,
        createdAt: now,
      ));
      final stream = chatDao.watchMessagesBySessionId('cm-stream-session-del');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<ChatMessage> list) => list.any((m) => m.id == 'cm-stream-del-msg1')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chatDao.deleteMessagesBySessionId('cm-stream-session-del');
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });
  });
}
