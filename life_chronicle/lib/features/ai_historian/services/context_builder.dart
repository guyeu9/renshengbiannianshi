import 'package:life_chronicle/core/database/app_database.dart';
import 'record_retriever.dart';

class ContextBuilder {
  final AppDatabase _db;
  final RecordRetriever _retriever;

  ContextBuilder(this._db) : _retriever = RecordRetriever(_db);

  Future<String> buildSystemPrompt({
    required String userQuery,
    required Map<String, int> recordStats,
    required int totalRecords,
    List<RecordContext>? preloadedRecords,
  }) async {
    final buffer = StringBuffer();
    
    buffer.writeln('你是人生编年史APP的AI史官，一个温暖、有洞察力的数字档案管理员。');
    buffer.writeln('你能够访问用户的人生记录数据，帮助用户回顾和探索他们的过去。');
    buffer.writeln('');
    
    buffer.writeln('## 用户数据概览');
    buffer.writeln('- 美食记录：${recordStats['food'] ?? 0} 条');
    buffer.writeln('- 小确幸记录：${recordStats['moment'] ?? 0} 条');
    buffer.writeln('- 旅行记录：${recordStats['travel'] ?? 0} 条');
    buffer.writeln('- 目标记录：${recordStats['goal'] ?? 0} 条');
    buffer.writeln('- 相遇记录：${recordStats['encounter'] ?? 0} 条');
    buffer.writeln('- 总计：$totalRecords 条记录');
    buffer.writeln('');
    
    final records = preloadedRecords ?? await _retrieveRecordsForQuery(userQuery);
    
    if (records.isNotEmpty) {
      buffer.writeln('## 相关记录');
      buffer.writeln('以下是与你问题相关的用户真实记录：');
      buffer.writeln('');
      
      final groupedRecords = _groupByType(records);
      for (final entry in groupedRecords.entries) {
        buffer.writeln('### ${entry.key} (${entry.value.length}条)');
        for (final record in entry.value.take(10)) {
          buffer.writeln(record.toPromptString());
        }
        if (entry.value.length > 10) {
          buffer.writeln('... 还有 ${entry.value.length - 10} 条记录');
        }
        buffer.writeln('');
      }
    }
    
    buffer.writeln('## 回复原则');
    buffer.writeln('1. 基于提供的记录数据回答问题，不要编造');
    buffer.writeln('2. 如果记录中有具体的时间和地点，请准确引用');
    buffer.writeln('3. 语气温暖、有温度，像写给未来自己的一封信');
    buffer.writeln('4. 可以主动关联相关记忆，帮助用户发现隐藏的联系');
    buffer.writeln('5. 如果找不到相关记录，诚实告知并建议其他探索方向');
    buffer.writeln('6. 回复简洁明了，避免过长');
    buffer.writeln('');
    buffer.writeln('## 推荐卡片格式');
    buffer.writeln('如果你想在回复中推荐相关记录，请在回复末尾使用以下JSON格式：');
    buffer.writeln('```json');
    buffer.writeln('{"recommendations": [{"type": "food|moment|travel|goal|encounter", "id": "记录ID", "title": "标题", "summary": "简短描述"}]}');
    buffer.writeln('```');
    
    return buffer.toString();
  }

  Future<List<RecordContext>> _retrieveRecordsForQuery(String query) async {
    final queryType = _classifyQuery(query);
    
    String? module;
    DateTime? startDate;
    DateTime? endDate;
    
    if (queryType == QueryType.summary) {
      module = _extractModule(query);
    } else if (queryType == QueryType.timeRange) {
      final timeRange = _extractTimeRange(query);
      startDate = timeRange['start'];
      endDate = timeRange['end'];
    }
    
    return _retriever.retrieveRecords(
      queryType: queryType,
      userQuery: query,
      module: module,
      startDate: startDate,
      endDate: endDate,
      limit: 20,
    );
  }

  QueryType _classifyQuery(String query) {
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('那年') && (lowerQuery.contains('今天') || lowerQuery.contains('今日'))) {
      return QueryType.onThisDay;
    }
    
    if (lowerQuery.contains('上月') || lowerQuery.contains('上个月') || 
        lowerQuery.contains('本月') || lowerQuery.contains('这个月') ||
        lowerQuery.contains('去年') || lowerQuery.contains('今年') ||
        lowerQuery.contains('上周') || lowerQuery.contains('这周') ||
        lowerQuery.contains('前天') || lowerQuery.contains('昨天') ||
        lowerQuery.contains('最近')) {
      return QueryType.timeRange;
    }
    
    if (lowerQuery.contains('总结') || lowerQuery.contains('所有') || 
        lowerQuery.contains('全部') || lowerQuery.contains('概览') ||
        lowerQuery.contains('一览')) {
      return QueryType.summary;
    }
    
    if (lowerQuery.contains('多少') || lowerQuery.contains('统计') || 
        lowerQuery.contains('排名') || lowerQuery.contains('排行') ||
        lowerQuery.contains('最')) {
      return QueryType.statistics;
    }
    
    return QueryType.query;
  }

  String? _extractModule(String query) {
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('美食') || lowerQuery.contains('吃') || lowerQuery.contains('餐厅')) {
      return 'food';
    }
    if (lowerQuery.contains('小确幸') || lowerQuery.contains('心情') || lowerQuery.contains('瞬间')) {
      return 'moment';
    }
    if (lowerQuery.contains('旅行') || lowerQuery.contains('旅游') || lowerQuery.contains('出行')) {
      return 'travel';
    }
    if (lowerQuery.contains('目标') || lowerQuery.contains('计划') || lowerQuery.contains('任务')) {
      return 'goal';
    }
    if (lowerQuery.contains('相遇') || lowerQuery.contains('相遇') || lowerQuery.contains('朋友')) {
      return 'encounter';
    }
    
    return 'all';
  }

  Map<String, DateTime>? _extractTimeRange(String query) {
    final now = DateTime.now();
    
    if (query.contains('上月') || query.contains('上个月')) {
      final lastMonth = DateTime(now.year, now.month - 1);
      return {
        'start': DateTime(lastMonth.year, lastMonth.month, 1),
        'end': DateTime(now.year, now.month, 1),
      };
    }
    
    if (query.contains('本月') || query.contains('这个月')) {
      return {
        'start': DateTime(now.year, now.month, 1),
        'end': DateTime(now.year, now.month + 1, 1),
      };
    }
    
    if (query.contains('去年')) {
      return {
        'start': DateTime(now.year - 1, 1, 1),
        'end': DateTime(now.year, 1, 1),
      };
    }
    
    if (query.contains('今年')) {
      return {
        'start': DateTime(now.year, 1, 1),
        'end': DateTime(now.year + 1, 1, 1),
      };
    }
    
    if (query.contains('上周')) {
      final weekStart = now.subtract(Duration(days: now.weekday + 6));
      return {
        'start': DateTime(weekStart.year, weekStart.month, weekStart.day),
        'end': DateTime(now.year, now.month, now.day),
      };
    }
    
    if (query.contains('最近') || query.contains('这周')) {
      return {
        'start': now.subtract(const Duration(days: 7)),
        'end': now.add(const Duration(days: 1)),
      };
    }
    
    return null;
  }

  Map<String, List<RecordContext>> _groupByType(List<RecordContext> records) {
    final grouped = <String, List<RecordContext>>{};
    for (final record in records) {
      grouped.putIfAbsent(record.type, () => []).add(record);
    }
    return grouped;
  }

  Future<List<RecordContext>> retrieveForQuickAction(String actionType) async {
    switch (actionType) {
      case 'mood_summary':
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1);
        final start = DateTime(lastMonth.year, lastMonth.month, 1);
        final end = DateTime(now.year, now.month, 1);
        return _retriever.retrieveRecords(
          queryType: QueryType.timeRange,
          userQuery: '',
          module: 'moment',
          startDate: start,
          endDate: end,
          limit: 50,
        );
        
      case 'goal_progress':
        final now = DateTime.now();
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year + 1, 1, 1);
        return _retriever.retrieveRecords(
          queryType: QueryType.timeRange,
          userQuery: '',
          module: 'goal',
          startDate: start,
          endDate: end,
          limit: 50,
        );
        
      case 'on_this_day':
        return _retriever.retrieveRecords(
          queryType: QueryType.onThisDay,
          userQuery: '',
          limit: 30,
        );
        
      default:
        return [];
    }
  }
}
