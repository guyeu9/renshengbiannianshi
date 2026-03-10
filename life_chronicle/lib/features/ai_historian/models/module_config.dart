import 'package:life_chronicle/features/ai_historian/models/quick_action_config.dart';

class ModuleConfig {
  final String moduleType;
  final String moduleName;
  final String modulePrompt;
  final List<String> analysisTypes;
  final List<QuickActionConfig> quickActions;
  final List<String> keyFields;

  const ModuleConfig({
    required this.moduleType,
    required this.moduleName,
    required this.modulePrompt,
    required this.analysisTypes,
    required this.quickActions,
    required this.keyFields,
  });
}
