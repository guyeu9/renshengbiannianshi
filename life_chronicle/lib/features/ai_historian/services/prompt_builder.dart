import 'package:life_chronicle/features/ai_historian/config/module_configs.dart';
import 'package:life_chronicle/features/ai_historian/models/stats_data.dart';
import 'package:life_chronicle/features/ai_historian/services/record_retriever.dart';

class PromptBuilder {
  String buildPrompt({
    required String moduleType,
    required String moduleName,
    required StatsData stats,
    required List<RecordContext> records,
    required String question,
    String? analysisType,
  }) {
    return '''
${buildSystemPrompt()}
${buildModulePrompt(moduleType)}
${buildStatsPrompt(stats)}
${buildRecordsPrompt(records)}
${buildQuestionPrompt(question, analysisType)}
''';
  }

  String buildSystemPrompt() {
    return '''
你是人生编年史APP的AI史官，也是用户的"人生数据分析师"。

你的任务不是简单总结，而是通过用户的人生记录数据：
- 发现行为模式
- 识别隐藏规律
- 解释用户的生活方式
- 给出改善建议

你的回答需要：
- 温暖：像一个真正了解用户的朋友
- 有洞察：发现用户可能没有意识到的模式
- 有数据支撑：用统计数据支持你的结论
- 可执行：给出具体可操作的建议

输出结构必须包含：
【核心洞察】
【数据支撑】
【行为模式】
【专属建议】

如涉及推荐记录，请在回复末尾输出推荐卡片JSON：
```json
{"recommendations": [{"id": "记录ID", "type": "记录类型", "title": "标题", "reason": "推荐理由"}]}
```
''';
  }

  String buildModulePrompt(String moduleType) {
    final config = getModuleConfig(moduleType);
    if (config == null) return '';
    
    return '''
## 当前分析模块

${config.modulePrompt}
''';
  }

  String buildStatsPrompt(StatsData stats) {
    return '''
## 数据概览

${stats.toPromptString()}
''';
  }

  String buildRecordsPrompt(List<RecordContext> records) {
    if (records.isEmpty) {
      return '''
## 详细记录

暂无记录数据。
''';
    }

    final buffer = StringBuffer();
    buffer.writeln('## 详细记录');
    buffer.writeln('');
    buffer.writeln('以下是用户的真实记录数据：');
    buffer.writeln('');

    for (final record in records) {
      buffer.writeln(record.toPromptString());
    }

    return buffer.toString();
  }

  String buildQuestionPrompt(String question, String? analysisType) {
    if (analysisType != null) {
      return '''
## 分析任务

分析类型：$analysisType

用户问题：$question

请按照分析类型的要求，进行深度分析。
''';
    }

    return '''
## 用户问题

$question
''';
  }

  String buildGlobalPrompt({
    required StatsData stats,
    required List<RecordContext> records,
    required String question,
  }) {
    return '''
${buildSystemPrompt()}
${buildGlobalModulePrompt()}
${buildStatsPrompt(stats)}
${buildRecordsPrompt(records)}
${buildQuestionPrompt(question, null)}
''';
  }

  String buildGlobalModulePrompt() {
    return '''
## 当前分析模块

你正在分析用户的全部生活记录数据，涵盖以下模块：
- 美食模块：饮食记录、口味偏好、消费习惯
- 旅行模块：旅行足迹、花费结构、旅行模式
- 小确幸模块：幸福时刻、心情变化、情绪规律
- 目标模块：目标进度、完成模式、执行力分析
- 羁绊模块：社交网络、关系健康度、见面模式

请综合分析用户的生活全貌，发现跨模块的行为模式和关联规律。
''';
  }
}
