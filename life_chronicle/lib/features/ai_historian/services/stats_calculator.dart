import 'dart:math';
import 'package:life_chronicle/features/ai_historian/models/stats_data.dart';
import 'package:life_chronicle/features/ai_historian/services/record_retriever.dart';

class StatsCalculator {
  Future<StatsData> calculateFoodStats(List<RecordContext> records) async {
    if (records.isEmpty) {
      return const StatsData(totalRecords: 0);
    }

    final cuisineDistribution = <String, int>{};
    final cityDistribution = <String, int>{};
    final priceDistribution = <String, int>{
      '50元以下': 0,
      '50-100元': 0,
      '100-200元': 0,
      '200元以上': 0,
    };
    final ratingDistribution = <String, int>{
      '1-2星': 0,
      '2-3星': 0,
      '3-4星': 0,
      '4-5星': 0,
    };

    double totalRating = 0;
    double totalPrice = 0;
    int ratingCount = 0;
    int priceCount = 0;
    int highRatedCount = 0;
    int favoriteCount = 0;
    int wishlistCount = 0;

    for (final record in records) {
      if (record.tags != null) {
        for (final tag in record.tags!) {
          cuisineDistribution[tag] = (cuisineDistribution[tag] ?? 0) + 1;
        }
      }

      if (record.extra['city'] != null) {
        final city = record.extra['city'].toString();
        cityDistribution[city] = (cityDistribution[city] ?? 0) + 1;
      }

      final rating = record.extra['rating'] as num?;
      if (rating != null) {
        totalRating += rating;
        ratingCount++;
        if (rating >= 4) {
          highRatedCount++;
        }
        if (rating < 2) {
          ratingDistribution['1-2星'] = ratingDistribution['1-2星']! + 1;
        } else if (rating < 3) {
          ratingDistribution['2-3星'] = ratingDistribution['2-3星']! + 1;
        } else if (rating < 4) {
          ratingDistribution['3-4星'] = ratingDistribution['3-4星']! + 1;
        } else {
          ratingDistribution['4-5星'] = ratingDistribution['4-5星']! + 1;
        }
      }

      final price = record.extra['pricePerPerson'] as num?;
      if (price != null) {
        totalPrice += price;
        priceCount++;
        if (price < 50) {
          priceDistribution['50元以下'] = priceDistribution['50元以下']! + 1;
        } else if (price < 100) {
          priceDistribution['50-100元'] = priceDistribution['50-100元']! + 1;
        } else if (price < 200) {
          priceDistribution['100-200元'] = priceDistribution['100-200元']! + 1;
        } else {
          priceDistribution['200元以上'] = priceDistribution['200元以上']! + 1;
        }
      }

      if (record.isFavorite) {
        favoriteCount++;
      }

      if (record.extra['isWishlist'] == true) {
        wishlistCount++;
      }
    }

    final topCuisines = _getTopItems(cuisineDistribution, 5);
    final topCities = _getTopItems(cityDistribution, 5);

    return StatsData(
      totalRecords: records.length,
      distribution: {
        '菜系分布': topCuisines,
        '城市分布': topCities,
        '消费区间': _formatDistribution(priceDistribution, records.length),
        '评分分布': _formatDistribution(ratingDistribution, records.length),
      },
      keyMetrics: {
        '平均评分': ratingCount > 0 
            ? '${(totalRating / ratingCount).toStringAsFixed(1)}星' 
            : '暂无数据',
        '平均消费': priceCount > 0 
            ? '¥${(totalPrice / priceCount).toStringAsFixed(0)}' 
            : '暂无数据',
        '高分餐厅数': highRatedCount,
        '收藏数量': favoriteCount,
        '心愿清单': wishlistCount,
      },
      timePatterns: _calculateTimePatterns(records),
    );
  }

  Future<StatsData> calculateTravelStats(List<RecordContext> records) async {
    if (records.isEmpty) {
      return const StatsData(totalRecords: 0);
    }

    final destinationDistribution = <String, int>{};
    final cityDistribution = <String, int>{};
    final seasonDistribution = <String, int>{
      '春季(3-5月)': 0,
      '夏季(6-8月)': 0,
      '秋季(9-11月)': 0,
      '冬季(12-2月)': 0,
    };

    double totalExpense = 0;
    double totalTransport = 0;
    double totalHotel = 0;
    double totalFood = 0;
    double totalTicket = 0;
    int expenseCount = 0;
    int favoriteCount = 0;
    int wishlistCount = 0;

    for (final record in records) {
      if (record.extra['destination'] != null) {
        final dest = record.extra['destination'].toString();
        destinationDistribution[dest] = (destinationDistribution[dest] ?? 0) + 1;
      }

      if (record.extra['city'] != null) {
        final city = record.extra['city'].toString();
        cityDistribution[city] = (cityDistribution[city] ?? 0) + 1;
      }

      final transport = (record.extra['expenseTransport'] as num?) ?? 0;
      final hotel = (record.extra['expenseHotel'] as num?) ?? 0;
      final food = (record.extra['expenseFood'] as num?) ?? 0;
      final ticket = (record.extra['expenseTicket'] as num?) ?? 0;
      final total = transport + hotel + food + ticket;

      if (total > 0) {
        totalExpense += total;
        totalTransport += transport;
        totalHotel += hotel;
        totalFood += food;
        totalTicket += ticket;
        expenseCount++;
      }

      final month = record.date.month;
      if (month >= 3 && month <= 5) {
        seasonDistribution['春季(3-5月)'] = seasonDistribution['春季(3-5月)']! + 1;
      } else if (month >= 6 && month <= 8) {
        seasonDistribution['夏季(6-8月)'] = seasonDistribution['夏季(6-8月)']! + 1;
      } else if (month >= 9 && month <= 11) {
        seasonDistribution['秋季(9-11月)'] = seasonDistribution['秋季(9-11月)']! + 1;
      } else {
        seasonDistribution['冬季(12-2月)'] = seasonDistribution['冬季(12-2月)']! + 1;
      }

      if (record.isFavorite) {
        favoriteCount++;
      }

      if (record.extra['isWishlist'] == true) {
        wishlistCount++;
      }
    }

    final topDestinations = _getTopItems(destinationDistribution, 5);
    final topCities = _getTopItems(cityDistribution, 5);

    return StatsData(
      totalRecords: records.length,
      distribution: {
        '目的地分布': topDestinations,
        '城市分布': topCities,
        '季节分布': _formatDistribution(seasonDistribution, records.length),
      },
      keyMetrics: {
        '总花费': '¥${totalExpense.toStringAsFixed(0)}',
        '平均花费': expenseCount > 0 
            ? '¥${(totalExpense / expenseCount).toStringAsFixed(0)}' 
            : '暂无数据',
        '交通花费': '¥${totalTransport.toStringAsFixed(0)}',
        '住宿花费': '¥${totalHotel.toStringAsFixed(0)}',
        '餐饮花费': '¥${totalFood.toStringAsFixed(0)}',
        '门票花费': '¥${totalTicket.toStringAsFixed(0)}',
        '收藏数量': favoriteCount,
        '心愿清单': wishlistCount,
      },
      timePatterns: _calculateTimePatterns(records),
    );
  }

  Future<StatsData> calculateMomentStats(List<RecordContext> records) async {
    if (records.isEmpty) {
      return const StatsData(totalRecords: 0);
    }

    final moodDistribution = <String, int>{};
    final hourDistribution = <String, int>{
      '早晨(6-9点)': 0,
      '上午(9-12点)': 0,
      '下午(12-18点)': 0,
      '晚上(18-22点)': 0,
      '深夜(22-6点)': 0,
    };
    final weekdayDistribution = <String, int>{
      '周一': 0,
      '周二': 0,
      '周三': 0,
      '周四': 0,
      '周五': 0,
      '周六': 0,
      '周日': 0,
    };

    int favoriteCount = 0;

    for (final record in records) {
      if (record.extra['mood'] != null) {
        final mood = record.extra['mood'].toString();
        moodDistribution[mood] = (moodDistribution[mood] ?? 0) + 1;
      }

      final hour = record.date.hour;
      if (hour >= 6 && hour < 9) {
        hourDistribution['早晨(6-9点)'] = hourDistribution['早晨(6-9点)']! + 1;
      } else if (hour >= 9 && hour < 12) {
        hourDistribution['上午(9-12点)'] = hourDistribution['上午(9-12点)']! + 1;
      } else if (hour >= 12 && hour < 18) {
        hourDistribution['下午(12-18点)'] = hourDistribution['下午(12-18点)']! + 1;
      } else if (hour >= 18 && hour < 22) {
        hourDistribution['晚上(18-22点)'] = hourDistribution['晚上(18-22点)']! + 1;
      } else {
        hourDistribution['深夜(22-6点)'] = hourDistribution['深夜(22-6点)']! + 1;
      }

      final weekday = record.date.weekday;
      final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      weekdayDistribution[weekdayNames[weekday - 1]] = 
          weekdayDistribution[weekdayNames[weekday - 1]]! + 1;

      if (record.isFavorite) {
        favoriteCount++;
      }
    }

    final topMoods = _getTopItems(moodDistribution, 5);

    return StatsData(
      totalRecords: records.length,
      distribution: {
        '心情分布': topMoods,
        '时段分布': _formatDistribution(hourDistribution, records.length),
        '星期分布': _formatDistribution(weekdayDistribution, records.length),
      },
      keyMetrics: {
        '收藏数量': favoriteCount,
      },
      timePatterns: _calculateTimePatterns(records),
    );
  }

  Future<StatsData> calculateGoalStats(List<RecordContext> records) async {
    if (records.isEmpty) {
      return const StatsData(totalRecords: 0);
    }

    final categoryDistribution = <String, int>{};
    final levelDistribution = <String, int>{};
    final yearDistribution = <String, int>{};

    int completedCount = 0;
    int postponedCount = 0;
    int favoriteCount = 0;
    double totalProgress = 0;

    for (final record in records) {
      if (record.extra['category'] != null) {
        final category = record.extra['category'].toString();
        categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
      }

      if (record.extra['level'] != null) {
        final level = record.extra['level'].toString();
        levelDistribution[level] = (levelDistribution[level] ?? 0) + 1;
      }

      if (record.extra['targetYear'] != null) {
        final year = record.extra['targetYear'].toString();
        yearDistribution['$year年'] = (yearDistribution['$year年'] ?? 0) + 1;
      }

      if (record.extra['isCompleted'] == true) {
        completedCount++;
      }

      if (record.extra['isPostponed'] == true) {
        postponedCount++;
      }

      final progress = (record.extra['progress'] as num?) ?? 0;
      totalProgress += progress;

      if (record.isFavorite) {
        favoriteCount++;
      }
    }

    final topCategories = _getTopItems(categoryDistribution, 5);

    return StatsData(
      totalRecords: records.length,
      distribution: {
        '分类分布': topCategories,
        '级别分布': _formatDistribution(levelDistribution, records.length),
        '年度分布': _formatDistribution(yearDistribution, records.length),
      },
      keyMetrics: {
        '完成率': '${((completedCount / records.length) * 100).toStringAsFixed(0)}%',
        '平均进度': '${(totalProgress / records.length).toStringAsFixed(0)}%',
        '已完成数': completedCount,
        '顺延数': postponedCount,
        '收藏数量': favoriteCount,
      },
      timePatterns: _calculateTimePatterns(records),
    );
  }

  Future<StatsData> calculateBondStats(List<RecordContext> friendRecords, List<RecordContext> encounterRecords) async {
    if (friendRecords.isEmpty && encounterRecords.isEmpty) {
      return const StatsData(totalRecords: 0);
    }

    final groupDistribution = <String, int>{};
    final meetWayDistribution = <String, int>{};
    final frequencyDistribution = <String, int>{};

    int favoriteCount = 0;

    for (final record in friendRecords) {
      if (record.extra['groupName'] != null) {
        final group = record.extra['groupName'].toString();
        groupDistribution[group] = (groupDistribution[group] ?? 0) + 1;
      }

      if (record.extra['meetWay'] != null) {
        final way = record.extra['meetWay'].toString();
        meetWayDistribution[way] = (meetWayDistribution[way] ?? 0) + 1;
      }

      if (record.extra['contactFrequency'] != null) {
        final freq = record.extra['contactFrequency'].toString();
        frequencyDistribution[freq] = (frequencyDistribution[freq] ?? 0) + 1;
      }

      if (record.isFavorite) {
        favoriteCount++;
      }
    }

    final topGroups = _getTopItems(groupDistribution, 5);

    return StatsData(
      totalRecords: friendRecords.length,
      distribution: {
        '分组分布': topGroups,
        '认识途径': _formatDistribution(meetWayDistribution, friendRecords.length),
        '联络频率': _formatDistribution(frequencyDistribution, friendRecords.length),
      },
      keyMetrics: {
        '朋友总数': friendRecords.length,
        '相遇次数': encounterRecords.length,
        '收藏朋友数': favoriteCount,
      },
      timePatterns: _calculateTimePatterns(encounterRecords),
    );
  }

  Map<String, String> _getTopItems(Map<String, int> distribution, int topN) {
    final sorted = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final result = <String, String>{};
    final total = distribution.values.fold(0, (sum, v) => sum + v);
    
    for (var i = 0; i < min(topN, sorted.length); i++) {
      final entry = sorted[i];
      final percentage = total > 0 
          ? '${((entry.value / total) * 100).toStringAsFixed(0)}%' 
          : '0%';
      result[entry.key] = '${entry.value}条 ($percentage)';
    }
    
    return result;
  }

  Map<String, String> _formatDistribution(Map<String, int> distribution, int total) {
    final result = <String, String>{};
    
    distribution.forEach((key, value) {
      final percentage = total > 0 
          ? '${((value / total) * 100).toStringAsFixed(0)}%' 
          : '0%';
      result[key] = '$value条 ($percentage)';
    });
    
    return result;
  }

  Map<String, dynamic> _calculateTimePatterns(List<RecordContext> records) {
    if (records.isEmpty) {
      return {};
    }

    final now = DateTime.now();
    final thisMonth = records.where((r) => 
        r.date.year == now.year && r.date.month == now.month).length;
    final thisYear = records.where((r) => r.date.year == now.year).length;

    final dates = records.map((r) => r.date).toList()..sort();
    final earliest = dates.first;
    final latest = dates.last;
    final daysDiff = latest.difference(earliest).inDays;

    return {
      '本月记录': thisMonth,
      '本年记录': thisYear,
      '时间跨度': daysDiff > 365 
          ? '${(daysDiff / 365).toStringAsFixed(1)}年' 
          : '$daysDiff天',
      '最早记录': '${earliest.year}-${earliest.month.toString().padLeft(2, '0')}-${earliest.day.toString().padLeft(2, '0')}',
      '最新记录': '${latest.year}-${latest.month.toString().padLeft(2, '0')}-${latest.day.toString().padLeft(2, '0')}',
    };
  }
}
