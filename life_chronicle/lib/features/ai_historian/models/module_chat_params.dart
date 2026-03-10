class ModuleChatParams {
  final String moduleType;
  final String moduleName;
  final String? initialQuery;
  final String? analysisType;
  final List<String>? recordIds;
  final bool fullData;

  const ModuleChatParams({
    required this.moduleType,
    required this.moduleName,
    this.initialQuery,
    this.analysisType,
    this.recordIds,
    this.fullData = true,
  });

  bool get isModuleMode => true;
  bool get isDetailMode => recordIds != null && recordIds!.isNotEmpty;
}
