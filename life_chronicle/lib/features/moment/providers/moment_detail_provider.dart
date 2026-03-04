import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';

class MomentDetailState {
  const MomentDetailState({
    required this.record,
    required this.links,
    required this.friends,
    required this.foods,
    required this.travels,
    required this.goals,
  });

  final MomentRecord record;
  final List<EntityLink> links;
  final List<FriendRecord> friends;
  final List<FoodRecord> foods;
  final List<TravelRecord> travels;
  final List<GoalRecord> goals;

  Map<String, Set<String>> get groupedLinkIds {
    final result = <String, Set<String>>{};
    for (final link in links) {
      final isMomentSource = link.sourceType == 'moment';
      final isMomentTarget = link.targetType == 'moment';

      if (isMomentSource) {
        final targetType = link.targetType;
        result.putIfAbsent(targetType, () => <String>{}).add(link.targetId);
      } else if (isMomentTarget) {
        final sourceType = link.sourceType;
        result.putIfAbsent(sourceType, () => <String>{}).add(link.sourceId);
      }
    }
    return result;
  }

  List<String> get friendNames {
    final ids = groupedLinkIds['friend'] ?? <String>{};
    return ids.map((id) {
      final friend = friends.where((f) => f.id == id).firstOrNull;
      return friend?.name ?? '';
    }).where((n) => n.isNotEmpty).toList();
  }

  List<String> get foodTitles {
    final ids = groupedLinkIds['food'] ?? <String>{};
    return ids.map((id) {
      final food = foods.where((f) => f.id == id).firstOrNull;
      return food?.title ?? '';
    }).where((n) => n.isNotEmpty).toList();
  }

  List<String> get travelTitles {
    final ids = groupedLinkIds['travel'] ?? <String>{};
    return ids.map((id) {
      final travel = travels.where((t) => t.id == id).firstOrNull;
      return travel?.title ?? travel?.destination ?? '';
    }).where((n) => n.isNotEmpty).toList();
  }

  List<String> get goalTitles {
    final ids = groupedLinkIds['goal'] ?? <String>{};
    return ids.map((id) {
      final goal = goals.where((g) => g.id == id).firstOrNull;
      return goal?.title ?? '';
    }).where((n) => n.isNotEmpty).toList();
  }
}

final momentDetailProvider = StreamProvider.family<MomentDetailState?, String>((ref, recordId) async* {
  final db = ref.watch(appDatabaseProvider);

  final recordStream = db.momentDao.watchById(recordId);
  final linksStream = db.linkDao.watchLinksForEntity(entityType: 'moment', entityId: recordId);
  final friendsStream = db.friendDao.watchAllActive();
  final foodsStream = db.foodDao.watchAllActive();
  final travelsStream = db.watchAllActiveTravelRecords();
  final goalsStream = db.watchUncompletedYearGoals();

  await for (final combined in _combineLatest6(
    recordStream,
    linksStream,
    friendsStream,
    foodsStream,
    travelsStream,
    goalsStream,
  )) {
    final record = combined.$1;
    if (record == null) {
      yield null;
      continue;
    }
    yield MomentDetailState(
      record: record,
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
