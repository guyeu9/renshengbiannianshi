import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_theme.dart';
import '../../../core/router/route_navigation.dart';
import '../providers/flashback_provider.dart';

class FlashbackPage extends ConsumerWidget {
  const FlashbackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashbackAsync = ref.watch(flashbackItemsProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              '那年今日',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1F2937)),
            ),
            Text(
              '${now.month}月${now.day}日',
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF374151)),
          onPressed: () => context.pop(),
        ),
      ),
      body: flashbackAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '暂无历史记录',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '过去几年的今天还没有记录',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final groupedItems = <int, List<FlashbackItem>>{};
          for (final item in items) {
            groupedItems.putIfAbsent(item.yearsAgo, () => []).add(item);
          }

          final sortedYears = groupedItems.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedYears.length,
            itemBuilder: (context, index) {
              final yearsAgo = sortedYears[index];
              final yearItems = groupedItems[yearsAgo]!;
              final year = now.year - yearsAgo;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$year年',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$yearsAgo年前',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${yearItems.length}条记录',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...yearItems.map((item) => _FlashbackItemCard(item: item)),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('加载失败: $e', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashbackItemCard extends StatelessWidget {
  final FlashbackItem item;

  const _FlashbackItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 80,
                height: 80,
                child: item.imageUrl != null
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                    : Container(
                        color: _getTypeColor(item.type),
                        child: Icon(_getTypeIcon(item.type), color: Colors.white, size: 32),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTypeColor(item.type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getTypeName(item.type),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getTypeColor(item.type),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item.isFavorite) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.content != null && item.content!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.content!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    switch (item.type) {
      case 'food':
        RouteNavigation.goToFoodDetail(context, item.recordId);
        break;
      case 'moment':
        RouteNavigation.goToMomentDetail(context, item.recordId);
        break;
      case 'travel':
        RouteNavigation.goToTravelDetail(context, item.recordId);
        break;
      case 'goal':
        RouteNavigation.goToGoalDetail(context, item.recordId);
        break;
      case 'encounter':
        RouteNavigation.goToEncounterDetail(context, item.recordId);
        break;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'food':
        return Colors.orange;
      case 'moment':
        return const Color(0xFF4ADE80);
      case 'travel':
        return Colors.purple;
      case 'goal':
        return const Color(0xFFA855F7);
      case 'encounter':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'food':
        return Icons.restaurant;
      case 'moment':
        return Icons.auto_awesome;
      case 'travel':
        return Icons.airplanemode_active;
      case 'goal':
        return Icons.outlined_flag;
      case 'encounter':
        return Icons.people;
      default:
        return Icons.event;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'food':
        return '美食';
      case 'moment':
        return '小确幸';
      case 'travel':
        return '旅行';
      case 'goal':
        return '目标';
      case 'encounter':
        return '相遇';
      default:
        return type;
    }
  }
}
