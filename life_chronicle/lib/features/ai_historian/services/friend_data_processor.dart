import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/features/ai_historian/models/friend_chat_params.dart';

class FriendDataProcessor {
  static const int _level1Threshold = 100;
  static const int _level2Threshold = 200;
  static const int _filterTargetCount = 100;
  static const int _topMemoriesLimit = 10;
  static const int _recentMemoriesLimit = 10;
  static const int _milestonesLimit = 5;

  ProcessingResult processMemories({
    required FriendRecord friend,
    required List<FriendMemoryData> memories,
    required String analysisType,
  }) {
    final count = memories.length;
    final stats = _generateStatsSummary(memories, friend);

    if (count < _level1Threshold) {
      return ProcessingResult(
        level: ProcessingLevel.direct,
        prompt: _buildDirectPrompt(friend, memories, stats, analysisType),
        stats: stats,
        processedCount: count,
        totalCount: count,
      );
    } else if (count < _level2Threshold) {
      final filtered = _filterImportantMemories(memories);
      return ProcessingResult(
        level: ProcessingLevel.filtered,
        prompt: _buildFilteredPrompt(friend, memories, filtered, stats, analysisType),
        stats: stats,
        processedCount: filtered.length,
        totalCount: count,
      );
    } else {
      final summaryData = _buildSummaryLayer(friend, memories);
      return ProcessingResult(
        level: ProcessingLevel.summary,
        prompt: _buildSummaryPrompt(friend, summaryData, analysisType),
        stats: summaryData.stats,
        processedCount: _topMemoriesLimit + _recentMemoriesLimit + _milestonesLimit,
        totalCount: count,
      );
    }
  }

  FriendStatsSummary _generateStatsSummary(
    List<FriendMemoryData> memories,
    FriendRecord friend,
  ) {
    final now = DateTime.now();
    final knownDays = friend.meetDate != null
        ? now.difference(friend.meetDate!).inDays
        : 0;

    final byType = <String, int>{};
    final byYear = <int, int>{};
    final byMonth = <int, int>{};
    final byWeekday = <int, int>{};
    final moodDistribution = <String, int>{};
    final placeCount = <String, int>{};

    for (final m in memories) {
      byType[m.type] = (byType[m.type] ?? 0) + 1;
      byYear[m.date.year] = (byYear[m.date.year] ?? 0) + 1;
      byMonth[m.date.month] = (byMonth[m.date.month] ?? 0) + 1;
      byWeekday[m.date.weekday] = (byWeekday[m.date.weekday] ?? 0) + 1;
      if (m.mood != null && m.mood!.isNotEmpty) {
        moodDistribution[m.mood!] = (moodDistribution[m.mood!] ?? 0) + 1;
      }
      if (m.place != null && m.place!.isNotEmpty) {
        placeCount[m.place!] = (placeCount[m.place!] ?? 0) + 1;
      }
    }

    final topPlaces = placeCount.entries
        .map((e) => PlaceFrequency(name: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final typeLabels = {
      'encounter': '相遇',
      'food': '美食',
      'moment': '小确幸',
      'travel': '旅行',
    };
    final topActivities = byType.entries
        .map((e) => ActivityFrequency(
              name: typeLabels[e.key] ?? e.key,
              count: e.value,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final yearSpan = byYear.keys.isEmpty
        ? 0
        : byYear.keys.reduce((a, b) => a > b ? a : b) -
            byYear.keys.reduce((a, b) => a < b ? a : b) +
            1;

    String peakPeriod = '暂无数据';
    if (byMonth.isNotEmpty) {
      final peakMonth = byMonth.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      peakPeriod = '$peakMonth月';
    }

    final trend = _calculateTrend(memories, now);

    return FriendStatsSummary(
      totalMemories: memories.length,
      knownDays: knownDays,
      yearSpan: yearSpan,
      byType: byType,
      byYear: byYear,
      topPlaces: topPlaces,
      topActivities: topActivities,
      moodDistribution: moodDistribution,
      timePatterns: TimePatterns(
        byMonth: byMonth,
        byWeekday: byWeekday,
        peakPeriod: peakPeriod,
      ),
      trend: trend,
    );
  }

  RelationshipTrend _calculateTrend(List<FriendMemoryData> memories, DateTime now) {
    if (memories.isEmpty) {
      return const RelationshipTrend(
        direction: 'stable',
        changeRate: 0,
        description: '暂无足够数据分析趋势',
      );
    }

    final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

    final recent6Months = memories.where((m) => m.date.isAfter(sixMonthsAgo)).length;
    final previous6Months = memories
        .where((m) => m.date.isAfter(oneYearAgo) && !m.date.isAfter(sixMonthsAgo))
        .length;

    if (previous6Months == 0) {
      return RelationshipTrend(
        direction: 'increasing',
        changeRate: 100,
        description: '近期互动频繁，关系正在升温',
      );
    }

    final changeRate = ((recent6Months - previous6Months) / previous6Months * 100);

    String direction;
    String description;

    if (changeRate > 20) {
      direction = 'increasing';
      description = '近期互动增加${changeRate.toStringAsFixed(0)}%，关系正在升温';
    } else if (changeRate < -20) {
      direction = 'decreasing';
      description = '近期互动减少${(-changeRate).toStringAsFixed(0)}%，可能需要主动维护';
    } else {
      direction = 'stable';
      description = '关系稳定，保持当前互动频率';
    }

    return RelationshipTrend(
      direction: direction,
      changeRate: changeRate,
      description: description,
    );
  }

  List<FriendMemoryData> _filterImportantMemories(List<FriendMemoryData> memories) {
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));

    final scored = memories.asMap().entries.map((entry) {
      final index = entry.key;
      final m = entry.value;
      var score = 0;

      if (index < 50) score += 100;
      if (m.type == 'travel') score += 10;
      if (m.images.isNotEmpty) score += 5;
      if (m.isFavorite) score += 8;
      if ((m.content?.length ?? 0) > 100) score += 3;
      if (m.date.isAfter(oneYearAgo)) score += 5;
      if (m.mood == '开心' || m.mood == '感动') score += 2;

      return MapEntry(m, score);
    }).toList();
    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.take(_filterTargetCount).map((e) => e.key).toList();
  }

  FriendAnalysisData _buildSummaryLayer(
    FriendRecord friend,
    List<FriendMemoryData> allMemories,
  ) {
    final stats = _generateStatsSummary(allMemories, friend);
    final topMemories = _selectTopMemories(allMemories);
    final recentMemories = _selectRecentMemories(allMemories);
    final milestones = _selectMilestones(allMemories, friend);

    return FriendAnalysisData(
      stats: stats,
      topMemories: topMemories,
      recentMemories: recentMemories,
      milestones: milestones,
    );
  }

  List<FriendMemoryData> _selectTopMemories(List<FriendMemoryData> memories) {
    final scored = memories.map((m) {
      var score = 0;
      if (m.images.length >= 3) score += 10;
      if (m.type == 'travel') score += 8;
      if (m.isFavorite) score += 6;
      if (m.mood == '开心' || m.mood == '感动') score += 4;
      if ((m.content?.length ?? 0) > 200) score += 3;
      return MapEntry(m, score);
    }).toList();
    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.take(_topMemoriesLimit).map((e) => e.key).toList();
  }

  List<FriendMemoryData> _selectRecentMemories(List<FriendMemoryData> memories) {
    final sorted = List<FriendMemoryData>.from(memories);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(_recentMemoriesLimit).toList();
  }

  List<FriendMemoryData> _selectMilestones(
    List<FriendMemoryData> memories,
    FriendRecord friend,
  ) {
    final milestones = <FriendMemoryData>[];

    final travelMemories = memories.where((m) => m.type == 'travel').toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (travelMemories.isNotEmpty) {
      milestones.add(travelMemories.first);
    }

    if (friend.meetDate != null) {
      final anniversaryMemories = memories.where((m) {
        final yearsDiff = m.date.year - friend.meetDate!.year;
        final isAnniversaryMonth = m.date.month == friend.meetDate!.month;
        return yearsDiff > 0 && yearsDiff % 5 == 0 && isAnniversaryMonth;
      }).toList();
      milestones.addAll(anniversaryMemories.take(2));
    }

    if (friend.birthday != null) {
      final birthdayMemories = memories.where((m) {
        return m.date.month == friend.birthday!.month &&
            m.date.day == friend.birthday!.day;
      }).toList();
      milestones.addAll(birthdayMemories.take(2));
    }

    return milestones.take(_milestonesLimit).toList();
  }

  String _buildDirectPrompt(
    FriendRecord friend,
    List<FriendMemoryData> memories,
    FriendStatsSummary stats,
    String analysisType,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('## 朋友基本信息');
    buffer.writeln('- 姓名：${friend.name}');
    if (friend.meetDate != null) {
      buffer.writeln('- 认识日期：${_formatDate(friend.meetDate!)}（已认识${stats.knownDays}天）');
    }
    if (friend.meetWay != null && friend.meetWay!.isNotEmpty) {
      buffer.writeln('- 认识途径：${friend.meetWay}');
    }
    if (friend.impressionTags.isNotEmpty) {
      buffer.writeln('- 印象标签：${friend.impressionTags.join('、')}');
    }
    if (friend.birthday != null) {
      buffer.writeln('- 生日：${_formatBirthday(friend.birthday!)}');
    }
    buffer.writeln('');

    buffer.writeln('## 共同回忆（共${memories.length}条）');
    for (final m in memories) {
      buffer.writeln('');
      buffer.writeln('【${_formatDate(m.date)}】${m.typeLabel}');
      buffer.writeln('标题：${m.title}');
      if (m.content != null && m.content!.isNotEmpty) {
        buffer.writeln('内容：${m.content}');
      }
      if (m.place != null && m.place!.isNotEmpty) {
        buffer.writeln('地点：${m.place}');
      }
    }

    return buffer.toString();
  }

  String _buildFilteredPrompt(
    FriendRecord friend,
    List<FriendMemoryData> allMemories,
    List<FriendMemoryData> filteredMemories,
    FriendStatsSummary stats,
    String analysisType,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('## 朋友基本信息');
    buffer.writeln('- 姓名：${friend.name}');
    if (friend.meetDate != null) {
      buffer.writeln('- 认识日期：${_formatDate(friend.meetDate!)}（已认识${stats.knownDays}天）');
    }
    if (friend.meetWay != null && friend.meetWay!.isNotEmpty) {
      buffer.writeln('- 认识途径：${friend.meetWay}');
    }
    buffer.writeln('');

    buffer.writeln('## 数据概览');
    buffer.writeln('- 总回忆数：${allMemories.length}条');
    buffer.writeln('- 本次分析：${filteredMemories.length}条（已筛选重要回忆）');
    buffer.writeln('');

    buffer.writeln('## 统计摘要');
    buffer.writeln('- 类型分布：${_formatTypeDistribution(stats.byType)}');
    buffer.writeln('- 年份分布：${_formatYearDistribution(stats.byYear)}');
    if (stats.topPlaces.isNotEmpty) {
      buffer.writeln('- 高频地点：${stats.topPlaces.take(5).map((p) => p.name).join('、')}');
    }
    buffer.writeln('');

    buffer.writeln('## 重要回忆详情');
    for (final m in filteredMemories) {
      buffer.writeln('');
      buffer.writeln('【${_formatDate(m.date)}】${m.typeLabel}');
      buffer.writeln('标题：${m.title}');
      if (m.content != null && m.content!.isNotEmpty) {
        buffer.writeln('内容：${m.content}');
      }
    }

    return buffer.toString();
  }

  String _buildSummaryPrompt(
    FriendRecord friend,
    FriendAnalysisData data,
    String analysisType,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('## 朋友基本信息');
    buffer.writeln('- 姓名：${friend.name}');
    buffer.writeln('- 认识日期：${_formatDate(friend.meetDate!)}（已认识${data.stats.knownDays}天）');
    if (friend.meetWay != null && friend.meetWay!.isNotEmpty) {
      buffer.writeln('- 认识途径：${friend.meetWay}');
    }
    if (friend.impressionTags.isNotEmpty) {
      buffer.writeln('- 印象标签：${friend.impressionTags.join('、')}');
    }
    if (friend.birthday != null) {
      buffer.writeln('- 生日：${_formatBirthday(friend.birthday!)}');
    }
    buffer.writeln('');

    buffer.writeln('## 数据概览');
    buffer.writeln('- 总回忆数：${data.stats.totalMemories}条');
    buffer.writeln('- 数据跨度：${data.stats.yearSpan}年');
    buffer.writeln('');

    buffer.writeln('## 统计摘要');
    buffer.writeln('### 类型分布');
    buffer.writeln(_formatTypeDistribution(data.stats.byType));
    buffer.writeln('');

    buffer.writeln('### 年份分布');
    buffer.writeln(_formatYearDistribution(data.stats.byYear));
    buffer.writeln('');

    if (data.stats.topPlaces.isNotEmpty) {
      buffer.writeln('### 高频地点Top5');
      for (final p in data.stats.topPlaces.take(5)) {
        buffer.writeln('- ${p.name}（${p.count}次）');
      }
      buffer.writeln('');
    }

    if (data.stats.topActivities.isNotEmpty) {
      buffer.writeln('### 高频活动Top5');
      for (final a in data.stats.topActivities.take(5)) {
        buffer.writeln('- ${a.name}（${a.count}次）');
      }
      buffer.writeln('');
    }

    if (data.stats.moodDistribution.isNotEmpty) {
      buffer.writeln('### 心情分布');
      buffer.writeln(_formatMoodDistribution(data.stats.moodDistribution));
      buffer.writeln('');
    }

    buffer.writeln('### 关系趋势');
    buffer.writeln(data.stats.trend.description);
    buffer.writeln('');

    if (data.topMemories.isNotEmpty) {
      buffer.writeln('## 最重要的高光时刻（Top 10）');
      for (final m in data.topMemories) {
        buffer.writeln('');
        buffer.writeln('【${_formatDate(m.date)}】${m.typeLabel}');
        buffer.writeln('标题：${m.title}');
        if (m.content != null && m.content!.isNotEmpty) {
          buffer.writeln('内容：${m.content}');
        }
      }
      buffer.writeln('');
    }

    if (data.recentMemories.isNotEmpty) {
      buffer.writeln('## 最近互动（10条）');
      for (final m in data.recentMemories) {
        buffer.writeln('【${_formatDate(m.date)}】${m.typeLabel} - ${m.title}');
      }
      buffer.writeln('');
    }

    if (data.milestones.isNotEmpty) {
      buffer.writeln('## 里程碑事件');
      for (final m in data.milestones) {
        buffer.writeln('【${_formatDate(m.date)}】${m.typeLabel} - ${m.title}');
      }
    }

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _formatBirthday(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  String _formatTypeDistribution(Map<String, int> byType) {
    final typeLabels = {
      'encounter': '相遇',
      'food': '美食',
      'moment': '小确幸',
      'travel': '旅行',
    };
    return byType.entries
        .map((e) => '${typeLabels[e.key] ?? e.key}(${e.value})')
        .join('、');
  }

  String _formatYearDistribution(Map<int, int> byYear) {
    final sortedYears = byYear.keys.toList()..sort();
    return sortedYears.map((y) => '$y年(${byYear[y]})').join('、');
  }

  String _formatMoodDistribution(Map<String, int> moodDistribution) {
    return moodDistribution.entries
        .map((e) => '${e.key}(${e.value})')
        .join('、');
  }
}
