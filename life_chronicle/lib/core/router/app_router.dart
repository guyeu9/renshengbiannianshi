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
import '../../features/profile/presentation/data_management_page.dart';
import '../../features/profile/presentation/backup_log_page.dart';
import '../../features/profile/presentation/amap_log_page.dart';
import '../../features/profile/presentation/system_log_page.dart';
import '../../features/ai_historian/presentation/ai_historian_chat_page.dart';
import '../../features/ai_historian/models/module_chat_params.dart';
import 'route_observer.dart';

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
  static const String journalDetail = '/travel/journal/:id';
  
  static const String goal = '/goal';
  static const String goalDetail = '/goal/:id';
  static const String goalCreate = '/goal/create';
  static const String annualGoalSummary = '/goal/annual-summary';
  static const String goalAllLinks = '/goal/links/:id';
  
  static const String bond = '/bond';
  static const String encounterDetail = '/encounter/:id';
  static const String encounterCreate = '/encounter/create';
  static const String friendProfile = '/bond/friend/:id';
  static const String friendCreate = '/bond/friend/create';
  
  static const String profile = '/profile';
  static const String aiModelManagement = '/profile/ai-models';
  static const String chronicleGenerateConfig = '/profile/chronicle-config';
  static const String favoritesCenter = '/profile/favorites';
  static const String chronicleManage = '/profile/chronicle-manage';
  static const String yearReport = '/profile/year-report';
  static const String dataManagement = '/profile/data-management';
  static const String moduleManagement = '/profile/module-management';
  static const String universalLink = '/profile/universal-link';
  static const String personalProfile = '/profile/personal';
  static const String reminderSettings = '/profile/reminder';
  static const String privacySecurity = '/profile/privacy';
  static const String helpFeedback = '/profile/help';
  static const String systemLog = '/profile/system-log';
  
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
                parentNavigatorKey: _rootNavigatorKey,
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
                parentNavigatorKey: _rootNavigatorKey,
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
                parentNavigatorKey: _rootNavigatorKey,
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
                parentNavigatorKey: _rootNavigatorKey,
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
                parentNavigatorKey: _rootNavigatorKey,
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
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return TravelDetailPage(
                    item: extra?['item'],
                  );
                },
              ),
              GoRoute(
                path: 'journal/:id',
                name: 'journalDetail',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return JournalDetailPage(recordId: id);
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
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return GoalCreatePage(goal: extra?['goal']);
                },
              ),
              GoRoute(
                path: ':id',
                name: 'goalDetail',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return GoalDetailPage(record: extra?['record']);
                },
              ),
              GoRoute(
                path: 'annual-summary',
                name: 'annualGoalSummary',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return AnnualGoalSummaryPage(
                    initialYear: extra?['initialYear'] ?? DateTime.now().year,
                    availableYears: extra?['availableYears'] ?? [DateTime.now().year],
                  );
                },
              ),
              GoRoute(
                path: 'links/:id',
                name: 'goalAllLinks',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return GoalAllLinksPage(goalId: id);
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
                parentNavigatorKey: _rootNavigatorKey,
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
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return EncounterDetailPage(encounterId: id);
                },
              ),
              GoRoute(
                path: 'friend/create',
                name: 'friendCreate',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return FriendCreatePage(initialFriend: extra?['initialFriend']);
                },
              ),
              GoRoute(
                path: 'friend/:id',
                name: 'friendProfile',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return FriendProfilePage(friendId: id);
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
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AiModelManagementPage(),
              ),
              GoRoute(
                path: 'chronicle-config',
                name: 'chronicleGenerateConfig',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ChronicleGenerateConfigPage(),
              ),
              GoRoute(
                path: 'favorites',
                name: 'favoritesCenter',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const FavoritesCenterPage(),
              ),
              GoRoute(
                path: 'chronicle-manage',
                name: 'chronicleManage',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ChronicleManagePage(),
              ),
              GoRoute(
                path: 'year-report',
                name: 'yearReport',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const YearReportPage(),
              ),
              GoRoute(
                path: 'data-management',
                name: 'dataManagement',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const DataManagementPage(),
              ),
              GoRoute(
                path: 'module-management',
                name: 'moduleManagement',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ModuleManagementPage(),
              ),
              GoRoute(
                path: 'universal-link',
                name: 'universalLink',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const UniversalLinkPage(),
              ),
              GoRoute(
                path: 'personal',
                name: 'personalProfile',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const PersonalProfilePage(),
              ),
              GoRoute(
                path: 'reminder',
                name: 'reminderSettings',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ReminderSettingsPage(),
              ),
              GoRoute(
                path: 'privacy',
                name: 'privacySecurity',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const PrivacySecurityPage(),
              ),
              GoRoute(
                path: 'help',
                name: 'helpFeedback',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const HelpFeedbackPage(),
              ),
              GoRoute(
                path: 'system-log',
                name: 'systemLog',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const SystemLogPage(),
              ),
              GoRoute(
                path: 'chronicle-preview',
                name: 'chroniclePreview',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return ChroniclePreviewPage(record: extra?['record']);
                },
              ),
              GoRoute(
                path: 'universal-link-logs',
                name: 'universalLinkAllLogs',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const UniversalLinkAllLogsPage(),
              ),
              GoRoute(
                path: 'backup-log',
                name: 'backupLog',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const BackupLogPage(),
              ),
              GoRoute(
                path: 'amap-log',
                name: 'amapLog',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AmapLogPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.aiHistorian,
        name: 'aiHistorian',
        builder: (context, state) {
          final params = state.extra as ModuleChatParams?;
          return AiHistorianChatPage(moduleParams: params);
        },
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
    observers: [AppRouteObserver()],
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
