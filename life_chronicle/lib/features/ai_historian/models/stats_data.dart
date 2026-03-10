class StatsData {
  final int totalRecords;
  final Map<String, dynamic> distribution;
  final Map<String, dynamic> keyMetrics;
  final Map<String, dynamic> timePatterns;

  const StatsData({
    required this.totalRecords,
    this.distribution = const {},
    this.keyMetrics = const {},
    this.timePatterns = const {},
  });

  String toPromptString() {
    final buffer = StringBuffer();

    buffer.writeln('记录总数：$totalRecords');

    if (distribution.isNotEmpty) {
      buffer.writeln('\n分布统计：');
      distribution.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }

    if (keyMetrics.isNotEmpty) {
      buffer.writeln('\n关键指标：');
      keyMetrics.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }

    if (timePatterns.isNotEmpty) {
      buffer.writeln('\n时间规律：');
      timePatterns.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }

    return buffer.toString();
  }
}
