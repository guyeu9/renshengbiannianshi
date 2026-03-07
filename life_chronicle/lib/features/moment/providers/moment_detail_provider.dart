import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:rxdart/rxdart.dart';

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

final momentDetailProvider = StreamProvider.family.autoDispose<MomentDetailState?, String>((ref, recordId) {
  final db = ref.watch(appDatabaseProvider);

  final recordStream = db.momentDao.watchById(recordId);
  final linksStream = db.linkDao.watchLinksForEntity(entityType: 'moment', entityId: recordId);
  final friendsStream = db.friendDao.watchAllActive();
  final foodsStream = db.foodDao.watchAllActive();
  final travelsStream = db.watchAllActiveTravelRecords();
  final goalsStream = db.watchUncompletedYearGoals();

  return Rx.combineLatest6(
    recordStream,
    linksStream,
    friendsStream,
    foodsStream,
    travelsStream,
    goalsStream,
    (record, links, friends, foods, travels, goals) {
      if (record == null) return null;
      return MomentDetailState(
        record: record,
        links: links,
        friends: friends,
        foods: foods,
        travels: travels,
        goals: goals,
      );
    },
  );
});
