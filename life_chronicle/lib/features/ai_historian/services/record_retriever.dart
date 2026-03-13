import 'dart:convert';
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

class EntityLinkInfo {
  final String targetType;
  final String targetId;
  final String? targetTitle;
  final String linkType;

  const EntityLinkInfo({
    required this.targetType,
    required this.targetId,
    this.targetTitle,
    this.linkType = 'manual',
  });

  String toDisplayString() {
    final typeNames = {
      'food': '美食',
      'moment': '小确幸',
      'travel': '旅行',
      'goal': '目标',
      'encounter': '相遇',
      'friend': '朋友',
    };
    final typeName = typeNames[targetType] ?? targetType;
    if (targetTitle != null && targetTitle!.isNotEmpty) {
      return '$typeName·$targetTitle';
    }
    return typeName;
  }
}

class RecordContext {
  final String type;
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final Map<String, dynamic> extra;
  
  final List<String>? images;
  final List<String>? tags;
  final bool isFavorite;
  final List<EntityLinkInfo>? links;

  const RecordContext({
    required this.type,
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.extra = const {},
    this.images,
    this.tags,
    this.isFavorite = false,
    this.links,
  });

  String toPromptString() {
    final buffer = StringBuffer();
    
    final favoriteMark = isFavorite ? ' ⭐' : '';
    buffer.writeln('【$type$favoriteMark】');
    buffer.writeln('ID: $id');
    
    if (title.isNotEmpty) {
      buffer.writeln('标题：$title');
    }
    
    if (content.isNotEmpty) {
      buffer.writeln('内容：$content');
    }
    
    if (extra['rating'] != null) {
      final rating = extra['rating'] as num;
      final stars = '⭐' * rating.round();
      buffer.writeln('评分：$stars (${rating.toStringAsFixed(1)}/5)');
    }
    
    if (extra['pricePerPerson'] != null) {
      buffer.writeln('人均：¥${(extra['pricePerPerson'] as num).toStringAsFixed(0)}');
    }
    
    if (extra['mood'] != null && extra['mood'].toString().isNotEmpty) {
      buffer.writeln('心情：${extra['mood']}');
    }
    
    if (tags != null && tags!.isNotEmpty) {
      buffer.writeln('标签：${tags!.map((t) => '#$t').join(' ')}');
    }
    
    final locationParts = <String>[];
    if (extra['poiName'] != null && extra['poiName'].toString().isNotEmpty) {
      locationParts.add(extra['poiName'].toString());
    }
    if (extra['poiAddress'] != null && extra['poiAddress'].toString().isNotEmpty) {
      locationParts.add(extra['poiAddress'].toString());
    }
    if (extra['city'] != null && extra['city'].toString().isNotEmpty) {
      locationParts.add(extra['city'].toString());
    }
    if (extra['country'] != null && extra['country'].toString().isNotEmpty) {
      locationParts.add(extra['country'].toString());
    }
    if (locationParts.isNotEmpty) {
      buffer.writeln('地点：${locationParts.join(' ')}');
    }
    
    if (extra['destination'] != null && extra['destination'].toString().isNotEmpty) {
      buffer.writeln('目的地：${extra['destination']}');
    }
    
    if (extra['level'] != null) {
      buffer.writeln('级别：${extra['level']}');
    }
    
    if (extra['progress'] != null) {
      buffer.writeln('进度：${(extra['progress'] as num).toStringAsFixed(0)}%');
    }
    
    if (extra['isCompleted'] != null) {
      buffer.writeln('状态：${extra['isCompleted'] == true ? '已完成' : '进行中'}');
    }
    
    if (extra['dueDate'] != null) {
      buffer.writeln('截止日期：${_formatDate(extra['dueDate'] as DateTime)}');
    }
    
    if (extra['targetYear'] != null) {
      final year = extra['targetYear'];
      final quarter = extra['targetQuarter'];
      final month = extra['targetMonth'];
      String target = '$year年';
      if (quarter != null) {
        target += ' Q$quarter';
      }
      if (month != null) {
        target += ' $month月';
      }
      buffer.writeln('目标时间：$target');
    }
    
    if (images != null && images!.isNotEmpty) {
      buffer.writeln('图片：共${images!.length}张');
    }
    
    if (links != null && links!.isNotEmpty) {
      final linkStrs = links!.map((l) => l.toDisplayString()).join('、');
      buffer.writeln('关联：$linkStrs');
    }
    
    buffer.writeln('日期：${_formatDateTime(date)}');
    buffer.writeln('---');
    
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
    bool fullData = false,
  }) async {
    switch (queryType) {
      case QueryType.summary:
        return _retrieveAllForModule(module ?? 'all', fullData ? null : limit);
      case QueryType.timeRange:
        return _retrieveByTimeRange(startDate, endDate, fullData ? null : limit);
      case QueryType.onThisDay:
        return _retrieveOnThisDay();
      case QueryType.query:
      case QueryType.statistics:
      case QueryType.general:
        return _retrieveByKeywords(userQuery, fullData ? null : limit);
    }
  }

  Future<List<RecordContext>> _retrieveAllForModule(String module, int? limit) async {
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
    if (module == 'all' || module == 'encounter' || module == 'bond') {
      records.addAll(await _loadAllEncounterRecords());
    }
    
    records.sort((a, b) {
      final favoriteCompare = (b.isFavorite ? 1 : 0) - (a.isFavorite ? 1 : 0);
      if (favoriteCompare != 0) return favoriteCompare;
      return b.date.compareTo(a.date);
    });
    
    if (limit != null && records.length > limit) {
      return records.take(limit).toList();
    }
    return records;
  }

  Future<List<RecordContext>> _retrieveByTimeRange(
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  ) async {
    final records = <RecordContext>[];
    
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    final perTypeLimit = limit != null ? (limit ~/ 5 + 5) : null;

    records.addAll(await _loadFoodByTimeRange(start, end, perTypeLimit));
    records.addAll(await _loadMomentByTimeRange(start, end, perTypeLimit));
    records.addAll(await _loadTravelByTimeRange(start, end, perTypeLimit));
    records.addAll(await _loadGoalByTimeRange(start, end, perTypeLimit));
    records.addAll(await _loadEncounterByTimeRange(start, end, perTypeLimit));

    records.sort((a, b) {
      final favoriteCompare = (b.isFavorite ? 1 : 0) - (a.isFavorite ? 1 : 0);
      if (favoriteCompare != 0) return favoriteCompare;
      return b.date.compareTo(a.date);
    });
    
    if (limit != null && records.length > limit) {
      return records.take(limit).toList();
    }
    return records;
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

    
    records.sort((a, b) {
      if (a.isFavorite != b.isFavorite) {
        return a.isFavorite ? -1 : 1;
      }
      return b.date.compareTo(a.date);
    });
    
    return records;
  }

  Future<List<RecordContext>> _retrieveByKeywords(String query, int? limit) async {
    final records = <RecordContext>[];
    final keywords = _extractKeywords(query);
    final perTypeLimit = limit != null ? (limit ~/ 5 + 5) : null;

    records.addAll(await _searchFoodRecords(keywords, perTypeLimit));
    records.addAll(await _searchMomentRecords(keywords, perTypeLimit));
    records.addAll(await _searchTravelRecords(keywords, perTypeLimit));
    records.addAll(await _searchGoalRecords(keywords, perTypeLimit));
    records.addAll(await _searchEncounterRecords(keywords, perTypeLimit));

    records.sort((a, b) {
      if (a.isFavorite != b.isFavorite) {
        return a.isFavorite ? -1 : 1;
      }
      return b.date.compareTo(a.date);
    });
    
    if (limit != null && records.length > limit) {
      return records.take(limit).toList();
    }
    return records;
  }

  List<String> _extractKeywords(String query) {
    final stopWords = {'的', '了', '是', '在', '有', '和', '与', '或', '我', '你', '他', '她', '它', '这', '那', '什么', '怎么', '如何', '为什么', '哪', '吗', '呢', '吧', '啊', '呀', '请', '帮', '给', '告诉', '说', '问', '想', '要', '能', '会', '可以', '应该', '需要', '总结', '分析', '查看', '看看', '一下', '一些', '所有', '全部', '记录', '数据'};
    
    final words = query.replaceAll(RegExp(r'[^\u4e00-\u9fa5a-zA-Z0-9]'), ' ').split(' ');
    return words
        .where((w) => w.isNotEmpty && !stopWords.contains(w) && w.length > 1)
        .toList();
  }

  List<String> _parseTags(String? tagsJson) {
    if (tagsJson == null || tagsJson.isEmpty) return [];
    try {
      final decoded = jsonDecode(tagsJson);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      if (decoded is String) {
        return decoded.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    } catch (e) {
      debugPrint('解析标签JSON失败，使用逗号分隔解析: $e');
      return tagsJson.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  List<String> _parseImages(String? imagesJson) {
    if (imagesJson == null || imagesJson.isEmpty) return [];
    try {
      final decoded = jsonDecode(imagesJson);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('解析图片JSON失败: $e');
    }
    return [];
  }

  Future<List<EntityLinkInfo>> _loadLinks(String entityType, String entityId) async {
    final links = await (_db.select(_db.entityLinks)
          ..where((t) => t.sourceType.equals(entityType))
          ..where((t) => t.sourceId.equals(entityId)))
        .get();
    
    final result = <EntityLinkInfo>[];
    for (final link in links) {
      String? targetTitle;
      if (link.targetType == 'friend') {
        final friend = await (_db.select(_db.friendRecords)
              ..where((t) => t.id.equals(link.targetId)))
            .getSingleOrNull();
        targetTitle = friend?.name;
      }
      result.add(EntityLinkInfo(
        targetType: link.targetType,
        targetId: link.targetId,
        targetTitle: targetTitle,
        linkType: link.linkType,
      ));
    }
    return result;
  }

  Future<Map<String, List<EntityLinkInfo>>> _batchLoadLinks(
    String entityType,
    List<String> entityIds,
  ) async {
    if (entityIds.isEmpty) return {};
    
    final allLinks = await _db.linkDao.listLinksForEntities(
      entityType: entityType,
      entityIds: entityIds,
    );
    
    final friendIds = <String>{};
    for (final link in allLinks) {
      if (link.targetType == 'friend') {
        friendIds.add(link.targetId);
      }
      if (link.sourceType == 'friend') {
        friendIds.add(link.sourceId);
      }
    }
    
    final friendNames = <String, String>{};
    if (friendIds.isNotEmpty) {
      final friends = await (_db.select(_db.friendRecords)
            ..where((t) => t.id.isIn(friendIds.toList())))
          .get();
      for (final friend in friends) {
        friendNames[friend.id] = friend.name;
      }
    }
    
    final linksByEntityId = <String, List<EntityLinkInfo>>{};
    for (final link in allLinks) {
      String entityId;
      EntityLinkInfo linkInfo;
      
      if (link.sourceType == entityType && entityIds.contains(link.sourceId)) {
        entityId = link.sourceId;
        linkInfo = EntityLinkInfo(
          targetType: link.targetType,
          targetId: link.targetId,
          targetTitle: friendNames[link.targetId],
          linkType: link.linkType,
        );
      } else if (link.targetType == entityType && entityIds.contains(link.targetId)) {
        entityId = link.targetId;
        linkInfo = EntityLinkInfo(
          targetType: link.sourceType,
          targetId: link.sourceId,
          targetTitle: friendNames[link.sourceId],
          linkType: link.linkType,
        );
      } else {
        continue;
      }
      
      (linksByEntityId[entityId] ??= []).add(linkInfo);
    }
    
    return linksByEntityId;
  }

  Future<List<RecordContext>> _loadAllFoodRecords([int? limit]) async {
    var query = _db.select(_db.foodRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    final foods = await query.get();
    
    if (foods.isEmpty) return [];
    
    final foodIds = foods.map((f) => f.id).toList();
    final linksByFoodId = await _batchLoadLinks('food', foodIds);
    
    return foods.map((f) => RecordContext(
      type: '美食',
      id: f.id,
      title: f.title,
      content: f.content ?? '',
      date: f.recordDate,
      images: _parseImages(f.images),
      tags: _parseTags(f.tags),
      isFavorite: f.isFavorite,
      links: linksByFoodId[f.id]?.isNotEmpty == true ? linksByFoodId[f.id] : null,
      extra: {
        'rating': f.rating,
        'pricePerPerson': f.pricePerPerson,
        'mood': f.mood,
        'poiName': f.poiName,
        'poiAddress': f.poiAddress,
        'city': f.city,
        'country': f.country,
        'link': f.link,
        'isWishlist': f.isWishlist,
        'wishlistDone': f.wishlistDone,
      },
    )).toList();
  }

  Future<List<RecordContext>> _loadAllMomentRecords([int? limit]) async {
    var query = _db.select(_db.momentRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    final moments = await query.get();
    
    if (moments.isEmpty) return [];
    
    final momentIds = moments.map((m) => m.id).toList();
    final linksByMomentId = await _batchLoadLinks('moment', momentIds);
    
    return moments.map((m) => RecordContext(
      type: '小确幸',
      id: m.id,
      title: '',
      content: m.content ?? '',
      date: m.recordDate,
      images: _parseImages(m.images),
      tags: _parseTags(m.tags),
      isFavorite: m.isFavorite,
      links: linksByMomentId[m.id]?.isNotEmpty == true ? linksByMomentId[m.id] : null,
      extra: {
        'mood': m.mood,
        'moodColor': m.moodColor,
        'poiName': m.poiName,
        'poiAddress': m.poiAddress,
        'city': m.city,
      },
    )).toList();
  }

  Future<List<RecordContext>> _loadAllTravelRecords([int? limit]) async {
    var query = _db.select(_db.travelRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    final travels = await query.get();
    
    if (travels.isEmpty) return [];
    
    final travelIds = travels.map((t) => t.id).toList();
    final linksByTravelId = await _batchLoadLinks('travel', travelIds);
    
    return travels.map((t) => RecordContext(
      type: '旅行',
      id: t.id,
      title: t.title ?? '',
      content: t.content ?? '',
      date: t.recordDate,
      images: _parseImages(t.images),
      tags: _parseTags(t.tags),
      isFavorite: t.isFavorite,
      links: linksByTravelId[t.id]?.isNotEmpty == true ? linksByTravelId[t.id] : null,
      extra: {
        'tripId': t.tripId,
        'destination': t.destination,
        'poiName': t.poiName,
        'poiAddress': t.poiAddress,
        'city': t.city,
        'country': t.country,
        'mood': t.mood,
        'expenseTransport': t.expenseTransport,
        'expenseHotel': t.expenseHotel,
        'expenseFood': t.expenseFood,
        'expenseTicket': t.expenseTicket,
        'flightLink': t.flightLink,
        'hotelLink': t.hotelLink,
        'isWishlist': t.isWishlist,
        'wishlistDone': t.wishlistDone,
        'isJournal': t.isJournal,
        'planDate': t.planDate,
      },
    )).toList();
  }

  Future<List<RecordContext>> _loadAllGoalRecords([int? limit]) async {
    var query = _db.select(_db.goalRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    final goals = await query.get();
    
    if (goals.isEmpty) return [];
    
    final goalIds = goals.map((g) => g.id).toList();
    final linksByGoalId = await _batchLoadLinks('goal', goalIds);
    
    return goals.map((g) => RecordContext(
      type: '目标',
      id: g.id,
      title: g.title,
      content: g.note ?? '',
      date: g.recordDate,
      tags: _parseTags(g.tags),
      isFavorite: g.isFavorite,
      links: linksByGoalId[g.id]?.isNotEmpty == true ? linksByGoalId[g.id] : null,
      extra: {
        'parentId': g.parentId,
        'level': g.level,
        'summary': g.summary,
        'category': g.category,
        'progress': g.progress,
        'isCompleted': g.isCompleted,
        'isPostponed': g.isPostponed,
        'remindFrequency': g.remindFrequency,
        'targetYear': g.targetYear,
        'targetQuarter': g.targetQuarter,
        'targetMonth': g.targetMonth,
        'dueDate': g.dueDate,
        'completedAt': g.completedAt,
      },
    )).toList();
  }

  Future<List<RecordContext>> _loadAllEncounterRecords([int? limit]) async {
    var query = _db.select(_db.timelineEvents)
      ..where((t) => t.eventType.equals('encounter'))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    final encounters = await query.get();
    
    if (encounters.isEmpty) return [];
    
    final encounterIds = encounters.map((e) => e.id).toList();
    final linksByEncounterId = await _batchLoadLinks('encounter', encounterIds);
    
    return encounters.map((e) => RecordContext(
      type: '相遇',
      id: e.id,
      title: e.title,
      content: e.note ?? '',
      date: e.recordDate,
      tags: _parseTags(e.tags),
      isFavorite: e.isFavorite,
      links: linksByEncounterId[e.id]?.isNotEmpty == true ? linksByEncounterId[e.id] : null,
      extra: {
        'startAt': e.startAt,
        'endAt': e.endAt,
        'poiName': e.poiName,
        'poiAddress': e.poiAddress,
      },
    )).toList();
  }

  Future<List<RecordContext>> _loadFoodByTimeRange(DateTime start, DateTime end, int? limit) async {
    var query = _db.select(_db.foodRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
      ..where((t) => t.recordDate.isSmallerThanValue(end))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    final foods = await query.get();
    
    if (foods.isEmpty) return [];
    
    final foodIds = foods.map((f) => f.id).toList();
    final linksByFoodId = await _batchLoadLinks('food', foodIds);
    
    return foods.map((f) => RecordContext(
      type: '美食',
      id: f.id,
      title: f.title,
      content: f.content ?? '',
      date: f.recordDate,
      images: _parseImages(f.images),
      tags: _parseTags(f.tags),
      isFavorite: f.isFavorite,
      links: linksByFoodId[f.id]?.isNotEmpty == true ? linksByFoodId[f.id] : null,
      extra: {
        'rating': f.rating,
        'pricePerPerson': f.pricePerPerson,
        'mood': f.mood,
        'poiName': f.poiName,
        'poiAddress': f.poiAddress,
        'city': f.city,
        'country': f.country,
      },
    )).toList();
  }

  Future<List<RecordContext>> _loadMomentByTimeRange(DateTime start, DateTime end, int? limit) async {
    var query = _db.select(_db.momentRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
      ..where((t) => t.recordDate.isSmallerThanValue(end))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    final moments = await query.get();
    
    if (moments.isEmpty) return [];
    
    final momentIds = moments.map((m) => m.id).toList();
    final linksByMomentId = await _batchLoadLinks('moment', momentIds);
    
    return moments.map((m) => RecordContext(
      type: '小确幸',
      id: m.id,
      title: '',
      content: m.content ?? '',
      date: m.recordDate,
      images: _parseImages(m.images),
      tags: _parseTags(m.tags),
      isFavorite: m.isFavorite,
      links: linksByMomentId[m.id]?.isNotEmpty == true ? linksByMomentId[m.id] : null,
      extra: {
        'mood': m.mood,
        'moodColor': m.moodColor,
        'poiName': m.poiName,
        'poiAddress': m.poiAddress,
        'city': m.city,
      },
    )).toList();
  }

  Future<List<RecordContext>> _loadTravelByTimeRange(DateTime start, DateTime end, int? limit) async {
    var query = _db.select(_db.travelRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
      ..where((t) => t.recordDate.isSmallerThanValue(end))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    final travels = await query.get();
    
    if (travels.isEmpty) return [];
    
    final travelIds = travels.map((t) => t.id).toList();
    final linksByTravelId = await _batchLoadLinks('travel', travelIds);
    
    return travels.map((t) => RecordContext(
      type: '旅行',
      id: t.id,
      title: t.title ?? '',
      content: t.content ?? '',
      date: t.recordDate,
      images: _parseImages(t.images),
      tags: _parseTags(t.tags),
      isFavorite: t.isFavorite,
      links: linksByTravelId[t.id]?.isNotEmpty == true ? linksByTravelId[t.id] : null,
      extra: {
        'tripId': t.tripId,
        'destination': t.destination,
        'poiName': t.poiName,
        'city': t.city,
        'country': t.country,
        'mood': t.mood,
      },
    )).toList();
  }

  Future<List<RecordContext>> _loadGoalByTimeRange(DateTime start, DateTime end, int? limit) async {
    var query = _db.select(_db.goalRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
      ..where((t) => t.recordDate.isSmallerThanValue(end))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    final goals = await query.get();
    
    if (goals.isEmpty) return [];
    
    final goalIds = goals.map((g) => g.id).toList();
    final linksByGoalId = await _batchLoadLinks('goal', goalIds);
    
    return goals.map((g) => RecordContext(
      type: '目标',
      id: g.id,
      title: g.title,
      content: g.note ?? '',
      date: g.recordDate,
      tags: _parseTags(g.tags),
      isFavorite: g.isFavorite,
      links: linksByGoalId[g.id]?.isNotEmpty == true ? linksByGoalId[g.id] : null,
      extra: {
        'parentId': g.parentId,
        'level': g.level,
        'summary': g.summary,
        'category': g.category,
        'progress': g.progress,
        'isCompleted': g.isCompleted,
        'dueDate': g.dueDate,
      },
    )).toList();
  }

  Future<List<RecordContext>> _loadEncounterByTimeRange(DateTime start, DateTime end, int? limit) async {
    var query = _db.select(_db.timelineEvents)
      ..where((t) => t.eventType.equals('encounter'))
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
      ..where((t) => t.recordDate.isSmallerThanValue(end))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    final encounters = await query.get();
    
    if (encounters.isEmpty) return [];
    
    final encounterIds = encounters.map((e) => e.id).toList();
    final linksByEncounterId = await _batchLoadLinks('encounter', encounterIds);
    
    return encounters.map((e) => RecordContext(
      type: '相遇',
      id: e.id,
      title: e.title,
      content: e.note ?? '',
      date: e.recordDate,
      tags: _parseTags(e.tags),
      isFavorite: e.isFavorite,
      links: linksByEncounterId[e.id]?.isNotEmpty == true ? linksByEncounterId[e.id] : null,
      extra: {
        'startAt': e.startAt,
        'endAt': e.endAt,
        'poiName': e.poiName,
        'poiAddress': e.poiAddress,
      },
    )).toList();
  }

  Future<List<RecordContext>> _searchFoodRecords(List<String> keywords, int? limit) async {
    if (keywords.isEmpty) return [];
    
    var query = _db.select(_db.foodRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    query.where((t) {
      var expr = t.title.like('%${keywords.first}%');
      for (final kw in keywords.skip(1)) {
        expr = expr | t.title.like('%$kw%') | t.content.like('%$kw%') | t.city.like('%$kw%') | t.tags.like('%$kw%');
      }
      return expr;
    });
    
    final foods = await query.get();
    
    if (foods.isEmpty) return [];
    
    final foodIds = foods.map((f) => f.id).toList();
    final linksByFoodId = await _batchLoadLinks('food', foodIds);
    
    return foods.map((f) => RecordContext(
      type: '美食',
      id: f.id,
      title: f.title,
      content: f.content ?? '',
      date: f.recordDate,
      images: _parseImages(f.images),
      tags: _parseTags(f.tags),
      isFavorite: f.isFavorite,
      links: linksByFoodId[f.id]?.isNotEmpty == true ? linksByFoodId[f.id] : null,
      extra: {
        'rating': f.rating,
        'pricePerPerson': f.pricePerPerson,
        'mood': f.mood,
        'poiName': f.poiName,
        'poiAddress': f.poiAddress,
        'city': f.city,
        'country': f.country,
      },
    )).toList();
  }

  Future<List<RecordContext>> _searchMomentRecords(List<String> keywords, int? limit) async {
    if (keywords.isEmpty) return [];
    
    var query = _db.select(_db.momentRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    query.where((t) {
      var expr = t.content.like('%${keywords.first}%');
      for (final kw in keywords.skip(1)) {
        expr = expr | t.content.like('%$kw%') | t.tags.like('%$kw%');
      }
      return expr;
    });
    
    final moments = await query.get();
    
    if (moments.isEmpty) return [];
    
    final momentIds = moments.map((m) => m.id).toList();
    final linksByMomentId = await _batchLoadLinks('moment', momentIds);
    
    return moments.map((m) => RecordContext(
      type: '小确幸',
      id: m.id,
      title: '',
      content: m.content ?? '',
      date: m.recordDate,
      images: _parseImages(m.images),
      tags: _parseTags(m.tags),
      isFavorite: m.isFavorite,
      links: linksByMomentId[m.id]?.isNotEmpty == true ? linksByMomentId[m.id] : null,
      extra: {
        'mood': m.mood,
        'moodColor': m.moodColor,
        'poiName': m.poiName,
        'poiAddress': m.poiAddress,
        'city': m.city,
      },
    )).toList();
  }

  Future<List<RecordContext>> _searchTravelRecords(List<String> keywords, int? limit) async {
    if (keywords.isEmpty) return [];
    
    var query = _db.select(_db.travelRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    query.where((t) {
      var expr = t.title.like('%${keywords.first}%') | t.destination.like('%${keywords.first}%');
      for (final kw in keywords.skip(1)) {
        expr = expr | t.title.like('%$kw%') | t.destination.like('%$kw%') | t.content.like('%$kw%') | t.tags.like('%$kw%');
      }
      return expr;
    });
    
    final travels = await query.get();
    
    if (travels.isEmpty) return [];
    
    final travelIds = travels.map((t) => t.id).toList();
    final linksByTravelId = await _batchLoadLinks('travel', travelIds);
    
    return travels.map((t) => RecordContext(
      type: '旅行',
      id: t.id,
      title: t.title ?? '',
      content: t.content ?? '',
      date: t.recordDate,
      images: _parseImages(t.images),
      tags: _parseTags(t.tags),
      isFavorite: t.isFavorite,
      links: linksByTravelId[t.id]?.isNotEmpty == true ? linksByTravelId[t.id] : null,
      extra: {
        'tripId': t.tripId,
        'destination': t.destination,
        'poiName': t.poiName,
        'city': t.city,
        'country': t.country,
        'mood': t.mood,
      },
    )).toList();
  }

  Future<List<RecordContext>> _searchGoalRecords(List<String> keywords, int? limit) async {
    if (keywords.isEmpty) return [];
    
    var query = _db.select(_db.goalRecords)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    query.where((t) {
      var expr = t.title.like('%${keywords.first}%');
      for (final kw in keywords.skip(1)) {
        expr = expr | t.title.like('%$kw%') | t.note.like('%$kw%') | t.tags.like('%$kw%');
      }
      return expr;
    });
    
    final goals = await query.get();
    
    if (goals.isEmpty) return [];
    
    final goalIds = goals.map((g) => g.id).toList();
    final linksByGoalId = await _batchLoadLinks('goal', goalIds);
    
    return goals.map((g) => RecordContext(
      type: '目标',
      id: g.id,
      title: g.title,
      content: g.note ?? '',
      date: g.recordDate,
      tags: _parseTags(g.tags),
      isFavorite: g.isFavorite,
      links: linksByGoalId[g.id]?.isNotEmpty == true ? linksByGoalId[g.id] : null,
      extra: {
        'parentId': g.parentId,
        'level': g.level,
        'summary': g.summary,
        'category': g.category,
        'progress': g.progress,
        'isCompleted': g.isCompleted,
        'dueDate': g.dueDate,
      },
    )).toList();
  }

  Future<List<RecordContext>> _searchEncounterRecords(List<String> keywords, int? limit) async {
    if (keywords.isEmpty) return [];
    
    var query = _db.select(_db.timelineEvents)
      ..where((t) => t.eventType.equals('encounter'))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]);
    
    if (limit != null) {
      query = query..limit(limit);
    }
    
    query.where((t) {
      var expr = t.title.like('%${keywords.first}%') | t.note.like('%${keywords.first}%');
      for (final kw in keywords.skip(1)) {
        expr = expr | t.title.like('%$kw%') | t.note.like('%$kw%') | t.tags.like('%$kw%');
      }
      return expr;
    });
    
    final encounters = await query.get();
    
    if (encounters.isEmpty) return [];
    
    final encounterIds = encounters.map((e) => e.id).toList();
    final linksByEncounterId = await _batchLoadLinks('encounter', encounterIds);
    
    return encounters.map((e) => RecordContext(
      type: '相遇',
      id: e.id,
      title: e.title,
      content: e.note ?? '',
      date: e.recordDate,
      tags: _parseTags(e.tags),
      isFavorite: e.isFavorite,
      links: linksByEncounterId[e.id]?.isNotEmpty == true ? linksByEncounterId[e.id] : null,
      extra: {
        'startAt': e.startAt,
        'endAt': e.endAt,
        'poiName': e.poiName,
        'poiAddress': e.poiAddress,
      },
    )).toList();
  }

  Future<RecordContext?> fetchRecordById(String type, String id) async {
    switch (type) {
      case 'food':
      case '美食':
        final food = await _db.foodDao.findById(id);
        if (food == null) return null;
        final links = await _loadLinks('food', food.id);
        return RecordContext(
          type: '美食',
          id: food.id,
          title: food.title,
          content: food.content ?? '',
          date: food.recordDate,
          images: _parseImages(food.images),
          tags: _parseTags(food.tags),
          isFavorite: food.isFavorite,
          links: links.isNotEmpty ? links : null,
          extra: {
            'rating': food.rating,
            'pricePerPerson': food.pricePerPerson,
            'mood': food.mood,
            'poiName': food.poiName,
            'poiAddress': food.poiAddress,
            'city': food.city,
            'country': food.country,
          },
        );
        
      case 'moment':
      case '小确幸':
        final moment = await _db.momentDao.findById(id);
        if (moment == null) return null;
        final links = await _loadLinks('moment', moment.id);
        return RecordContext(
          type: '小确幸',
          id: moment.id,
          title: '',
          content: moment.content ?? '',
          date: moment.recordDate,
          images: _parseImages(moment.images),
          tags: _parseTags(moment.tags),
          isFavorite: moment.isFavorite,
          links: links.isNotEmpty ? links : null,
          extra: {
            'mood': moment.mood,
            'moodColor': moment.moodColor,
            'poiName': moment.poiName,
            'poiAddress': moment.poiAddress,
            'city': moment.city,
          },
        );
        
      case 'travel':
      case '旅行':
        final travel = await _db.watchTravelById(id).first;
        if (travel == null) return null;
        final links = await _loadLinks('travel', travel.id);
        return RecordContext(
          type: '旅行',
          id: travel.id,
          title: travel.title ?? '',
          content: travel.content ?? '',
          date: travel.recordDate,
          images: _parseImages(travel.images),
          tags: _parseTags(travel.tags),
          isFavorite: travel.isFavorite,
          links: links.isNotEmpty ? links : null,
          extra: {
            'tripId': travel.tripId,
            'destination': travel.destination,
            'poiName': travel.poiName,
            'city': travel.city,
            'country': travel.country,
            'mood': travel.mood,
          },
        );
        
      case 'goal':
      case '目标':
        final goals = await _db.watchAllActiveGoalRecords().first;
        final goal = goals.where((g) => g.id == id).firstOrNull;
        if (goal == null) return null;
        final links = await _loadLinks('goal', goal.id);
        return RecordContext(
          type: '目标',
          id: goal.id,
          title: goal.title,
          content: goal.note ?? '',
          date: goal.recordDate,
          tags: _parseTags(goal.tags),
          isFavorite: goal.isFavorite,
          links: links.isNotEmpty ? links : null,
          extra: {
            'parentId': goal.parentId,
            'level': goal.level,
            'summary': goal.summary,
            'category': goal.category,
            'progress': goal.progress,
            'isCompleted': goal.isCompleted,
            'dueDate': goal.dueDate,
          },
        );
        
      case 'encounter':
      case '相遇':
        final events = await (_db.select(_db.timelineEvents)
              ..where((t) => t.eventType.equals('encounter'))
              ..where((t) => t.isDeleted.equals(false)))
            .get();
        final encounter = events.where((e) => e.id == id).firstOrNull;
        if (encounter == null) return null;
        final links = await _loadLinks('encounter', encounter.id);
        return RecordContext(
          type: '相遇',
          id: encounter.id,
          title: encounter.title,
          content: encounter.note ?? '',
          date: encounter.recordDate,
          tags: _parseTags(encounter.tags),
          isFavorite: encounter.isFavorite,
          links: links.isNotEmpty ? links : null,
          extra: {
            'startAt': encounter.startAt,
            'endAt': encounter.endAt,
            'poiName': encounter.poiName,
            'poiAddress': encounter.poiAddress,
          },
        );
        
      default:
        return null;
    }
  }
}
