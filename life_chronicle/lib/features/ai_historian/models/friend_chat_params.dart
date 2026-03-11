class FriendChatParams {
  final String friendId;
  final String friendName;
  final String? friendAvatar;
  final DateTime? birthday;
  final String? meetWay;
  final DateTime? meetDate;
  final List<String> impressionTags;
  final String? contactFrequency;
  final DateTime? lastMeetDate;
  final bool isFavorite;

  final int knownDays;
  final int totalMemories;
  final Map<String, int> memoryByType;
  final int lastMeetDays;

  final List<FriendMemoryData> memories;

  final int friendRank;
  final int totalFriends;

  const FriendChatParams({
    required this.friendId,
    required this.friendName,
    this.friendAvatar,
    this.birthday,
    this.meetWay,
    this.meetDate,
    required this.impressionTags,
    this.contactFrequency,
    this.lastMeetDate,
    required this.isFavorite,
    required this.knownDays,
    required this.totalMemories,
    required this.memoryByType,
    required this.lastMeetDays,
    required this.memories,
    required this.friendRank,
    required this.totalFriends,
  });

  bool get hasMemories => memories.isNotEmpty;
  bool get hasBirthday => birthday != null;
  bool get hasMeetDate => meetDate != null;
  bool get hasLastMeetDate => lastMeetDate != null;
}

class FriendMemoryData {
  final String id;
  final String type;
  final DateTime date;
  final String title;
  final String? content;
  final String? place;
  final List<String> images;
  final String? mood;
  final bool isFavorite;

  const FriendMemoryData({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    this.content,
    this.place,
    required this.images,
    this.mood,
    this.isFavorite = false,
  });

  String get typeLabel {
    switch (type) {
      case 'encounter':
        return '相遇';
      case 'food':
        return '美食';
      case 'moment':
        return '小确幸';
      case 'travel':
        return '旅行';
      default:
        return '记录';
    }
  }
}

class FriendStatsSummary {
  final int totalMemories;
  final int knownDays;
  final int yearSpan;

  final Map<String, int> byType;
  final Map<int, int> byYear;

  final List<PlaceFrequency> topPlaces;
  final List<ActivityFrequency> topActivities;

  final Map<String, int> moodDistribution;

  final TimePatterns timePatterns;

  final RelationshipTrend trend;

  const FriendStatsSummary({
    required this.totalMemories,
    required this.knownDays,
    required this.yearSpan,
    required this.byType,
    required this.byYear,
    required this.topPlaces,
    required this.topActivities,
    required this.moodDistribution,
    required this.timePatterns,
    required this.trend,
  });
}

class FriendAnalysisData {
  final FriendStatsSummary stats;
  final List<FriendMemoryData> topMemories;
  final List<FriendMemoryData> recentMemories;
  final List<FriendMemoryData> milestones;

  const FriendAnalysisData({
    required this.stats,
    required this.topMemories,
    required this.recentMemories,
    required this.milestones,
  });
}

class PlaceFrequency {
  final String name;
  final int count;

  const PlaceFrequency({required this.name, required this.count});
}

class ActivityFrequency {
  final String name;
  final int count;

  const ActivityFrequency({required this.name, required this.count});
}

class TimePatterns {
  final Map<int, int> byMonth;
  final Map<int, int> byWeekday;
  final String peakPeriod;

  const TimePatterns({
    required this.byMonth,
    required this.byWeekday,
    required this.peakPeriod,
  });
}

class RelationshipTrend {
  final String direction;
  final double changeRate;
  final String description;

  const RelationshipTrend({
    required this.direction,
    required this.changeRate,
    required this.description,
  });

  bool get isIncreasing => direction == 'increasing';
  bool get isStable => direction == 'stable';
  bool get isDecreasing => direction == 'decreasing';
}

enum ProcessingLevel {
  direct,
  filtered,
  summary,
}

class ProcessingResult {
  final ProcessingLevel level;
  final String prompt;
  final FriendStatsSummary stats;
  final int processedCount;
  final int totalCount;

  const ProcessingResult({
    required this.level,
    required this.prompt,
    required this.stats,
    required this.processedCount,
    required this.totalCount,
  });

  String get levelDescription {
    switch (level) {
      case ProcessingLevel.direct:
        return '全量数据分析';
      case ProcessingLevel.filtered:
        return '重要回忆分析';
      case ProcessingLevel.summary:
        return '摘要层分析';
    }
  }
}
