import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/travel/presentation/travel_page.dart';
import '../../features/ai_historian/models/module_chat_params.dart';
import '../../features/ai_historian/models/friend_chat_params.dart';
import '../../features/profile/presentation/profile_page.dart' show ChronicleRecord;
import '../../core/widgets/amap_location_page.dart';
import '../../core/database/app_database.dart';
import 'app_router.dart';

class RouteNavigation {
  RouteNavigation._();

  static void goToFoodDetail(BuildContext context, String id) {
    context.push('${AppRoutes.food}/$id');
  }

  static Future<bool?> pushToFoodDetail(BuildContext context, String id) {
    return context.push<bool>('${AppRoutes.food}/$id');
  }

  static void goToFoodCreate(BuildContext context, {FoodRecord? initialRecord}) {
    context.push(AppRoutes.foodCreate, extra: {'initialRecord': initialRecord});
  }

  static void goToMomentDetail(BuildContext context, String id) {
    context.push('${AppRoutes.moment}/$id');
  }

  static void goToMomentCreate(BuildContext context, {MomentRecord? initialRecord}) {
    context.push(AppRoutes.momentCreate, extra: {'initialRecord': initialRecord});
  }

  static void goToTravelDetail(BuildContext context, String id, {TravelItem? item}) {
    context.push('${AppRoutes.travel}/$id', extra: {'item': item});
  }

  static void goToTravelCreate(BuildContext context, {TravelRecord? initialRecord}) {
    context.push(AppRoutes.travelCreate, extra: {'initialRecord': initialRecord});
  }

  static void goToJournalDetail(BuildContext context, String id) {
    context.push('/travel/journal/$id');
  }

  static void goToJournalCreate(BuildContext context, {String? initialTripId, String? initialTripTitle, TravelRecord? initialRecord}) {
    context.push('/travel/journal/create', extra: {'initialTripId': initialTripId, 'initialTripTitle': initialTripTitle, 'initialRecord': initialRecord});
  }

  static void goToGoalDetail(BuildContext context, String id, {GoalRecord? record}) {
    context.push('${AppRoutes.goal}/$id', extra: {'record': record});
  }

  static void goToGoalCreate(BuildContext context, {GoalRecord? goal}) {
    context.push(AppRoutes.goalCreate, extra: {'goal': goal});
  }

  static void goToAnnualGoalSummary(BuildContext context, {required int initialYear, required List<int> availableYears}) {
    context.push(AppRoutes.annualGoalSummary, extra: {'initialYear': initialYear, 'availableYears': availableYears});
  }

  static void goToGoalAllLinks(BuildContext context, String goalId) {
    context.push('/goal/links/$goalId');
  }

  static void goToGoalBreakdownMaintenance(BuildContext context, String goalId) {
    context.push('/goal/breakdown', extra: {'goalId': goalId});
  }

  static void goToGoalPostpone(BuildContext context, String goalId) {
    context.push('/goal/postpone', extra: {'goalId': goalId});
  }

  static void goToFriendProfile(BuildContext context, String friendId) {
    context.push(AppRoutes.friendProfile.replaceAll(':id', friendId));
  }

  static void goToFriendCreate(BuildContext context, {FriendRecord? initialFriend}) {
    context.push(AppRoutes.friendCreate, extra: {'initialFriend': initialFriend});
  }

  static void goToEncounterDetail(BuildContext context, String id) {
    context.push('${AppRoutes.bond}/encounter/$id');
  }

  static void goToEncounterCreate(BuildContext context, {TimelineEvent? initialEvent}) {
    context.push(AppRoutes.encounterCreate, extra: {'initialEvent': initialEvent});
  }

  static void goToChronicleGenerateConfig(BuildContext context) {
    context.push(AppRoutes.chronicleGenerateConfig);
  }

  static void goToChroniclePreview(BuildContext context, ChronicleRecord record) {
    context.push('/profile/chronicle-preview', extra: {'record': record});
  }

  static void goToFavoritesCenter(BuildContext context) {
    context.push(AppRoutes.favoritesCenter);
  }

  static void goToChronicleManage(BuildContext context) {
    context.push(AppRoutes.chronicleManage);
  }

  static void goToYearReport(BuildContext context) {
    context.push(AppRoutes.yearReport);
  }

  static void goToDataManagement(BuildContext context) {
    context.push(AppRoutes.dataManagement);
  }

  static void goToModuleManagement(BuildContext context) {
    context.push(AppRoutes.moduleManagement);
  }

  static void goToUniversalLink(BuildContext context) {
    context.push(AppRoutes.universalLink);
  }

  static void goToUniversalLinkAllLogs(BuildContext context) {
    context.push('/profile/universal-link-logs');
  }

  static void goToPersonalProfile(BuildContext context) {
    context.push(AppRoutes.personalProfile);
  }

  static void goToReminderSettings(BuildContext context) {
    context.push(AppRoutes.reminderSettings);
  }

  static void goToPrivacySecurity(BuildContext context) {
    context.push(AppRoutes.privacySecurity);
  }

  static void goToHelpFeedback(BuildContext context) {
    context.push(AppRoutes.helpFeedback);
  }

  static void goToSystemLog(BuildContext context) {
    context.push(AppRoutes.systemLog);
  }

  static void goToBackupLog(BuildContext context) {
    context.push('/profile/backup-log');
  }

  static void goToAmapLog(BuildContext context) {
    context.push('/profile/amap-log');
  }

  static void goToAiModelManagement(BuildContext context) {
    context.push(AppRoutes.aiModelManagement);
  }

  static void goToAiHistorian(BuildContext context, {ModuleChatParams? moduleParams}) {
    context.go(AppRoutes.aiHistorian, extra: moduleParams);
  }

  static void goToAiHistorianForModule(BuildContext context, {
    required String moduleType,
    required String moduleName,
    String? initialQuery,
    String? analysisType,
    List<String>? recordIds,
    bool fullData = true,
  }) {
    final params = ModuleChatParams(
      moduleType: moduleType,
      moduleName: moduleName,
      initialQuery: initialQuery,
      analysisType: analysisType,
      recordIds: recordIds,
      fullData: fullData,
    );
    context.go(AppRoutes.aiHistorian, extra: params);
  }

  static void goToAiHistorianForFriend(
    BuildContext context, {
    required FriendChatParams friendParams,
    String? initialQuery,
    String? analysisType,
  }) {
    final params = ModuleChatParams(
      moduleType: 'friend',
      moduleName: friendParams.friendName,
      initialQuery: initialQuery,
      analysisType: analysisType,
      friendParams: friendParams,
    );
    context.go(AppRoutes.aiHistorian, extra: params);
  }

  static Future<AmapLocationPickResult?> openMapPicker(
    BuildContext context, {
    required String initialPoiName,
    required String initialAddress,
    double? initialLatitude,
    double? initialLongitude,
    String initialCity = '',
    String initialCountry = '',
  }) {
    return Navigator.of(context).push<AmapLocationPickResult>(
      MaterialPageRoute(
        builder: (_) => AmapLocationPage.pick(
          initialPoiName: initialPoiName,
          initialAddress: initialAddress,
          initialLatitude: initialLatitude,
          initialLongitude: initialLongitude,
          initialCity: initialCity,
          initialCountry: initialCountry,
        ),
      ),
    );
  }

  static Future<void> openMapPreview(
    BuildContext context, {
    required String title,
    required String poiName,
    required String address,
    double? latitude,
    double? longitude,
    String city = '',
    String country = '',
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AmapLocationPage.preview(
          title: title,
          poiName: poiName,
          address: address,
          latitude: latitude,
          longitude: longitude,
          city: city,
          country: country,
        ),
      ),
    );
  }

  static void back(BuildContext context, {dynamic result}) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(result);
    } else {
      context.go(AppRoutes.home);
    }
  }

  static void goHome(BuildContext context) {
    context.go(AppRoutes.home);
  }
}
