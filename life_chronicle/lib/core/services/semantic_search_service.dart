import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/vector_index_service.dart';

class SemanticSearchResult {
  final String entityType;
  final String entityId;
  final double similarity;
  final Map<String, dynamic>? record;

  const SemanticSearchResult({
    required this.entityType,
    required this.entityId,
    required this.similarity,
    this.record,
  });
}

class SearchFilters {
  final List<String>? entityTypes;
  final DateTime? startDate;
  final DateTime? endDate;
  final double minSimilarity;

  const SearchFilters({
    this.entityTypes,
    this.startDate,
    this.endDate,
    this.minSimilarity = 0.5,
  });
}

class SemanticSearchService {
  final AppDatabase _db;
  final VectorIndexService _vectorIndexService;

  SemanticSearchService(this._db, this._vectorIndexService);

  Future<List<SemanticSearchResult>> search({
    required String query,
    int limit = 10,
    SearchFilters? filters,
  }) async {
    final matches = await _vectorIndexService.searchByText(
      query: query,
      limit: limit * 2,
      entityTypes: filters?.entityTypes,
      minSimilarity: filters?.minSimilarity ?? 0.5,
    );

    if (matches.isEmpty) return [];

    final results = <SemanticSearchResult>[];
    for (final match in matches) {
      final record = await _fetchRecord(match.entityType, match.entityId);
      if (record == null) continue;

      if (filters?.startDate != null || filters?.endDate != null) {
        final recordDate = _getRecordDate(match.entityType, record);
        if (recordDate != null) {
          if (filters!.startDate != null && recordDate.isBefore(filters.startDate!)) {
            continue;
          }
          if (filters.endDate != null && recordDate.isAfter(filters.endDate!)) {
            continue;
          }
        }
      }

      results.add(SemanticSearchResult(
        entityType: match.entityType,
        entityId: match.entityId,
        similarity: match.similarity,
        record: record,
      ));

      if (results.length >= limit) break;
    }

    return results;
  }

  Future<List<SemanticSearchResult>> hybridSearch({
    required String query,
    int limit = 10,
    SearchFilters? filters,
    double semanticWeight = 0.7,
    double keywordWeight = 0.3,
  }) async {
    final semanticResults = await search(
      query: query,
      limit: limit * 2,
      filters: filters,
    );

    final keywordResults = await _keywordSearch(
      query: query,
      limit: limit * 2,
      filters: filters,
    );

    final combinedScores = <String, double>{};
    final recordMap = <String, SemanticSearchResult>{};

    for (final result in semanticResults) {
      final key = '${result.entityType}:${result.entityId}';
      combinedScores[key] = result.similarity * semanticWeight;
      recordMap[key] = result;
    }

    for (final result in keywordResults) {
      final key = '${result.entityType}:${result.entityId}';
      final existing = combinedScores[key] ?? 0;
      combinedScores[key] = existing + result.similarity * keywordWeight;
      recordMap.putIfAbsent(key, () => result);
    }

    final sortedKeys = combinedScores.keys.toList()
      ..sort((a, b) => combinedScores[b]!.compareTo(combinedScores[a]!));

    return sortedKeys.take(limit).map((key) => recordMap[key]!).toList();
  }

  Future<List<SemanticSearchResult>> _keywordSearch({
    required String query,
    required int limit,
    SearchFilters? filters,
  }) async {
    final results = <SemanticSearchResult>[];

    if (filters?.entityTypes == null || filters!.entityTypes!.contains('food')) {
      final foodResults = await _db.foodDao.searchFood(query);
      for (final food in foodResults.take(limit)) {
        results.add(SemanticSearchResult(
          entityType: 'food',
          entityId: food.id,
          similarity: 0.8,
          record: {'title': food.title, 'content': food.content, 'recordDate': food.recordDate.toIso8601String()},
        ));
      }
    }

    if (filters?.entityTypes == null || filters!.entityTypes!.contains('moment')) {
      final momentResults = await _db.momentDao.searchMoments(query);
      for (final moment in momentResults.take(limit)) {
        results.add(SemanticSearchResult(
          entityType: 'moment',
          entityId: moment.id,
          similarity: 0.8,
          record: {'content': moment.content, 'recordDate': moment.recordDate.toIso8601String()},
        ));
      }
    }

    return results.take(limit).toList();
  }

  Future<Map<String, dynamic>?> _fetchRecord(String entityType, String entityId) async {
    switch (entityType) {
      case 'food':
        final record = await _db.foodDao.findById(entityId);
        if (record == null) return null;
        return {
          'title': record.title,
          'content': record.content,
          'rating': record.rating,
          'city': record.city,
          'recordDate': record.recordDate.toIso8601String(),
        };
      case 'moment':
        final record = await _db.momentDao.findById(entityId);
        if (record == null) return null;
        return {
          'content': record.content,
          'mood': record.mood,
          'city': record.city,
          'recordDate': record.recordDate.toIso8601String(),
        };
      case 'travel':
        final record = await _db.watchTravelById(entityId).first;
        if (record == null) return null;
        return {
          'title': record.title,
          'content': record.content,
          'destination': record.destination,
          'recordDate': record.recordDate.toIso8601String(),
        };
      case 'goal':
        final records = await _db.watchAllActiveGoalRecords().first;
        final record = records.where((r) => r.id == entityId).firstOrNull;
        if (record == null) return null;
        return {
          'title': record.title,
          'note': record.note,
          'level': record.level,
          'recordDate': record.recordDate.toIso8601String(),
        };
      default:
        return null;
    }
  }

  DateTime? _getRecordDate(String entityType, Map<String, dynamic> record) {
    final dateStr = record['recordDate'] as String?;
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }
}
