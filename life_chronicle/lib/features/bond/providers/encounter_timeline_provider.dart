import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';

class EncounterTimelineState {
  const EncounterTimelineState({
    required this.encounters,
    required this.foods,
    required this.moments,
    required this.travels,
    required this.friendLinks,
  });

  final List<TimelineEvent> encounters;
  final List<FoodRecord> foods;
  final List<MomentRecord> moments;
  final List<TravelRecord> travels;
  final Map<String, List<String>> friendLinks;

  static EncounterTimelineState empty() => const EncounterTimelineState(
        encounters: [],
        foods: [],
        moments: [],
        travels: [],
        friendLinks: {},
      );
}

final encounterTimelineProvider = StreamProvider<EncounterTimelineState>((ref) async* {
  final db = ref.watch(appDatabaseProvider);

  final encountersStream = db.watchEncounterEvents();
  final foodsStream = db.watchFoodRecordsWithFriends();
  final momentsStream = db.watchMomentRecordsWithFriends();
  final travelsStream = db.watchTravelRecordsWithFriends();

  await for (final combined in _combineLatest4(
    encountersStream,
    foodsStream,
    momentsStream,
    travelsStream,
  )) {
    final encounters = combined.$1;
    final foods = combined.$2;
    final moments = combined.$3;
    final travels = combined.$4;

    final friendLinks = <String, List<String>>{};

    // 批量查询 encounter 关联
    if (encounters.isNotEmpty) {
      final encounterIds = encounters.map((e) => e.id).toList();
      final links = await db.linkDao.listLinksForEntities(
        entityType: 'encounter',
        entityIds: encounterIds,
      );
      for (final link in links) {
        if (link.targetType == 'friend') {
          (friendLinks[link.sourceId] ??= <String>[]).add(link.targetId);
        }
        if (link.sourceType == 'friend') {
          (friendLinks[link.targetId] ??= <String>[]).add(link.sourceId);
        }
      }
    }

    // 批量查询 food 关联
    if (foods.isNotEmpty) {
      final foodIds = foods.map((f) => f.id).toList();
      final links = await db.linkDao.listLinksForEntities(
        entityType: 'food',
        entityIds: foodIds,
      );
      for (final link in links) {
        if (link.targetType == 'friend') {
          (friendLinks[link.sourceId] ??= <String>[]).add(link.targetId);
        }
        if (link.sourceType == 'friend') {
          (friendLinks[link.targetId] ??= <String>[]).add(link.sourceId);
        }
      }
    }

    // 批量查询 moment 关联
    if (moments.isNotEmpty) {
      final momentIds = moments.map((m) => m.id).toList();
      final links = await db.linkDao.listLinksForEntities(
        entityType: 'moment',
        entityIds: momentIds,
      );
      for (final link in links) {
        if (link.targetType == 'friend') {
          (friendLinks[link.sourceId] ??= <String>[]).add(link.targetId);
        }
        if (link.sourceType == 'friend') {
          (friendLinks[link.targetId] ??= <String>[]).add(link.sourceId);
        }
      }
    }

    // 批量查询 travel 关联
    if (travels.isNotEmpty) {
      final travelIds = travels.map((t) => t.id).toList();
      final links = await db.linkDao.listLinksForEntities(
        entityType: 'travel',
        entityIds: travelIds,
      );
      for (final link in links) {
        if (link.targetType == 'friend') {
          (friendLinks[link.sourceId] ??= <String>[]).add(link.targetId);
        }
        if (link.sourceType == 'friend') {
          (friendLinks[link.targetId] ??= <String>[]).add(link.sourceId);
        }
      }
    }

    yield EncounterTimelineState(
      encounters: encounters,
      foods: foods,
      moments: moments,
      travels: travels,
      friendLinks: friendLinks,
    );
  }
});

Stream<(T1, T2, T3, T4)> _combineLatest4<T1, T2, T3, T4>(
  Stream<T1> s1,
  Stream<T2> s2,
  Stream<T3> s3,
  Stream<T4> s4,
) {
  T1? v1;
  T2? v2;
  T3? v3;
  T4? v4;
  var hasV1 = false;
  var hasV2 = false;
  var hasV3 = false;
  var hasV4 = false;
  var doneCount = 0;
  final subscriptions = <StreamSubscription>[];
  final controller = StreamController<(T1, T2, T3, T4)>();

  void emit() {
    if (hasV1 && hasV2 && hasV3 && hasV4) {
      controller.add((v1 as T1, v2 as T2, v3 as T3, v4 as T4));
    }
  }

  void onDone() {
    doneCount++;
    if (doneCount >= 4) {
      controller.close();
    }
  }

  subscriptions.addAll([
    s1.listen((v) { v1 = v; hasV1 = true; emit(); }, onError: controller.addError, onDone: onDone),
    s2.listen((v) { v2 = v; hasV2 = true; emit(); }, onError: controller.addError, onDone: onDone),
    s3.listen((v) { v3 = v; hasV3 = true; emit(); }, onError: controller.addError, onDone: onDone),
    s4.listen((v) { v4 = v; hasV4 = true; emit(); }, onError: controller.addError, onDone: onDone),
  ]);

  controller.onCancel = () {
    for (final sub in subscriptions) {
      sub.cancel();
    }
  };

  return controller.stream;
}
