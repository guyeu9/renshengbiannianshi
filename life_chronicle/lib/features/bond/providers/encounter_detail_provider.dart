import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:rxdart/rxdart.dart';

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

final encounterDetailProvider = StreamProvider.family.autoDispose<EncounterDetailState?, String>((ref, encounterId) {
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

  return Rx.combineLatest6(
    eventStream,
    linksStream,
    friendsStream,
    foodsStream,
    travelsStream,
    goalsStream,
    (event, links, friends, foods, travels, goals) {
      if (event == null) return null;
      return EncounterDetailState(
        event: event,
        links: links,
        friends: friends,
        foods: foods,
        travels: travels,
        goals: goals,
      );
    },
  );
});
