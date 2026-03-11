import 'friend_chat_params.dart';

class ModuleChatParams {
  final String moduleType;
  final String moduleName;
  final String? initialQuery;
  final String? analysisType;
  final List<String>? recordIds;
  final bool fullData;
  final FriendChatParams? friendParams;

  const ModuleChatParams({
    required this.moduleType,
    required this.moduleName,
    this.initialQuery,
    this.analysisType,
    this.recordIds,
    this.fullData = true,
    this.friendParams,
  });

  bool get isModuleMode => true;
  bool get isDetailMode => recordIds != null && recordIds!.isNotEmpty;
  bool get isFriendMode => friendParams != null;
}
