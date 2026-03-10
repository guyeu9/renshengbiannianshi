import 'dart:convert';

class RecommendationCard {
  final String id;
  final String type;
  final String title;
  final String reason;

  const RecommendationCard({
    required this.id,
    required this.type,
    required this.title,
    required this.reason,
  });

  factory RecommendationCard.fromJson(Map<String, dynamic> json) {
    return RecommendationCard(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class AIAnalysisResult {
  final List<String> insights;
  final Map<String, dynamic> stats;
  final List<String> suggestions;
  final List<RecommendationCard>? recommendations;
  final String rawResponse;

  const AIAnalysisResult({
    required this.insights,
    required this.stats,
    required this.suggestions,
    this.recommendations,
    required this.rawResponse,
  });

  bool get hasRecommendations => 
      recommendations != null && recommendations!.isNotEmpty;
}

class ResponseParser {
  AIAnalysisResult parse(String response) {
    return AIAnalysisResult(
      insights: _parseInsights(response),
      stats: _parseStats(response),
      suggestions: _parseSuggestions(response),
      recommendations: _parseRecommendations(response),
      rawResponse: response,
    );
  }

  List<String> _parseInsights(String response) {
    final regex = RegExp(r'【核心洞察】\s*([\s\S]*?)(?=【|$)');
    final match = regex.firstMatch(response);
    if (match == null) return [];

    return match.group(1)!
        .split('\n')
        .where((line) => line.trim().startsWith('-'))
        .map((line) => line.replaceFirst(RegExp(r'^-\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _parseStats(String response) {
    final regex = RegExp(r'【数据支撑】\s*([\s\S]*?)(?=【|$)');
    final match = regex.firstMatch(response);
    if (match == null) return {};

    final stats = <String, dynamic>{};
    final lines = match.group(1)!.split('\n');
    for (final line in lines) {
      if (line.contains('📊') && line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].replaceFirst('📊', '').trim();
          final value = parts.sublist(1).join(':').trim();
          stats[key] = value;
        }
      } else if (line.contains(':') && !line.startsWith('【')) {
        final colonIndex = line.indexOf(':');
        if (colonIndex > 0) {
          final key = line.substring(0, colonIndex).trim();
          final value = line.substring(colonIndex + 1).trim();
          if (key.isNotEmpty && value.isNotEmpty) {
            stats[key] = value;
          }
        }
      }
    }
    return stats;
  }

  List<String> _parseSuggestions(String response) {
    final regex = RegExp(r'【专属建议】\s*([\s\S]*?)(?=【|```json|$)');
    final match = regex.firstMatch(response);
    if (match == null) return [];

    return match.group(1)!
        .split('\n')
        .where((line) => line.trim().startsWith('✨') || line.trim().startsWith('-'))
        .map((line) {
          if (line.trim().startsWith('✨')) {
            return line.replaceFirst('✨', '').trim();
          }
          return line.replaceFirst(RegExp(r'^-\s*'), '').trim();
        })
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<RecommendationCard>? _parseRecommendations(String response) {
    final regex = RegExp(r'```json\s*(\{[\s\S]*?\})\s*```');
    final match = regex.firstMatch(response);
    if (match == null) return null;

    try {
      final json = jsonDecode(match.group(1)!);
      final cards = json['recommendations'] as List?;
      if (cards == null) return null;
      return cards
          .map((c) => RecommendationCard.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  String extractJsonFromResponse(String response) {
    final regex = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final match = regex.firstMatch(response);
    if (match != null) {
      return match.group(1)!;
    }
    return '';
  }
}
