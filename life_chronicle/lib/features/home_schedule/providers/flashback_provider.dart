import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';

class FlashbackItem {
  final int yearsAgo;
  final String title;
  final String? imageUrl;
  final String type;
  final String recordId;
  final bool isFavorite;
  final DateTime date;
  final String? content;
  final bool isJournal;

  const FlashbackItem({
    required this.yearsAgo,
    required this.title,
    this.imageUrl,
    required this.type,
    required this.recordId,
    required this.isFavorite,
    required this.date,
    this.content,
    this.isJournal = false,
  });

  String get yearLabel => '${date.year}年';
  String get typeLabel {
    const typeNames = {
      'food': '美食',
      'moment': '小确幸',
      'travel': '旅行',
      'goal': '目标',
      'encounter': '相遇',
    };
    return typeNames[type] ?? type;
  }
}

final flashbackItemsProvider = FutureProvider<List<FlashbackItem>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final items = <FlashbackItem>[];

  final now = DateTime.now();

  for (int i = 1; i <= 5; i++) {
    final targetDate = DateTime(now.year - i, now.month, now.day);
    final nextDay = targetDate.add(const Duration(days: 1));

    final foods = await _loadFoodByTimeRange(db, targetDate, nextDay);
    items.addAll(foods);

    final moments = await _loadMomentByTimeRange(db, targetDate, nextDay);
    items.addAll(moments);

    final travels = await _loadTravelByTimeRange(db, targetDate, nextDay);
    items.addAll(travels);

    final goals = await _loadGoalByTimeRange(db, targetDate, nextDay);
    items.addAll(goals);

    final encounters = await _loadEncounterByTimeRange(db, targetDate, nextDay);
    items.addAll(encounters);
  }

  items.sort((a, b) {
    if (a.isFavorite != b.isFavorite) {
      return a.isFavorite ? -1 : 1;
    }
    return b.date.compareTo(a.date);
  });

  return items;
});

Future<List<FlashbackItem>> _loadFoodByTimeRange(AppDatabase db, DateTime start, DateTime end) async {
  final records = await (db.select(db.foodRecords)
        ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
        ..where((t) => t.recordDate.isSmallerThanValue(end))
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
        ..limit(5))
      .get();

  final now = DateTime.now();
  return records.map((r) {
    String? imageUrl;
    if (r.images != null && r.images!.isNotEmpty) {
      try {
        final decoded = jsonDecode(r.images!);
        if (decoded is List && decoded.isNotEmpty) {
          imageUrl = decoded.first.toString();
        } else if (decoded is String && decoded.isNotEmpty) {
          imageUrl = decoded;
        }
      } catch (_) {
        final parts = r.images!.split(',');
        if (parts.isNotEmpty) {
          imageUrl = parts.first.trim();
        }
      }
    }

    return FlashbackItem(
      yearsAgo: now.year - r.recordDate.year,
      title: r.title,
      imageUrl: imageUrl,
      type: 'food',
      recordId: r.id,
      isFavorite: r.isFavorite,
      date: r.recordDate,
      content: r.content,
    );
  }).toList();
}

Future<List<FlashbackItem>> _loadMomentByTimeRange(AppDatabase db, DateTime start, DateTime end) async {
  final records = await (db.select(db.momentRecords)
        ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
        ..where((t) => t.recordDate.isSmallerThanValue(end))
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
        ..limit(5))
      .get();

  final now = DateTime.now();
  return records.map((r) {
    String? imageUrl;
    if (r.images != null && r.images!.isNotEmpty) {
      try {
        final decoded = jsonDecode(r.images!);
        if (decoded is List && decoded.isNotEmpty) {
          imageUrl = decoded.first.toString();
        } else if (decoded is String && decoded.isNotEmpty) {
          imageUrl = decoded;
        }
      } catch (_) {
        final parts = r.images!.split(',');
        if (parts.isNotEmpty) {
          imageUrl = parts.first.trim();
        }
      }
    }

    return FlashbackItem(
      yearsAgo: now.year - r.recordDate.year,
      title: r.content ?? '小确幸',
      imageUrl: imageUrl,
      type: 'moment',
      recordId: r.id,
      isFavorite: r.isFavorite,
      date: r.recordDate,
      content: r.content,
    );
  }).toList();
}

Future<List<FlashbackItem>> _loadTravelByTimeRange(AppDatabase db, DateTime start, DateTime end) async {
  final records = await (db.select(db.travelRecords)
        ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
        ..where((t) => t.recordDate.isSmallerThanValue(end))
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
        ..limit(5))
      .get();

  final now = DateTime.now();
  return records.map((r) {
    String? imageUrl;
    if (r.images != null && r.images!.isNotEmpty) {
      try {
        final decoded = jsonDecode(r.images!);
        if (decoded is List && decoded.isNotEmpty) {
          imageUrl = decoded.first.toString();
        } else if (decoded is String && decoded.isNotEmpty) {
          imageUrl = decoded;
        }
      } catch (_) {
        final parts = r.images!.split(',');
        if (parts.isNotEmpty) {
          imageUrl = parts.first.trim();
        }
      }
    }

    return FlashbackItem(
      yearsAgo: now.year - r.recordDate.year,
      title: r.title ?? r.destination ?? '旅行',
      imageUrl: imageUrl,
      type: 'travel',
      recordId: r.id,
      isFavorite: r.isFavorite,
      date: r.recordDate,
      content: r.content,
      isJournal: r.isJournal,
    );
  }).toList();
}

Future<List<FlashbackItem>> _loadGoalByTimeRange(AppDatabase db, DateTime start, DateTime end) async {
  final records = await (db.select(db.goalRecords)
        ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
        ..where((t) => t.recordDate.isSmallerThanValue(end))
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
        ..limit(5))
      .get();

  final now = DateTime.now();
  return records.map((r) {
    return FlashbackItem(
      yearsAgo: now.year - r.recordDate.year,
      title: r.title,
      imageUrl: null,
      type: 'goal',
      recordId: r.id,
      isFavorite: r.isFavorite,
      date: r.recordDate,
      content: r.note,
    );
  }).toList();
}

Future<List<FlashbackItem>> _loadEncounterByTimeRange(AppDatabase db, DateTime start, DateTime end) async {
  final records = await (db.select(db.timelineEvents)
        ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
        ..where((t) => t.recordDate.isSmallerThanValue(end))
        ..where((t) => t.isDeleted.equals(false))
        ..where((t) => t.eventType.equals('encounter'))
        ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
        ..limit(5))
      .get();

  final now = DateTime.now();
  return records.map((r) {
    return FlashbackItem(
      yearsAgo: now.year - r.recordDate.year,
      title: r.title,
      imageUrl: null,
      type: 'encounter',
      recordId: r.id,
      isFavorite: r.isFavorite,
      date: r.recordDate,
      content: r.note,
    );
  }).toList();
}

final upcomingBirthdaysProvider = StreamProvider<List<({FriendRecord friend, int daysLeft})>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.friendDao.watchAllActive().map((friends) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = <({FriendRecord friend, int daysLeft})>[];

    for (final friend in friends) {
      if (friend.birthday == null) continue;

      var nextBirthday = DateTime(now.year, friend.birthday!.month, friend.birthday!.day);
      if (nextBirthday.isBefore(today) || nextBirthday.isAtSameMomentAs(today)) {
        nextBirthday = DateTime(now.year + 1, friend.birthday!.month, friend.birthday!.day);
      }

      final daysLeft = nextBirthday.difference(today).inDays;

      if (daysLeft <= 30) {
        result.add((friend: friend, daysLeft: daysLeft));
      }
    }

    result.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return result;
  });
});

final contactRemindersProvider = StreamProvider<List<({FriendRecord friend, int daysSinceLastMeet})>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.friendDao.watchAllActive().map((friends) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = <({FriendRecord friend, int daysSinceLastMeet})>[];

    for (final friend in friends) {
      if (friend.lastMeetDate == null) continue;

      final daysSinceLastMeet = today.difference(DateTime(
        friend.lastMeetDate!.year,
        friend.lastMeetDate!.month,
        friend.lastMeetDate!.day,
      )).inDays;

      int thresholdDays = 30;
      if (friend.contactFrequency != null && friend.contactFrequency!.isNotEmpty) {
        final freq = friend.contactFrequency!.toLowerCase();
        if (freq.contains('周') || freq.contains('week')) {
          thresholdDays = 7;
        } else if (freq.contains('月') || freq.contains('month')) {
          thresholdDays = 30;
        } else if (freq.contains('季') || freq.contains('quarter')) {
          thresholdDays = 90;
        } else if (freq.contains('年') || freq.contains('year')) {
          thresholdDays = 365;
        }
      }

      if (daysSinceLastMeet >= thresholdDays) {
        result.add((friend: friend, daysSinceLastMeet: daysSinceLastMeet));
      }
    }

    result.sort((a, b) => b.daysSinceLastMeet.compareTo(a.daysSinceLastMeet));
    return result;
  });
});
