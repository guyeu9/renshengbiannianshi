import 'package:drift/drift.dart';
import 'package:life_chronicle/core/database/app_database.dart';

enum QueryType {
  summary,
  query,
  timeRange,
  statistics,
  onThisDay,
  general,
}

class RecordContext {
  final String type;
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final Map<String, dynamic> extra;

  const RecordContext({
    required this.type,
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.extra = const {},
  });

  String toPromptString() {
    final buffer = StringBuffer();
    buffer.write('- [$type] ');
    if (title.isNotEmpty) {
      buffer.write(title);
    }
    if (content.isNotEmpty) {
      buffer.write(': $content');
    }
    buffer.write(' (${_formatDate(date)})');
    
    if (extra.isNotEmpty) {
      final extraParts = <String>[];
      if (extra['rating'] != null) {
        extraParts.add('评分${extra['rating']}');
      }
      if (extra['city'] != null && extra['city'].toString().isNotEmpty) {
        extraParts.add(extra['city'].toString());
      }
      if (extra['mood'] != null && extra['mood'].toString().isNotEmpty) {
        extraParts.add('心情: ${extra['mood']}');
      }
      if (extra['destination'] != null && extra['destination'].toString().isNotEmpty) {
        extraParts.add(extra['destination'].toString());
      }
      if (extra['level'] != null) {
        extraParts.add('级别: ${extra['level']}');
      }
      if (extra['isCompleted'] != null) {
        extraParts.add(extra['isCompleted'] ? '已完成' : '进行中');
      }
      if (extraParts.isNotEmpty) {
        buffer.write(' [${extraParts.join(', ')}]');
      }
    }
    
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class RecordRetriever {
  final AppDatabase _db;

  RecordRetriever(this._db);

  Future<List<RecordContext>> retrieveRecords({
    required QueryType queryType,
    required String userQuery,
    String? module,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    switch (queryType) {
      case QueryType.summary:
        return _retrieveAllForModule(module ?? 'all');
      case QueryType.timeRange:
        return _retrieveByTimeRange(startDate, endDate, limit);
      case QueryType.onThisDay:
        return _retrieveOnThisDay();
      case QueryType.query:
      case QueryType.statistics:
      case QueryType.general:
        return _retrieveByKeywords(userQuery, limit);
    }
  }

  Future<List<RecordContext>> _retrieveAllForModule(String module) async {
    final records = <RecordContext>[];
    
    if (module == 'all' || module == 'food') {
      records.addAll(await _loadAllFoodRecords());
    }
    if (module == 'all' || module == 'moment') {
      records.addAll(await _loadAllMomentRecords());
    }
    if (module == 'all' || module == 'travel') {
      records.addAll(await _loadAllTravelRecords());
    }
    if (module == 'all' || module == 'goal') {
      records.addAll(await _loadAllGoalRecords());
    }
    if (module == 'all' || module == 'encounter') {
      records.addAll(await _loadAllEncounterRecords());
    }
    
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<List<RecordContext>> _retrieveByTimeRange(
    DateTime? startDate,
    DateTime? endDate,
    int limit,
  ) async {
    final records = <RecordContext>[];
    
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    records.addAll(await _loadFoodByTimeRange(start, end, limit));
    records.addAll(await _loadMomentByTimeRange(start, end, limit));
    records.addAll(await _loadTravelByTimeRange(start, end, limit));
    records.addAll(await _loadGoalByTimeRange(start, end, limit));
    records.addAll(await _loadEncounterByTimeRange(start, end, limit));

    records.sort((a, b) => b.date.compareTo(a.date));
    return records.take(limit).toList();
  }

  Future<List<RecordContext>> _retrieveOnThisDay() async {
    final records = <RecordContext>[];
    final now = DateTime.now();
    
    for (int i = 1; i <= 5; i++) {
      final targetDate = DateTime(now.year - i, now.month, now.day);
      final nextDay = targetDate.add(const Duration(days: 1));
      
      records.addAll(await _loadFoodByTimeRange(targetDate, nextDay, 5));
      records.addAll(await _loadMomentByTimeRange(targetDate, nextDay, 5));
      records.addAll(await _loadTravelByTimeRange(targetDate, nextDay, 5));
      records.addAll(await _loadGoalByTimeRange(targetDate, nextDay, 5));
      records.addAll(await _loadEncounterByTimeRange(targetDate, nextDay, 5));
    }

    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<List<RecordContext>> _retrieveByKeywords(String query, int limit) async {
    final records = <RecordContext>[];
    final keywords = _extractKeywords(query);

    records.addAll(await _searchFoodRecords(keywords, limit));
    records.addAll(await _searchMomentRecords(keywords, limit));
    records.addAll(await _searchTravelRecords(keywords, limit));
    records.addAll(await _searchGoalRecords(keywords, limit));
    records.addAll(await _searchEncounterRecords(keywords, limit));

    records.sort((a, b) => b.date.compareTo(a.date));
    return records.take(limit).toList();
  }

  List<String> _extractKeywords(String query) {
    final stopWords = {'的', '了', '是', '在', '有', '和', '与', '或', '我', '你', '他', '她', '它', '这', '那', '什么', '怎么', '如何', '为什么', '哪', '吗', '呢', '吧', '啊', '呀', '请', '帮', '给', '告诉', '说', '问', '想', '要', '能', '会', '可以', '应该', '需要', '总结', '分析', '查看', '看看', '一下', '一些', '所有', '全部', '记录', '数据'};
    
    final words = query.replaceAll(RegExp(r'[^\u4e00-\u9fa5a-zA-Z0-9]'), ' ').split(' ');
    return words
        .where((w) => w.isNotEmpty && !stopWords.contains(w) && w.length > 1)
        .toList();
  }

  Future<List<RecordContext>> _loadAllFoodRecords() async {
    final foods = await (_db.select(_db.foodRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
    
    return foods.map((f) => RecordContext(
      type: '美食',
      id: f.id,
      title: f.title,
      content: f.content ?? '',
      date: f.recordDate,
      extra: {'rating': f.rating, 'city': f.city, 'poiName': f.poiName},
    )).toList();
  }

  Future<List<RecordContext>> _loadAllMomentRecords() async {
    final moments = await (_db.select(_db.momentRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
    
    return moments.map((m) => RecordContext(
      type: '小确幸',
      id: m.id,
      title: '',
      content: m.content ?? '',
      date: m.recordDate,
      extra: {'mood': m.mood, 'city': m.city},
    )).toList();
  }

  Future<List<RecordContext>> _loadAllTravelRecords() async {
    final travels = await (_db.select(_db.travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
    
    return travels.map((t) => RecordContext(
      type: '旅行',
      id: t.id,
      title: t.title ?? '',
      content: t.content ?? '',
      date: t.recordDate,
      extra: {'destination': t.destination, 'city': t.city},
    )).toList();
  }

  Future<List<RecordContext>> _loadAllGoalRecords() async {
    final goals = await (_db.select(_db.goalRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
    
    return goals.map((g) => RecordContext(
      type: '目标',
      id: g.id,
      title: g.title,
      content: g.note ?? '',
      date: g.recordDate,
      extra: {'level': g.level, 'isCompleted': g.isCompleted},
    )).toList();
  }

  Future<List<RecordContext>> _loadAllEncounterRecords() async {
    final encounters = await (_db.select(_db.timelineEvents)
          ..where((t) => t.eventType.equals('encounter'))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
    
    return encounters.map((e) => RecordContext(
      type: '相遇',
      id: e.id,
      title: e.title ?? '',
      content: e.note ?? '',
      date: e.recordDate,
      extra: {},
    )).toList();
  }

  Future<List<RecordContext>> _loadFoodByTimeRange(DateTime start, DateTime end, int limit) async {
    final foods = await (_db.select(_db.foodRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(limit))
        .get();
    
    return foods.map((f) => RecordContext(
      type: '美食',
      id: f.id,
      title: f.title,
      content: f.content ?? '',
      date: f.recordDate,
      extra: {'rating': f.rating, 'city': f.city},
    )).toList();
  }

  Future<List<RecordContext>> _loadMomentByTimeRange(DateTime start, DateTime end, int limit) async {
    final moments = await (_db.select(_db.momentRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(limit))
        .get();
    
    return moments.map((m) => RecordContext(
      type: '小确幸',
      id: m.id,
      title: '',
      content: m.content ?? '',
      date: m.recordDate,
      extra: {'mood': m.mood},
    )).toList();
  }

  Future<List<RecordContext>> _loadTravelByTimeRange(DateTime start, DateTime end, int limit) async {
    final travels = await (_db.select(_db.travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(limit))
        .get();
    
    return travels.map((t) => RecordContext(
      type: '旅行',
      id: t.id,
      title: t.title ?? '',
      content: t.content ?? '',
      date: t.recordDate,
      extra: {'destination': t.destination},
    )).toList();
  }

  Future<List<RecordContext>> _loadGoalByTimeRange(DateTime start, DateTime end, int limit) async {
    final goals = await (_db.select(_db.goalRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(limit))
        .get();
    
    return goals.map((g) => RecordContext(
      type: '目标',
      id: g.id,
      title: g.title,
      content: g.note ?? '',
      date: g.recordDate,
      extra: {'level': g.level, 'isCompleted': g.isCompleted},
    )).toList();
  }

  Future<List<RecordContext>> _loadEncounterByTimeRange(DateTime start, DateTime end, int limit) async {
    final encounters = await (_db.select(_db.timelineEvents)
          ..where((t) => t.eventType.equals('encounter'))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(limit))
        .get();
    
    return encounters.map((e) => RecordContext(
      type: '相遇',
      id: e.id,
      title: e.title ?? '',
      content: e.note ?? '',
      date: e.recordDate,
      extra: {},
    )).toList();
  }

  Future<List<RecordContext>> _searchFoodRecords(List<String> keywords, int limit) async {
    if (keywords.isEmpty) return [];
    
    final query = _db.select(_db.foodRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
      ..limit(limit);
    
    query.where((t) {
      var expr = t.title.like('%${keywords.first}%');
      for (final kw in keywords.skip(1)) {
        expr = expr | t.title.like('%$kw%') | t.content.like('%$kw%') | t.city.like('%$kw%');
      }
      return expr;
    });
    
    final foods = await query.get();
    return foods.map((f) => RecordContext(
      type: '美食',
      id: f.id,
      title: f.title,
      content: f.content ?? '',
      date: f.recordDate,
      extra: {'rating': f.rating, 'city': f.city},
    )).toList();
  }

  Future<List<RecordContext>> _searchMomentRecords(List<String> keywords, int limit) async {
    if (keywords.isEmpty) return [];
    
    final query = _db.select(_db.momentRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
      ..limit(limit);
    
    query.where((t) {
      var expr = t.content.like('%${keywords.first}%');
      for (final kw in keywords.skip(1)) {
        expr = expr | t.content.like('%$kw%');
      }
      return expr;
    });
    
    final moments = await query.get();
    return moments.map((m) => RecordContext(
      type: '小确幸',
      id: m.id,
      title: '',
      content: m.content ?? '',
      date: m.recordDate,
      extra: {'mood': m.mood},
    )).toList();
  }

  Future<List<RecordContext>> _searchTravelRecords(List<String> keywords, int limit) async {
    if (keywords.isEmpty) return [];
    
    final query = _db.select(_db.travelRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
      ..limit(limit);
    
    query.where((t) {
      var expr = t.title.like('%${keywords.first}%') | t.destination.like('%${keywords.first}%');
      for (final kw in keywords.skip(1)) {
        expr = expr | t.title.like('%$kw%') | t.destination.like('%$kw%') | t.content.like('%$kw%');
      }
      return expr;
    });
    
    final travels = await query.get();
    return travels.map((t) => RecordContext(
      type: '旅行',
      id: t.id,
      title: t.title ?? '',
      content: t.content ?? '',
      date: t.recordDate,
      extra: {'destination': t.destination},
    )).toList();
  }

  Future<List<RecordContext>> _searchGoalRecords(List<String> keywords, int limit) async {
    if (keywords.isEmpty) return [];
    
    final query = _db.select(_db.goalRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
      ..limit(limit);
    
    query.where((t) {
      var expr = t.title.like('%${keywords.first}%');
      for (final kw in keywords.skip(1)) {
        expr = expr | t.title.like('%$kw%') | t.note.like('%$kw%');
      }
      return expr;
    });
    
    final goals = await query.get();
    return goals.map((g) => RecordContext(
      type: '目标',
      id: g.id,
      title: g.title,
      content: g.note ?? '',
      date: g.recordDate,
      extra: {'level': g.level, 'isCompleted': g.isCompleted},
    )).toList();
  }

  Future<List<RecordContext>> _searchEncounterRecords(List<String> keywords, int limit) async {
    if (keywords.isEmpty) return [];
    
    final query = _db.select(_db.timelineEvents)
      ..where((t) => t.eventType.equals('encounter'))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
      ..limit(limit);
    
    query.where((t) {
      var expr = t.title.like('%${keywords.first}%') | t.note.like('%${keywords.first}%');
      for (final kw in keywords.skip(1)) {
        expr = expr | t.title.like('%$kw%') | t.note.like('%$kw%');
      }
      return expr;
    });
    
    final encounters = await query.get();
    return encounters.map((e) => RecordContext(
      type: '相遇',
      id: e.id,
      title: e.title ?? '',
      content: e.note ?? '',
      date: e.recordDate,
      extra: {},
    )).toList();
  }
}
