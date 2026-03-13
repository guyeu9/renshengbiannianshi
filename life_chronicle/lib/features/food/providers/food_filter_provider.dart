import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:rxdart/rxdart.dart';

class FoodFilterParams {
  const FoodFilterParams({
    required this.filterDateIndex,
    required this.filterCustomRange,
    required this.filterRatings,
    required this.filterCities,
    required this.filterFriendIds,
    required this.filterSolo,
    required this.filterFavorite,
  });

  final int filterDateIndex;
  final DateTimeRange? filterCustomRange;
  final Set<int> filterRatings;
  final Set<String> filterCities;
  final Set<String> filterFriendIds;
  final bool filterSolo;
  final bool filterFavorite;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodFilterParams &&
          filterDateIndex == other.filterDateIndex &&
          _dateTimeRangeEquals(filterCustomRange, other.filterCustomRange) &&
          _setEquals(filterRatings, other.filterRatings) &&
          _setEquals(filterCities, other.filterCities) &&
          _setEquals(filterFriendIds, other.filterFriendIds) &&
          filterSolo == other.filterSolo &&
          filterFavorite == other.filterFavorite;

  @override
  int get hashCode => Object.hash(
    filterDateIndex,
    filterCustomRange != null 
        ? Object.hash(filterCustomRange!.start, filterCustomRange!.end) 
        : null,
    Object.hashAll(filterRatings),
    Object.hashAll(filterCities),
    Object.hashAll(filterFriendIds),
    filterSolo,
    filterFavorite,
  );

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  static bool _dateTimeRangeEquals(DateTimeRange? a, DateTimeRange? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.start == b.start && a.end == b.end;
  }
}

class FoodFilterState {
  const FoodFilterState({
    required this.records,
    required this.friendLinks,
  });

  final List<FoodRecord> records;
  final List<EntityLink> friendLinks;

  List<FoodRecord> get filteredRecords {
    final byFriend = _filterByFriend(records, friendLinks);
    return byFriend;
  }

  List<FoodRecord> _filterByFriend(List<FoodRecord> records, List<EntityLink> links) {
    final foodIdsWithFriends = <String>{};
    for (final link in links) {
      if (link.sourceType == 'food' && link.targetType == 'friend') {
        foodIdsWithFriends.add(link.sourceId);
      } else if (link.targetType == 'food' && link.sourceType == 'friend') {
        foodIdsWithFriends.add(link.targetId);
      }
    }

    return records.where((r) {
      final hasFriend = foodIdsWithFriends.contains(r.id);
      return hasFriend;
    }).toList(growable: false);
  }
}

final foodFilterProvider = StreamProvider.family.autoDispose<FoodFilterState, FoodFilterParams>((ref, params) {
  final db = ref.watch(appDatabaseProvider);

  final range = _resolveDateRange(params.filterDateIndex, params.filterCustomRange);
  final recordsStream = range == null
      ? db.foodDao.watchAllActive()
      : db.foodDao.watchByRecordDateRange(range.$1, range.$2);

  final friendLinksStream = (db.select(db.entityLinks)
        ..where((t) => t.sourceType.equals('food'))
        ..where((t) => t.targetType.equals('friend')))
      .watch();

  return Rx.combineLatest2(
    recordsStream,
    friendLinksStream,
    (records, links) => FoodFilterState(
      records: _applyFilters(records, links, params),
      friendLinks: links,
    ),
  );
});

(DateTime, DateTime)? _resolveDateRange(int index, DateTimeRange? customRange) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (index) {
    case 1:
      return (today, today.add(const Duration(days: 1)));
    case 2:
      return (today.subtract(const Duration(days: 6)), today.add(const Duration(days: 1)));
    case 3:
      return (today.subtract(const Duration(days: 29)), today.add(const Duration(days: 1)));
    case 4:
      if (customRange == null) return null;
      final start = DateTime(customRange.start.year, customRange.start.month, customRange.start.day);
      final end = DateTime(customRange.end.year, customRange.end.month, customRange.end.day).add(const Duration(days: 1));
      return (start, end);
    default:
      return null;
  }
}

List<FoodRecord> _applyFilters(List<FoodRecord> records, List<EntityLink> links, FoodFilterParams params) {
  var result = records.where((e) => e.isWishlist == false).toList(growable: false);

  if (params.filterRatings.isNotEmpty) {
    result = result.where((r) {
      final v = r.rating;
      if (v == null) return false;
      return params.filterRatings.contains(v.round().clamp(1, 5));
    }).toList(growable: false);
  }

  if (params.filterCities.isNotEmpty) {
    result = result.where((r) {
      final city = _resolveFoodCity(r);
      return city.isNotEmpty && params.filterCities.contains(city);
    }).toList(growable: false);
  }

  if (params.filterFavorite) {
    result = result.where((r) => r.isFavorite).toList(growable: false);
  }

  if (params.filterFriendIds.isNotEmpty || params.filterSolo) {
    result = _filterByFriendFilter(result, links, params);
  }

  return result;
}

List<FoodRecord> _filterByFriendFilter(List<FoodRecord> records, List<EntityLink> links, FoodFilterParams params) {
  final foodIdsWithSelectedFriends = <String>{};
  final foodIdsWithAnyFriend = <String>{};

  for (final link in links) {
    final isFoodSource = link.sourceType == 'food';
    final isFoodTarget = link.targetType == 'food';
    final isFriendSource = link.sourceType == 'friend';
    final isFriendTarget = link.targetType == 'friend';

    if (isFoodSource && isFriendTarget) {
      foodIdsWithAnyFriend.add(link.sourceId);
      if (params.filterFriendIds.contains(link.targetId)) {
        foodIdsWithSelectedFriends.add(link.sourceId);
      }
    } else if (isFriendSource && isFoodTarget) {
      foodIdsWithAnyFriend.add(link.targetId);
      if (params.filterFriendIds.contains(link.sourceId)) {
        foodIdsWithSelectedFriends.add(link.targetId);
      }
    }
  }

  return records.where((r) {
    final hasAnyFriend = foodIdsWithAnyFriend.contains(r.id);
    final hasSelectedFriend = foodIdsWithSelectedFriends.contains(r.id);

    if (params.filterSolo) {
      if (hasAnyFriend) {
        return params.filterFriendIds.isEmpty || hasSelectedFriend;
      }
      return true;
    }

    return hasSelectedFriend;
  }).toList(growable: false);
}

String _resolveFoodCity(FoodRecord r) {
  final city = (r.city ?? '').trim();
  if (city.isNotEmpty) return city;
  final address = (r.poiAddress ?? '').trim();
  if (address.isEmpty) return '';
  return _extractCityToken(address);
}

String _extractCityToken(String address) {
  final patterns = [
    RegExp(r'([^省]+省)?([^市]+市)'),
    RegExp(r'([^自治区]+自治区)?([^市]+市)'),
    RegExp(r'([^盟]+盟)?([^市]+市)'),
    RegExp(r'([^地区]+地区)?([^市]+市)'),
  ];
  for (final p in patterns) {
    final m = p.firstMatch(address);
    if (m != null) {
      final city = m.group(2);
      if (city != null && city.isNotEmpty) return city;
    }
  }
  return '';
}
