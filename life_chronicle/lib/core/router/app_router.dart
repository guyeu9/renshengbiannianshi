import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_shell.dart';
import '../../features/home_schedule/presentation/home_schedule_page.dart';
import '../../features/food/presentation/food_page.dart';
import '../../features/moment/presentation/moment_page.dart';
import '../../features/travel/presentation/travel_page.dart';
import '../../features/goal/presentation/goal_page.dart';
import '../../features/bond/presentation/bond_page.dart';
import '../../features/bond/presentation/encounter_pages.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/ai_model_management_page.dart';
import '../../features/ai_historian/presentation/ai_historian_chat_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String food = '/food';
  static const String foodDetail = '/food/:id';
  static const String foodCreate = '/food/create';
  static const String moment = '/moment';
  static const String momentDetail = '/moment/:id';
  static const String momentCreate = '/moment/create';
  static const String travel = '/travel';
  static const String travelDetail = '/travel/:id';
  static const String travelCreate = '/travel/create';
  static const String goal = '/goal';
  static const String goalDetail = '/goal/:id';
  static const String goalCreate = '/goal/create';
  static const String bond = '/bond';
  static const String encounterDetail = '/encounter/:id';
  static const String encounterCreate = '/encounter/create';
  static const String profile = '/profile';
  static const String aiModelManagement = '/profile/ai-models';
  static const String aiHistorian = '/ai-historian';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeSchedulePage(),
          ),
          GoRoute(
            path: AppRoutes.food,
            name: 'food',
            builder: (context, state) => const FoodPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'foodCreate',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return FoodCreatePage(
                    initialRecord: extra?['initialRecord'],
                    prefillTitle: extra?['prefillTitle'],
                    prefillPoiName: extra?['prefillPoiName'],
                    prefillPoiAddress: extra?['prefillPoiAddress'],
                    prefillPricePerPerson: extra?['prefillPricePerPerson'],
                    overrideIsWishlist: extra?['overrideIsWishlist'],
                    overrideWishlistDone: extra?['overrideWishlistDone'],
                    popWithResultOnPublish: extra?['popWithResultOnPublish'] ?? false,
                  );
                },
              ),
              GoRoute(
                path: ':id',
                name: 'foodDetail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return FoodDetailPage(recordId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.moment,
            name: 'moment',
            builder: (context, state) => const MomentPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'momentCreate',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return MomentCreatePage(
                    initialRecord: extra?['initialRecord'],
                  );
                },
              ),
              GoRoute(
                path: ':id',
                name: 'momentDetail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return MomentDetailPage(recordId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.travel,
            name: 'travel',
            builder: (context, state) => const TravelPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'travelCreate',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return TravelCreatePage(
                    initialRecord: extra?['initialRecord'],
                    initialTrip: extra?['initialTrip'],
                  );
                },
              ),
              GoRoute(
                path: ':id',
                name: 'travelDetail',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return TravelDetailPage(
                    item: extra?['item'],
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.goal,
            name: 'goal',
            builder: (context, state) => const GoalPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'goalCreate',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return GoalCreatePage(goal: extra?['goal']);
                },
              ),
              GoRoute(
                path: ':id',
                name: 'goalDetail',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return GoalDetailPage(record: extra?['record']);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.bond,
            name: 'bond',
            builder: (context, state) => const BondPage(),
            routes: [
              GoRoute(
                path: 'encounter/create',
                name: 'encounterCreate',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return EncounterCreatePage(
                    initialEvent: extra?['initialEvent'],
                  );
                },
              ),
              GoRoute(
                path: 'encounter/:id',
                name: 'encounterDetail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return EncounterDetailPage(encounterId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'ai-models',
                name: 'aiModelManagement',
                builder: (context, state) => const AiModelManagementPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.aiHistorian,
        name: 'aiHistorian',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiHistorianChatPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('无法找到页面: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
});

extension GoRouterExtension on BuildContext {
  void goToFoodDetail(String id) => go('${AppRoutes.food}/$id');
  
  void goToMomentDetail(String id) => go('${AppRoutes.moment}/$id');
  
  void goToTravelDetail(String id, {dynamic item}) => go(
    '${AppRoutes.travel}/$id',
    extra: {'item': item},
  );
  
  void goToGoalDetail(String id, {dynamic record}) => go(
    '${AppRoutes.goal}/$id',
    extra: {'record': record},
  );
  
  void goToEncounterDetail(String id) => go('${AppRoutes.bond}/encounter/$id');
  
  void goToAiHistorian() => go(AppRoutes.aiHistorian);
}
