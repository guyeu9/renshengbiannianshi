import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';

class EncounterDetailState {
  const EncounterDetailState({
    required this.event,
    required this.links,
    required this.friends,
    required this.foods,
    required this.travels,
    required this.goals,
  });

  final TimelineEvent event;
  final List<EntityLink> links;
  final List<FriendRecord> friends;
  final List<FoodRecord> foods;
  final List<TravelRecord> travels;
  final List<TimelineEvent> goals;

  List<String> get friendIds {
    final ids = <String>{};
    for (final link in links) {
      final isSource = link.sourceType == 'encounter' && link.sourceId == event.id;
      if (isSource) {
        ids.add(link.targetId);
      } else {
        ids.add(link.sourceId);
      }
    }
    return ids.toList();
  }

  List<String> get foodIds {
    final ids = <String>{};
    for (final link in links) {
      final isSource = link.sourceType == 'encounter' && link.sourceId == event.id;
      if (isSource && link.targetType == 'food') {
        ids.add(link.targetId);
      } else if (!isSource && link.sourceType == 'food') {
        ids.add(link.sourceId);
      }
    }
    return ids.toList();
  }

  List<String> get travelIds {
    final ids = <String>{};
    for (final link in links) {
      final isSource = link.sourceType == 'encounter' && link.sourceId == event.id;
      if (isSource && link.targetType == 'travel') {
        ids.add(link.targetId);
      } else if (!isSource && link.sourceType == 'travel') {
        ids.add(link.sourceId);
      }
    }
    return ids.toList();
  }

  List<String> get goalIds {
    final ids = <String>{};
    for (final link in links) {
      final isSource = link.sourceType == 'encounter' && link.sourceId == event.id;
      if (isSource && link.targetType == 'goal') {
        ids.add(link.targetId);
      } else if (!isSource && link.sourceType == 'goal') {
        ids.add(link.sourceId);
      }
    }
    return ids.toList();
  }

  List<String> get friendNames {
    return friendIds.map((id) {
      final friend = friends.where((f) => f.id == id).firstOrNull;
      return friend?.name ?? '';
    }).where((n) => n.isNotEmpty).toList();
  }

  List<String> get foodTitles {
    return foodIds.map((id) {
      final food = foods.where((f) => f.id == id).firstOrNull;
      return food?.title ?? '';
    }).where((t) => t.isNotEmpty).toList();
  }

  List<String> get travelTitles {
    return travelIds.map((id) {
      final travel = travels.where((t) => t.id == id).firstOrNull;
      final title = travel?.title?.trim() ?? '';
      final dest = travel?.destination?.trim() ?? '';
      return title.isNotEmpty ? title : dest;
    }).where((t) => t.isNotEmpty).toList();
  }

  List<String> get goalTitles {
    return goalIds.map((id) {
      final goal = goals.where((g) => g.id == id).firstOrNull;
      return goal?.title ?? '';
    }).where((t) => t.isNotEmpty).toList();
  }
}

final encounterDetailProvider = StreamProvider.family.autoDispose<EncounterDetailState?, String>((ref, encounterId) async* {
  final db = ref.watch(appDatabaseProvider);

  final eventStream = (db.select(db.timelineEvents)
        ..where((t) => t.isDeleted.equals(false))
        ..where((t) => t.id.equals(encounterId))
        ..limit(1))
      .watchSingleOrNull();

  final linksStream = db.linkDao.watchLinksForEntity(entityType: 'encounter', entityId: encounterId);
  final friendsStream = db.friendDao.watchAllActive();
  final foodsStream = db.foodDao.watchAllActive();
  final travelsStream = db.watchAllActiveTravelRecords();
  final goalsStream = (db.select(db.timelineEvents)
        ..where((t) => t.isDeleted.equals(false))
        ..where((t) => t.eventType.equals('goal')))
      .watch();

  await for (final combined in _combineLatest6(
    eventStream,
    linksStream,
    friendsStream,
    foodsStream,
    travelsStream,
    goalsStream,
  )) {
    final event = combined.$1;
    if (event == null) {
      yield null;
      continue;
    }
    yield EncounterDetailState(
      event: event,
      links: combined.$2,
      friends: combined.$3,
      foods: combined.$4,
      travels: combined.$5,
      goals: combined.$6,
    );
  }
});

Stream<(T1, T2, T3, T4, T5, T6)> _combineLatest6<T1, T2, T3, T4, T5, T6>(
  Stream<T1> s1,
  Stream<T2> s2,
  Stream<T3> s3,
  Stream<T4> s4,
  Stream<T5> s5,
  Stream<T6> s6,
) {
  T1? v1;
  T2? v2;
  T3? v3;
  T4? v4;
  T5? v5;
  T6? v6;
  var hasV1 = false;
  var hasV2 = false;
  var hasV3 = false;
  var hasV4 = false;
  var hasV5 = false;
  var hasV6 = false;

  final controller = StreamController<(T1, T2, T3, T4, T5, T6)>();

  void emit() {
    if (hasV1 && hasV2 && hasV3 && hasV4 && hasV5 && hasV6) {
      controller.add((v1 as T1, v2 as T2, v3 as T3, v4 as T4, v5 as T5, v6 as T6));
    }
  }

  s1.listen((v) { v1 = v; hasV1 = true; emit(); }, onError: controller.addError, onDone: controller.close);
  s2.listen((v) { v2 = v; hasV2 = true; emit(); }, onError: controller.addError);
  s3.listen((v) { v3 = v; hasV3 = true; emit(); }, onError: controller.addError);
  s4.listen((v) { v4 = v; hasV4 = true; emit(); }, onError: controller.addError);
  s5.listen((v) { v5 = v; hasV5 = true; emit(); }, onError: controller.addError);
  s6.listen((v) { v6 = v; hasV6 = true; emit(); }, onError: controller.addError);

  return controller.stream;
}
