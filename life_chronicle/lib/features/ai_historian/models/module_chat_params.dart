import 'friend_chat_params.dart';

class ModuleChatParams {
  final String moduleType;
  final String moduleName;
  final String? initialQuery;
  final String? analysisType;
  final List<String>? recordIds;
  final bool fullData;
  final FriendChatParams? friendParams;
  final String? sourceRoute;

  const ModuleChatParams({
    required this.moduleType,
    required this.moduleName,
    this.initialQuery,
    this.analysisType,
    this.recordIds,
    this.fullData = true,
    this.friendParams,
    this.sourceRoute,
  });

  bool get isModuleMode => true;
  bool get isDetailMode => recordIds != null && recordIds!.isNotEmpty;
  bool get isFriendMode => friendParams != null;

  ModuleChatParams copyWith({
    String? moduleType,
    String? moduleName,
    String? initialQuery,
    String? analysisType,
    List<String>? recordIds,
    bool? fullData,
    FriendChatParams? friendParams,
    String? sourceRoute,
  }) {
    return ModuleChatParams(
      moduleType: moduleType ?? this.moduleType,
      moduleName: moduleName ?? this.moduleName,
      initialQuery: initialQuery ?? this.initialQuery,
      analysisType: analysisType ?? this.analysisType,
      recordIds: recordIds ?? this.recordIds,
      fullData: fullData ?? this.fullData,
      friendParams: friendParams ?? this.friendParams,
      sourceRoute: sourceRoute ?? this.sourceRoute,
    );
  }
}
