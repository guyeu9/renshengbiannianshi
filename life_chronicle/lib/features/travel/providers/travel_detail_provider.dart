import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:rxdart/rxdart.dart';

class TravelDetailState {
  const TravelDetailState({
    required this.record,
    required this.trip,
    required this.journals,
    required this.checklistItems,
    required this.linkedFriends,
    required this.linkedFoods,
    required this.allTravelIds,
  });

  final TravelRecord? record;
  final Trip? trip;
  final List<TravelRecord> journals;
  final List<ChecklistItem> checklistItems;
  final List<FriendRecord> linkedFriends;
  final List<FoodRecord> linkedFoods;
  final Set<String> allTravelIds;

  String get title => record?.title ?? trip?.name ?? '';
  
  String get place {
    if (record == null) return '';
    final destination = record!.destination?.trim();
    if (destination != null && destination.isNotEmpty) return destination;
    final poiName = record!.poiName?.trim();
    if (poiName != null && poiName.isNotEmpty) return poiName;
    final poiAddress = record!.poiAddress?.trim();
    if (poiAddress != null && poiAddress.isNotEmpty) return poiAddress;
    return '';
  }

  DateTime get headerStart => trip?.startDate ?? record?.planDate ?? record?.recordDate ?? DateTime.now();
  DateTime get headerEnd => trip?.endDate ?? record?.planDate ?? headerStart;
  int get durationDays => _durationDays(headerStart, headerEnd);
  String get durationLabel => _formatDurationLabel(durationDays);
  String get dateLabel => _formatDateDotRange(headerStart, headerEnd);
  String get cover => _pickCoverImage(record);
  String get tripId => trip?.id ?? record?.tripId ?? '';
  String get tripTitle => trip?.name ?? title;
  String get recordId => record?.id ?? '';

  List<String> get tags {
    final tagSet = <String>{};
    if (record != null) {
      tagSet.addAll(_decodeStringList(record!.tags));
      final destination = record!.destination?.trim();
      if (destination != null && destination.isNotEmpty) {
        tagSet.add(destination);
      }
    }
    return tagSet.toList()..sort();
  }

  bool get isJournal => record?.isJournal == true;
  bool get isWishlist => record?.isWishlist == true;
  bool get wishlistDone => record?.wishlistDone ?? false;

  static int _durationDays(DateTime start, DateTime end) {
    final diff = end.difference(start).inDays;
    return diff < 1 ? 1 : diff + 1;
  }

  static String _formatDurationLabel(int days) {
    if (days <= 1) return '1 天';
    return '$days 天';
  }

  static String _formatDateDotRange(DateTime start, DateTime end) {
    final startStr = '${start.month}.${start.day}';
    if (start.year != end.year || start.month != end.month || start.day != end.day) {
      return '$startStr - ${end.month}.${end.day}';
    }
    return startStr;
  }

  static String _pickCoverImage(TravelRecord? record) {
    if (record == null) return '';
    final images = _decodeStringList(record.images);
    if (images.isNotEmpty) return images.first;
    return '';
  }

  static List<String> _decodeStringList(String? json) {
    if (json == null || json.trim().isEmpty) return const [];
    final trimmed = json.trim();
    
    // 尝试JSON解析
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList(growable: false);
      }
    } catch (_) {}
    
    // 兼容历史数据：逗号分隔格式
    if (trimmed.contains(',') && !trimmed.startsWith('[')) {
      return trimmed.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(growable: false);
    }
    
    // 单个路径
    if (trimmed.isNotEmpty) {
      return [trimmed];
    }
    
    return const [];
  }
}

final travelDetailProvider = StreamProvider.family.autoDispose<TravelDetailState, ({String travelId, String tripId})>((ref, params) {
  final db = ref.watch(appDatabaseProvider);

  final recordStream = db.travelDao.watchById(params.travelId);

  final tripStream = db.travelDao.watchTripById(params.tripId);

  final allRecordsStream = (db.select(db.travelRecords)
        ..where((t) => t.isDeleted.equals(false))
        ..where((t) => t.tripId.equals(params.tripId)))
      .watch();

  final checklistStream = db.checklistDao.watchByTripId(params.tripId);

  final linksStream = db.select(db.entityLinks).watch();

  final friendsStream = db.friendDao.watchAllActive();

  final foodsStream = db.foodDao.watchAllActive();

  return _combineStreams(
    recordStream: recordStream,
    tripStream: tripStream,
    allRecordsStream: allRecordsStream,
    checklistStream: checklistStream,
    linksStream: linksStream,
    friendsStream: friendsStream,
    foodsStream: foodsStream,
    travelId: params.travelId,
    tripId: params.tripId,
  );
});

Stream<TravelDetailState> _combineStreams({
  required Stream<TravelRecord?> recordStream,
  required Stream<Trip?> tripStream,
  required Stream<List<TravelRecord>> allRecordsStream,
  required Stream<List<ChecklistItem>> checklistStream,
  required Stream<List<EntityLink>> linksStream,
  required Stream<List<FriendRecord>> friendsStream,
  required Stream<List<FoodRecord>> foodsStream,
  required String travelId,
  required String tripId,
}) {
  return Rx.combineLatest7(
    recordStream,
    tripStream,
    allRecordsStream,
    checklistStream,
    linksStream,
    friendsStream,
    foodsStream,
    (record, trip, allRecords, checklistItems, links, friends, foods) {
      final isCurrentJournal = record?.isJournal == true;
      final recordId = record?.id ?? travelId;
      final journals = allRecords.where((r) {
        if (r.isWishlist || !r.isJournal) return false;
        if (isCurrentJournal) return true;
        return r.id != recordId;
      }).toList(growable: false);

      final allTravelIds = <String>{recordId};
      for (final r in allRecords) {
        if (r.tripId == tripId) {
          allTravelIds.add(r.id);
        }
      }

      final linkedFriendIds = <String>{};
      final linkedFoodIds = <String>{};
      for (final link in links) {
        if (link.sourceType == 'travel' && allTravelIds.contains(link.sourceId)) {
          if (link.targetType == 'friend') {
            linkedFriendIds.add(link.targetId);
          } else if (link.targetType == 'food') {
            linkedFoodIds.add(link.targetId);
          }
        } else if (link.targetType == 'travel' && allTravelIds.contains(link.targetId)) {
          if (link.sourceType == 'friend') {
            linkedFriendIds.add(link.sourceId);
          } else if (link.sourceType == 'food') {
            linkedFoodIds.add(link.sourceId);
          }
        }
      }

      final linkedFriends = friends.where((f) => linkedFriendIds.contains(f.id)).toList(growable: false);
      final linkedFoods = foods.where((f) => linkedFoodIds.contains(f.id)).toList(growable: false);

      return TravelDetailState(
        record: record,
        trip: trip,
        journals: journals,
        checklistItems: checklistItems,
        linkedFriends: linkedFriends,
        linkedFoods: linkedFoods,
        allTravelIds: allTravelIds,
      );
    },
  );
}

class JournalDetailState {
  const JournalDetailState({
    required this.record,
    required this.trip,
    required this.linkedFriends,
    required this.linkedFoods,
    required this.linkedGoals,
    required this.linkedTravels,
  });

  final TravelRecord record;
  final Trip? trip;
  final List<FriendRecord> linkedFriends;
  final List<FoodRecord> linkedFoods;
  final List<GoalRecord> linkedGoals;
  final List<TravelRecord> linkedTravels;

  String get title => record.title ?? '游记';

  String get place {
    final poiName = record.poiName?.trim();
    if (poiName != null && poiName.isNotEmpty) return poiName;
    final poiAddress = record.poiAddress?.trim();
    if (poiAddress != null && poiAddress.isNotEmpty) return poiAddress;
    return '';
  }

  List<String> get images => _decodeStringList(record.images);
  List<String> get tags => _decodeStringList(record.tags);

  static List<String> _decodeStringList(String? json) {
    if (json == null || json.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }
}

final journalDetailProvider = StreamProvider.family.autoDispose<JournalDetailState?, String>((ref, recordId) {
  final db = ref.watch(appDatabaseProvider);

  final recordStream = (db.select(db.travelRecords)
        ..where((t) => t.id.equals(recordId))
        ..where((t) => t.isDeleted.equals(false))
        ..where((t) => t.isJournal.equals(true))
        ..limit(1))
      .watchSingleOrNull();

  final linksStream = db.select(db.entityLinks).watch();
  final friendsStream = db.friendDao.watchAllActive();
  final foodsStream = db.foodDao.watchAllActive();
  final goalsStream = db.goalDao.watchAllActive();
  final allTravelsStream = db.travelDao.watchAllActive();

  return _combineJournalStreams(
    recordStream: recordStream,
    linksStream: linksStream,
    friendsStream: friendsStream,
    foodsStream: foodsStream,
    goalsStream: goalsStream,
    allTravelsStream: allTravelsStream,
    recordId: recordId,
    db: db,
  );
});

Stream<JournalDetailState?> _combineJournalStreams({
  required Stream<TravelRecord?> recordStream,
  required Stream<List<EntityLink>> linksStream,
  required Stream<List<FriendRecord>> friendsStream,
  required Stream<List<FoodRecord>> foodsStream,
  required Stream<List<GoalRecord>> goalsStream,
  required Stream<List<TravelRecord>> allTravelsStream,
  required String recordId,
  required AppDatabase db,
}) {
  return Rx.combineLatest6(
    recordStream,
    linksStream,
    friendsStream,
    foodsStream,
    goalsStream,
    allTravelsStream,
    (record, links, friends, foods, goals, allTravels) async {
      if (record == null) return null;

      Trip? trip;
      if (record.tripId.isNotEmpty) {
        trip = await db.travelDao.findTripById(record.tripId);
      }

      final linkedFriendIds = <String>{};
      final linkedFoodIds = <String>{};
      final linkedGoalIds = <String>{};
      final linkedTravelIds = <String>{};

      for (final link in links) {
        if (link.sourceType == 'travel' && link.sourceId == recordId) {
          if (link.targetType == 'friend') linkedFriendIds.add(link.targetId);
          if (link.targetType == 'food') linkedFoodIds.add(link.targetId);
          if (link.targetType == 'goal') linkedGoalIds.add(link.targetId);
          if (link.targetType == 'travel') linkedTravelIds.add(link.targetId);
        } else if (link.targetType == 'travel' && link.targetId == recordId) {
          if (link.sourceType == 'friend') linkedFriendIds.add(link.sourceId);
          if (link.sourceType == 'food') linkedFoodIds.add(link.sourceId);
          if (link.sourceType == 'goal') linkedGoalIds.add(link.sourceId);
          if (link.sourceType == 'travel') linkedTravelIds.add(link.sourceId);
        }
      }

      final linkedFriends = friends.where((f) => linkedFriendIds.contains(f.id)).toList(growable: false);
      final linkedFoods = foods.where((f) => linkedFoodIds.contains(f.id)).toList(growable: false);
      final linkedGoals = goals.where((g) => linkedGoalIds.contains(g.id)).toList(growable: false);
      final linkedTravels = allTravels.where((t) => linkedTravelIds.contains(t.id) && t.id != recordId).toList(growable: false);

      return JournalDetailState(
        record: record,
        trip: trip,
        linkedFriends: linkedFriends,
        linkedFoods: linkedFoods,
        linkedGoals: linkedGoals,
        linkedTravels: linkedTravels,
      );
    },
  ).switchMap((future) => Stream.fromFuture(future));
}

class TravelTimelineState {
  const TravelTimelineState({
    required this.records,
    required this.trips,
    required this.links,
    required this.friends,
    required this.foods,
  });

  final List<TravelRecord> records;
  final List<Trip> trips;
  final List<EntityLink> links;
  final List<FriendRecord> friends;
  final List<FoodRecord> foods;

  static List<String> _decodeStringList(String? json) {
    if (json == null || json.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }
}

final travelTimelineProvider = StreamProvider.family.autoDispose<TravelTimelineState, ({String searchQuery, Set<String> filterFriendIds})>((ref, params) {
  final db = ref.watch(appDatabaseProvider);

  final recordsStream = db.travelDao.watchAllActive();
  final linksStream = db.select(db.entityLinks).watch();
  final friendsStream = db.friendDao.watchAllActive();
  final foodsStream = db.foodDao.watchAllActive();

  return _combineTimelineStreams(
    recordsStream: recordsStream,
    linksStream: linksStream,
    friendsStream: friendsStream,
    foodsStream: foodsStream,
    db: db,
    searchQuery: params.searchQuery,
    filterFriendIds: params.filterFriendIds,
  );
});

Stream<TravelTimelineState> _combineTimelineStreams({
  required Stream<List<TravelRecord>> recordsStream,
  required Stream<List<EntityLink>> linksStream,
  required Stream<List<FriendRecord>> friendsStream,
  required Stream<List<FoodRecord>> foodsStream,
  required AppDatabase db,
  required String searchQuery,
  required Set<String> filterFriendIds,
}) {
  return Rx.combineLatest4(
    recordsStream,
    linksStream,
    friendsStream,
    foodsStream,
    (allRecords, links, friends, foods) async {
      var filtered = allRecords.where((r) => !r.isWishlist && !r.isJournal).toList(growable: false);

      final searchLower = searchQuery.toLowerCase().trim();
      if (searchLower.isNotEmpty) {
        filtered = filtered.where((r) {
          final title = (r.title ?? '').toLowerCase();
          final destination = (r.destination ?? '').toLowerCase();
          final tags = TravelTimelineState._decodeStringList(r.tags).join(' ').toLowerCase();
          return title.contains(searchLower) ||
              destination.contains(searchLower) ||
              tags.contains(searchLower);
        }).toList(growable: false);
      }

      if (filterFriendIds.isNotEmpty) {
        final friendIdsByTravel = <String, Set<String>>{};
        for (final link in links) {
          String? travelId;
          if (link.sourceType == 'travel' && link.targetType == 'friend') {
            travelId = link.sourceId;
            final set = friendIdsByTravel.putIfAbsent(travelId, () => <String>{});
            set.add(link.targetId);
          } else if (link.targetType == 'travel' && link.sourceType == 'friend') {
            travelId = link.targetId;
            final set = friendIdsByTravel.putIfAbsent(travelId, () => <String>{});
            set.add(link.sourceId);
          }
        }
        filtered = filtered.where((r) {
          final linkedFriendIds = friendIdsByTravel[r.id] ?? <String>{};
          return filterFriendIds.any((id) => linkedFriendIds.contains(id));
        }).toList(growable: false);
      }

      final tripIds = filtered.map((e) => e.tripId).toSet().toList();
      final trips = await _fetchTripsByIds(db, tripIds);

      return TravelTimelineState(
        records: filtered,
        trips: trips,
        links: links,
        friends: friends,
        foods: foods,
      );
    },
  ).switchMap((future) => Stream.fromFuture(future));
}

Future<List<Trip>> _fetchTripsByIds(AppDatabase db, List<String> tripIds) async {
  if (tripIds.isEmpty) return const [];
  return (db.select(db.trips)..where((t) => t.id.isIn(tripIds))).get();
}
