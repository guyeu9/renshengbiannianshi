import 'dart:developer' as developer;

import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/vector_index_service.dart';
import 'record_retriever.dart';

class _CacheEntry<T> {
  final T value;
  final DateTime timestamp;
  
  const _CacheEntry(this.value, this.timestamp);
  
  bool get isExpired => DateTime.now().difference(timestamp).inMinutes > 5;
}

class ContextLog {
  final DateTime timestamp;
  final String query;
  final int recordCount;
  final int estimatedTokens;
  final Duration retrievalTime;
  final bool fullData;
  final String? queryFocus;
  
  const ContextLog({
    required this.timestamp,
    required this.query,
    required this.recordCount,
    required this.estimatedTokens,
    required this.retrievalTime,
    required this.fullData,
    this.queryFocus,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'query': query,
    'recordCount': recordCount,
    'estimatedTokens': estimatedTokens,
    'retrievalTimeMs': retrievalTime.inMilliseconds,
    'fullData': fullData,
    'queryFocus': queryFocus,
  };
}

class ContextBuilder {
  final RecordRetriever _retriever;
  final VectorIndexService? Function()? _vectorServiceGetter;
  
  static final Map<String, _CacheEntry<List<RecordContext>>> _cache = {};
  static final List<ContextLog> _logs = [];
  static const int _maxLogs = 100;
  
  List<ContextLog> get logs => List.unmodifiable(_logs);
  
  ContextBuilder(AppDatabase db, {VectorIndexService? Function()? vectorServiceGetter})
      : _retriever = RecordRetriever(db),
        _vectorServiceGetter = vectorServiceGetter;

  Future<String> buildSystemPrompt({
    required String userQuery,
    required Map<String, int> recordStats,
    required int totalRecords,
    List<RecordContext>? preloadedRecords,
    bool fullData = false,
  }) async {
    final buffer = StringBuffer();
    final now = DateTime.now();
    
    buffer.writeln('你是人生编年史APP的AI史官，一个温暖、有洞察力的数字档案管理员。');
    buffer.writeln('你能够访问用户的人生记录数据，帮助用户回顾和探索他们的过去。');
    buffer.writeln('');
    
    buffer.writeln('## 当前时间');
    buffer.writeln('今天是 ${now.year}年${now.month}月${now.day}日（${_getWeekdayName(now.weekday)}）');
    buffer.writeln('当前时间：${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
    buffer.writeln('');
    
    buffer.writeln('## 用户数据概览');
    buffer.writeln('- 美食记录：${recordStats['food'] ?? 0} 条');
    buffer.writeln('- 小确幸记录：${recordStats['moment'] ?? 0} 条');
    buffer.writeln('- 旅行记录：${recordStats['travel'] ?? 0} 条');
    buffer.writeln('- 目标记录：${recordStats['goal'] ?? 0} 条');
    buffer.writeln('- 相遇记录：${recordStats['encounter'] ?? 0} 条');
    buffer.writeln('- 总计：$totalRecords 条记录');
    buffer.writeln('');
    
    final queryFocus = _detectQueryFocus(userQuery);
    if (queryFocus != null) {
      buffer.writeln('## 用户关注点');
      buffer.writeln(queryFocus);
      buffer.writeln('');
    }
    
    final queryType = _classifyQuery(userQuery);
    final timeRange = queryType == QueryType.timeRange ? _extractTimeRange(userQuery) : null;
    
    if (timeRange != null) {
      buffer.writeln('## 查询时间范围');
      buffer.writeln('用户询问的时间范围：${_formatDateRange(timeRange['start']!, timeRange['end']!)}');
      buffer.writeln('');
    }
    
    final records = preloadedRecords ?? await _retrieveRecordsForQuery(userQuery, fullData: fullData);
    
    if (records.isNotEmpty) {
      buffer.writeln('## 用户档案记录');
      buffer.writeln('以下是用户的真实记录数据（完整原始数据）：');
      buffer.writeln('');
      
      final groupedRecords = _groupByType(records);
      for (final entry in groupedRecords.entries) {
        buffer.writeln('### ${entry.key}（${entry.value.length}条）');
        for (final record in entry.value) {
          buffer.writeln(record.toPromptString());
        }
        buffer.writeln('');
      }
    } else {
      buffer.writeln('## 用户档案记录');
      buffer.writeln('目前用户还没有任何记录。请友好地引导用户开始记录他们的人生故事。');
      buffer.writeln('');
    }
    
    if (timeRange != null) {
      final timeRangeRecords = records.where((r) {
        final recordDate = r.date;
        return recordDate.isAfter(timeRange['start']!) && recordDate.isBefore(timeRange['end']!);
      }).toList();
      
      if (timeRangeRecords.isEmpty) {
        buffer.writeln('## 时间范围提示');
        buffer.writeln('⚠️ 用户询问的时间范围内没有找到记录。');
        buffer.writeln('请基于用户的其他记录数据，友好地告知用户这一情况，并建议其他探索方向。');
        buffer.writeln('');
      }
    }
    
    buffer.writeln('## 数据格式说明');
    buffer.writeln('每条记录包含完整的原始数据：');
    buffer.writeln('- ID：记录唯一标识，用于生成推荐卡片');
    buffer.writeln('- 标题/内容：完整的原始文本');
    buffer.writeln('- 评分：⭐数量表示评分（1-5星）');
    buffer.writeln('- 标签：#标签 格式');
    buffer.writeln('- 地点：完整地址信息');
    buffer.writeln('- 心情：用户当时的心情');
    buffer.writeln('- 图片：图片数量（AI无法查看图片内容）');
    buffer.writeln('- 关联：与其他记录/朋友的关联关系');
    buffer.writeln('- ⭐标记：表示用户收藏的记录');
    buffer.writeln('');
    
    buffer.writeln('## 回复原则');
    buffer.writeln('1. **基于真实数据**：严格基于提供的记录数据回答，不要编造或臆测');
    buffer.writeln('2. **完整引用**：引用记录时保留原始内容，不要过度概括或省略关键信息');
    buffer.writeln('3. **准确引用**：如果记录中有具体的时间、地点、评分，请准确引用');
    buffer.writeln('4. **温暖有温度**：语气温暖，像写给未来自己的一封信');
    buffer.writeln('5. **发现联系**：主动关联相关记忆，帮助用户发现隐藏的联系');
    buffer.writeln('6. **诚实告知**：如果找不到相关记录，诚实告知并建议其他探索方向');
    buffer.writeln('');
    
    buffer.writeln('## 推荐卡片格式');
    buffer.writeln('如果你想在回复中推荐相关记录，请在回复末尾使用以下JSON格式（最多推荐5条）：');
    buffer.writeln('```json');
    buffer.writeln('{"recommendations": [');
    buffer.writeln('  {');
    buffer.writeln('    "type": "food|moment|travel|goal|encounter",');
    buffer.writeln('    "id": "记录ID（从记录中获取）",');
    buffer.writeln('    "title": "标题",');
    buffer.writeln('    "summary": "简短描述（30字以内）",');
    buffer.writeln('    "imageUrl": "第一张图片路径（如果有图片）",');
    buffer.writeln('    "rating": 4.5,');
    buffer.writeln('    "tags": ["标签1", "标签2"],');
    buffer.writeln('    "date": "2024-03-10",');
    buffer.writeln('    "isFavorite": true');
    buffer.writeln('  }');
    buffer.writeln(']}');
    buffer.writeln('```');
    buffer.writeln('');
    buffer.writeln('**重要**：推荐卡片中的 id 必须是记录中的真实 ID，type 必须是以下之一：food、moment、travel、goal、encounter');
    
    return buffer.toString();
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final startStr = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endStr = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    return '$startStr 至 $endStr';
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday - 1];
  }

  String? _detectQueryFocus(String query) {
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('美食') || lowerQuery.contains('餐厅') || lowerQuery.contains('吃') || lowerQuery.contains('好吃')) {
      return '用户对美食相关内容感兴趣，请重点关注：评分、人均价格、标签、地点、口味描述等。';
    }
    if (lowerQuery.contains('旅行') || lowerQuery.contains('旅游') || lowerQuery.contains('出行') || lowerQuery.contains('景点')) {
      return '用户对旅行相关内容感兴趣，请重点关注：目的地、行程、费用、心情、同行人员等。';
    }
    if (lowerQuery.contains('心情') || lowerQuery.contains('感受') || lowerQuery.contains('开心') || lowerQuery.contains('快乐') || lowerQuery.contains('难过')) {
      return '用户对心情感受相关内容感兴趣，请重点关注：心情状态、内容描述、当时情境等。';
    }
    if (lowerQuery.contains('目标') || lowerQuery.contains('计划') || lowerQuery.contains('完成') || lowerQuery.contains('进度')) {
      return '用户对目标计划相关内容感兴趣，请重点关注：目标进度、完成状态、截止日期、总结等。';
    }
    if (lowerQuery.contains('朋友') || lowerQuery.contains('相遇') || lowerQuery.contains('见面') || lowerQuery.contains('一起')) {
      return '用户对朋友相遇相关内容感兴趣，请重点关注：相遇时间、地点、同行人员、活动内容等。';
    }
    if (lowerQuery.contains('花费') || lowerQuery.contains('消费') || lowerQuery.contains('价格') || lowerQuery.contains('费用')) {
      return '用户对消费花费相关内容感兴趣，请重点关注：人均价格、各项费用、消费地点等。';
    }
    if (lowerQuery.contains('评分') || lowerQuery.contains('评价') || lowerQuery.contains('推荐')) {
      return '用户对评分评价相关内容感兴趣，请重点关注：评分、标签、推荐理由等。';
    }
    
    return null;
  }

  Future<List<RecordContext>> _retrieveRecordsForQuery(String query, {bool fullData = false}) async {
    final cacheKey = 'query:${query.hashCode}:full:$fullData';
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.value;
    }
    
    final startTime = DateTime.now();
    
    final baseRecords = await _retrieveAllRecords(fullData: fullData);
    
    final queryType = _classifyQuery(query);
    List<RecordContext> additionalRecords = [];
    
    if (queryType == QueryType.timeRange) {
      final timeRange = _extractTimeRange(query);
      if (timeRange != null) {
        additionalRecords = await _retriever.retrieveRecords(
          queryType: QueryType.timeRange,
          userQuery: query,
          startDate: timeRange['start'],
          endDate: timeRange['end'],
          limit: fullData ? 1000 : 50,
          fullData: fullData,
        );
      }
    } else if (queryType == QueryType.summary) {
      final module = _extractModule(query);
      if (module != 'all') {
        additionalRecords = await _retriever.retrieveRecords(
          queryType: QueryType.summary,
          userQuery: query,
          module: module,
          limit: fullData ? 1000 : 50,
          fullData: fullData,
        );
      }
    } else if (queryType == QueryType.onThisDay) {
      additionalRecords = await _retriever.retrieveRecords(
        queryType: QueryType.onThisDay,
        userQuery: query,
        limit: fullData ? 1000 : 50,
        fullData: fullData,
      );
    } else if (queryType == QueryType.query) {
      final semanticRecords = await _semanticSearchWithFallback(query, fullData: fullData);
      additionalRecords = semanticRecords;
    }
    
    final records = _mergeRecords(baseRecords, additionalRecords);
    
    _cache[cacheKey] = _CacheEntry(records, DateTime.now());
    
    final retrievalTime = DateTime.now().difference(startTime);
    final queryFocus = _detectQueryFocus(query);
    final estimatedTokens = _estimateTokens(records);
    
    final log = ContextLog(
      timestamp: startTime,
      query: query,
      recordCount: records.length,
      estimatedTokens: estimatedTokens,
      retrievalTime: retrievalTime,
      fullData: fullData,
      queryFocus: queryFocus,
    );
    
    _logs.insert(0, log);
    if (_logs.length > _maxLogs) {
      _logs.removeLast();
    }
    
    developer.log(
      'AI史官上下文: ${records.length}条记录 (基础${baseRecords.length}+补充${additionalRecords.length}), 约${estimatedTokens}tokens, 耗时${retrievalTime.inMilliseconds}ms',
      name: 'ContextBuilder',
    );
    
    return records;
  }

  int _estimateTokens(List<RecordContext> records) {
    int totalChars = 0;
    for (final record in records) {
      totalChars += record.title.length;
      totalChars += record.content.length;
      totalChars += record.toPromptString().length;
    }
    return (totalChars / 2).round();
  }

  Future<List<RecordContext>> _semanticSearchWithFallback(String query, {bool fullData = false}) async {
    final vectorService = _vectorServiceGetter?.call();
    
    if (vectorService != null) {
      try {
        final semanticResults = await vectorService.searchByText(
          query: query,
          limit: fullData ? 50 : 10,
          minSimilarity: 0.3,
        );
        
        if (semanticResults.isNotEmpty) {
          final records = <RecordContext>[];
          for (final result in semanticResults) {
            final record = await _fetchRecordFromSemanticResult(result);
            if (record != null) {
              records.add(record);
            }
          }
          
          if (records.isNotEmpty) {
            return records;
          }
        }
      } catch (e) {
        // 语义搜索失败，回退到关键词搜索
      }
    }
    
    return _retriever.retrieveRecords(
      queryType: QueryType.query,
      userQuery: query,
      limit: fullData ? 100 : 20,
      fullData: fullData,
    );
  }

  Future<RecordContext?> _fetchRecordFromSemanticResult(SimilarityMatch result) async {
    final record = await _retriever.fetchRecordById(result.entityType, result.entityId);
    return record;
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
      // 计算上周的时间范围
      // 上周一 = 今天 - (weekday + 6) 天
      // 例如：今天是周三(weekday=3)，上周一 = 今天 - 9天
      // 验证：周三减9天 = 上周一 ✓
      final daysToLastMonday = now.weekday + 6;
      final lastMonday = now.subtract(Duration(days: daysToLastMonday));
      final lastSunday = lastMonday.add(const Duration(days: 6));
      return {
        'start': DateTime(lastMonday.year, lastMonday.month, lastMonday.day),
        'end': DateTime(lastSunday.year, lastSunday.month, lastSunday.day, 23, 59, 59),
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

  Future<List<RecordContext>> _retrieveAllRecords({bool fullData = false}) async {
    final cacheKey = 'all_records:full:$fullData';
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.value;
    }
    
    final records = await _retriever.retrieveRecords(
      queryType: QueryType.summary,
      userQuery: '',
      module: 'all',
      limit: fullData ? 1000 : 50,
      fullData: fullData,
    );
    
    _cache[cacheKey] = _CacheEntry(records, DateTime.now());
    return records;
  }

  List<RecordContext> _mergeRecords(
    List<RecordContext> baseRecords,
    List<RecordContext> additionalRecords,
  ) {
    final recordMap = <String, RecordContext>{};
    
    for (final record in baseRecords) {
      recordMap['${record.type}_${record.id}'] = record;
    }
    
    for (final record in additionalRecords) {
      recordMap['${record.type}_${record.id}'] = record;
    }
    
    return recordMap.values.toList()
      ..sort((a, b) {
        final favoriteCompare = (b.isFavorite ? 1 : 0) - (a.isFavorite ? 1 : 0);
        if (favoriteCompare != 0) return favoriteCompare;
        return b.date.compareTo(a.date);
      });
  }

  Future<List<RecordContext>> retrieveForQuickAction(String actionType, {bool fullData = false}) async {
    final cacheKey = 'quick:$actionType:full:$fullData';
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.value;
    }
    
    final baseRecords = await _retrieveAllRecords(fullData: fullData);
    
    List<RecordContext> specificRecords;
    
    switch (actionType) {
      case 'mood_summary':
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1);
        final start = DateTime(lastMonth.year, lastMonth.month, 1);
        final end = DateTime(now.year, now.month, 1);
        specificRecords = await _retriever.retrieveRecords(
          queryType: QueryType.timeRange,
          userQuery: '',
          module: 'moment',
          startDate: start,
          endDate: end,
          limit: fullData ? 1000 : 50,
          fullData: fullData,
        );
        break;
        
      case 'goal_progress':
        final now = DateTime.now();
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year + 1, 1, 1);
        specificRecords = await _retriever.retrieveRecords(
          queryType: QueryType.timeRange,
          userQuery: '',
          module: 'goal',
          startDate: start,
          endDate: end,
          limit: fullData ? 1000 : 50,
          fullData: fullData,
        );
        break;
        
      case 'on_this_day':
        specificRecords = await _retriever.retrieveRecords(
          queryType: QueryType.onThisDay,
          userQuery: '',
          limit: fullData ? 1000 : 50,
          fullData: fullData,
        );
        break;
        
      default:
        specificRecords = [];
    }
    
    final records = _mergeRecords(baseRecords, specificRecords);
    
    _cache[cacheKey] = _CacheEntry(records, DateTime.now());
    return records;
  }
  
  static void clearCache() {
    _cache.clear();
  }
  
  static void clearExpiredCache() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }
}
