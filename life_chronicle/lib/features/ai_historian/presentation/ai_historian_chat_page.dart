import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/app_theme.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/providers/ai_provider.dart';
import '../../../core/services/ai_service.dart';

enum MessageRole { user, assistant }

class RecommendationCard {
  final String type;
  final String id;
  final String title;
  final String? summary;
  final String? imageUrl;

  RecommendationCard({
    required this.type,
    required this.id,
    required this.title,
    this.summary,
    this.imageUrl,
  });

  factory RecommendationCard.fromJson(Map<String, dynamic> json) {
    return RecommendationCard(
      type: json['type'] ?? '',
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'],
      imageUrl: json['imageUrl'],
    );
  }
}

class ChatMessageModel {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;
  final List<RecommendationCard> recommendations;

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.recommendations = const [],
  });

  ChatMessageModel copyWith({
    String? content,
    bool? isStreaming,
    List<RecommendationCard>? recommendations,
  }) {
    return ChatMessageModel(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}

class AiHistorianChatPage extends ConsumerStatefulWidget {
  const AiHistorianChatPage({super.key});

  @override
  ConsumerState<AiHistorianChatPage> createState() => _AiHistorianChatPageState();
}

class _AiHistorianChatPageState extends ConsumerState<AiHistorianChatPage> {
  final List<ChatMessageModel> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _errorMessage;
  int _totalRecords = 0;
  Map<String, int> _recordStats = {};

  @override
  void initState() {
    super.initState();
    _loadRecordStats();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRecordStats() async {
    final db = ref.read(appDatabaseProvider);
    
    final foodCount = await (db.select(db.foodRecords)..where((t) => t.isDeleted.equals(false))).get().then((r) => r.length);
    final momentCount = await (db.select(db.momentRecords)..where((t) => t.isDeleted.equals(false))).get().then((r) => r.length);
    final travelCount = await (db.select(db.travelRecords)..where((t) => t.isDeleted.equals(false))).get().then((r) => r.length);
    final goalCount = await (db.select(db.goalRecords)..where((t) => t.isDeleted.equals(false))).get().then((r) => r.length);
    final encounterCount = await (db.select(db.timelineEvents)..where((t) => t.eventType.equals('encounter'))).get().then((r) => r.length);
    
    setState(() {
      _recordStats = {
        'food': foodCount,
        'moment': momentCount,
        'travel': travelCount,
        'goal': goalCount,
        'encounter': encounterCount,
      };
      _totalRecords = foodCount + momentCount + travelCount + goalCount + encounterCount;
    });
  }

  void _addWelcomeMessage() {
    final now = DateTime.now();
    _messages.add(ChatMessageModel(
      id: 'welcome_${now.millisecondsSinceEpoch}',
      role: MessageRole.assistant,
      content: '你好！我是你的 AI 史官。我已经阅读了你的人生档案，包含 $_totalRecords 条记录。今天你想回顾哪段记忆？',
      timestamp: now,
    ));
  }

  String _buildSystemPrompt() {
    final buffer = StringBuffer();
    buffer.writeln('你是人生编年史APP的AI史官，一个温暖、有洞察力的数字档案管理员。');
    buffer.writeln('你能够访问用户的人生记录数据，帮助用户回顾和探索他们的过去。');
    buffer.writeln('');
    buffer.writeln('## 用户数据统计');
    buffer.writeln('- 美食记录：${_recordStats['food'] ?? 0} 条');
    buffer.writeln('- 小确幸记录：${_recordStats['moment'] ?? 0} 条');
    buffer.writeln('- 旅行记录：${_recordStats['travel'] ?? 0} 条');
    buffer.writeln('- 目标记录：${_recordStats['goal'] ?? 0} 条');
    buffer.writeln('- 相遇记录：${_recordStats['encounter'] ?? 0} 条');
    buffer.writeln('- 总计：$_totalRecords 条记录');
    buffer.writeln('');
    buffer.writeln('## 回复原则');
    buffer.writeln('1. 语气温暖、有温度，像写给未来自己的一封信');
    buffer.writeln('2. 如果用户询问具体记录，尽量提供准确的时间和地点信息');
    buffer.writeln('3. 可以主动关联相关记忆，帮助用户发现隐藏的联系');
    buffer.writeln('4. 如果找不到相关记录，诚实告知并建议其他探索方向');
    buffer.writeln('5. 回复简洁明了，避免过长');
    buffer.writeln('');
    buffer.writeln('## 推荐卡片格式');
    buffer.writeln('如果你想在回复中推荐相关记录，请在回复末尾使用以下JSON格式：');
    buffer.writeln('```json');
    buffer.writeln('{"recommendations": [{"type": "food|moment|travel|goal|encounter", "id": "记录ID", "title": "标题", "summary": "简短描述"}]}');
    buffer.writeln('```');
    return buffer.toString();
  }

  List<RecommendationCard> _parseRecommendations(String content) {
    try {
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(content);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(1)!;
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final cards = json['recommendations'] as List?;
        if (cards != null) {
          return cards.map((c) => RecommendationCard.fromJson(c as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint('Failed to parse recommendations: $e');
    }
    return [];
  }

  String _removeRecommendationsJson(String content) {
    return content.replaceAll(RegExp(r'\s*```json\s*[\s\S]*?\s*```\s*'), '').trim();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _inputController.clear();
    setState(() {
      _errorMessage = null;
    });

    final userMessage = ChatMessageModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _scrollToBottom();

    final chatService = ref.read(activeChatServiceProvider);
    if (chatService == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '请先在"个人中心 > AI 模型管理"中配置 AI 服务';
      });
      return;
    }

    final aiMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _messages.add(ChatMessageModel(
        id: aiMessageId,
        role: MessageRole.assistant,
        content: '',
        timestamp: DateTime.now(),
        isStreaming: true,
      ));
    });
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => m.id != aiMessageId && m.id != 'welcome_${_messages.first.timestamp.millisecondsSinceEpoch}')
          .map((m) => ChatMessage(
                role: m.role == MessageRole.user ? 'user' : 'assistant',
                content: m.content,
              ))
          .toList();

      final fullContent = await chatService.chatStream(
        systemPrompt: _buildSystemPrompt(),
        messages: history,
        onChunk: (chunk) {
          final index = _messages.indexWhere((m) => m.id == aiMessageId);
          if (index != -1) {
            setState(() {
              _messages[index] = _messages[index].copyWith(
                content: _messages[index].content + chunk,
              );
            });
          }
        },
      );

      final index = _messages.indexWhere((m) => m.id == aiMessageId);
      if (index != -1) {
        final recommendations = _parseRecommendations(fullContent);
        final cleanContent = _removeRecommendationsJson(fullContent);
        setState(() {
          _messages[index] = _messages[index].copyWith(
            content: cleanContent,
            isStreaming: false,
            recommendations: recommendations,
          );
        });
      }
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == aiMessageId);
      if (index != -1) {
        setState(() {
          _messages[index] = _messages[index].copyWith(
            content: '抱歉，我遇到了一些问题：$e',
            isStreaming: false,
          );
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _sendQuickMessage(String message) {
    _inputController.text = message;
    _sendMessage();
  }

  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('确定要清空所有对话记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleCardTap(RecommendationCard card) {
    String route;
    switch (card.type) {
      case 'food':
        route = '/food/${card.id}';
        break;
      case 'moment':
        route = '/moment/${card.id}';
        break;
      case 'travel':
        route = '/travel/${card.id}';
        break;
      case 'goal':
        route = '/goal/${card.id}';
        break;
      case 'encounter':
        route = '/encounter/${card.id}';
        break;
      default:
        return;
    }
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final hasAiService = ref.watch(hasActiveChatProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                _AiChatTopBar(
                  onClear: _clearConversation,
                  onAnalytics: () => Navigator.of(context).pushNamed('/chronicle'),
                  hasAiService: hasAiService,
                ),
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/ai-model-management'),
                          child: const Text('去配置'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 220),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      if (index == 0) {
                        return Column(
                          children: [
                            _TimestampChip(timestamp: message.timestamp),
                            const SizedBox(height: 18),
                            _MessageBubble(
                              message: message,
                              onCardTap: _handleCardTap,
                            ),
                          ],
                        );
                      }
                      final prevMessage = _messages[index - 1];
                      final showTimestamp = message.timestamp.difference(prevMessage.timestamp).inMinutes > 5;
                      return Column(
                        children: [
                          if (showTimestamp) ...[
                            const SizedBox(height: 12),
                            _TimestampChip(timestamp: message.timestamp),
                          ],
                          const SizedBox(height: 18),
                          _MessageBubble(
                            message: message,
                            onCardTap: _handleCardTap,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _AiChatInputBar(
            controller: _inputController,
            isLoading: _isLoading,
            onSend: _sendMessage,
            onQuickMessage: _sendQuickMessage,
            enabled: hasAiService,
          ),
        ],
      ),
    );
  }
}

class _AiChatTopBar extends StatelessWidget {
  const _AiChatTopBar({
    required this.onClear,
    required this.onAnalytics,
    required this.hasAiService,
  });

  final VoidCallback onClear;
  final VoidCallback onAnalytics;
  final bool hasAiService;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 80 + MediaQuery.paddingOf(context).top,
          padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 8, 16, 12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.10),
            border: Border(
              bottom: BorderSide(color: AppTheme.primary.withValues(alpha: 0.20), width: 1),
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back_ios_new, color: Color(0xFF475569), size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI 史官',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: hasAiService ? const Color(0xFF4ADE80) : const Color(0xFFFB923C),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasAiService ? '在线 · 全量数据已挂载' : '离线 · 请配置AI服务',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onAnalytics,
                icon: const Icon(Icons.analytics, color: Color(0xFF475569)),
                splashRadius: 22,
                tooltip: '分析报告',
              ),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.delete_sweep, color: Color(0xFF475569)),
                splashRadius: 22,
                tooltip: '清空对话',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiChatInputBar extends StatelessWidget {
  const _AiChatInputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.onQuickMessage,
    required this.enabled,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final void Function(String) onQuickMessage;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.90),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dataset_linked, size: 14, color: enabled ? AppTheme.primary : const Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Text(
                        enabled ? '已接入：美食、旅行、小确幸等全量数据' : '请先配置 AI 服务',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: enabled ? AppTheme.primary : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _SuggestionChip(
                        icon: Icons.mood,
                        iconColor: const Color(0xFFA855F7),
                        label: '总结上月心情',
                        onTap: enabled ? () => onQuickMessage('请帮我总结一下上个月的心情变化') : null,
                      ),
                      const SizedBox(width: 8),
                      _SuggestionChip(
                        icon: Icons.pie_chart,
                        iconColor: const Color(0xFF60A5FA),
                        label: '分析年度目标进度',
                        onTap: enabled ? () => onQuickMessage('请分析一下我今年的目标完成进度') : null,
                      ),
                      const SizedBox(width: 8),
                      _SuggestionChip(
                        icon: Icons.history,
                        iconColor: const Color(0xFFFB923C),
                        label: '那年今日',
                        onTap: enabled ? () => onQuickMessage('那年今天我做了什么？') : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('语音输入功能开发中')),
                                );
                              },
                              icon: const Icon(Icons.mic, color: Color(0xFF94A3B8)),
                              splashRadius: 20,
                            ),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                enabled: enabled && !isLoading,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: '向史官提问，探索你的过去...',
                                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                ),
                                onSubmitted: (_) => onSend(),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('添加附件功能开发中')),
                                );
                              },
                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF94A3B8)),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: enabled ? AppTheme.primary : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: enabled
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.30),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        onPressed: enabled && !isLoading ? onSend : null,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        splashRadius: 26,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: onTap == null ? const Color(0xFFCBD5E1) : iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onTap == null ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimestampChip extends StatelessWidget {
  const _TimestampChip({required this.timestamp});

  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String text;
    if (timestamp.year == now.year && timestamp.month == now.month && timestamp.day == now.day) {
      text = DateFormat('HH:mm').format(timestamp);
    } else {
      text = DateFormat('MM-dd HH:mm').format(timestamp);
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.50),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    this.onCardTap,
  });

  final ChatMessageModel message;
  final void Function(RecommendationCard)? onCardTap;

  @override
  Widget build(BuildContext context) {
    if (message.role == MessageRole.user) {
      return _UserMessageBubble(message: message);
    }
    return _AiMessageBubble(message: message, onCardTap: onCardTap);
  }
}

class _UserMessageBubble extends StatelessWidget {
  const _UserMessageBubble({required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14).copyWith(bottomRight: const Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.20),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  message.content,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: AppTheme.primary, size: 20),
        ),
      ],
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  const _AiMessageBubble({required this.message, this.onCardTap});

  final ChatMessageModel message;
  final void Function(RecommendationCard)? onCardTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF2563EB)]),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: const Center(child: Icon(Icons.auto_stories, color: Colors.white, size: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI 史官', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14).copyWith(bottomLeft: const Radius.circular(4)),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            message.content.isEmpty && message.isStreaming ? '正在思考...' : message.content,
                            style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
                          ),
                        ),
                        if (message.isStreaming) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                          ),
                        ],
                      ],
                    ),
                    if (message.recommendations.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 12),
                      Text(
                        '相关记录',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...message.recommendations.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _RecommendationCardWidget(
                          card: card,
                          onTap: onCardTap != null ? () => onCardTap!(card) : null,
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecommendationCardWidget extends StatelessWidget {
  const _RecommendationCardWidget({
    required this.card,
    this.onTap,
  });

  final RecommendationCard card;
  final VoidCallback? onTap;

  IconData get _icon {
    switch (card.type) {
      case 'food':
        return Icons.restaurant;
      case 'moment':
        return Icons.auto_awesome;
      case 'travel':
        return Icons.flight;
      case 'goal':
        return Icons.flag;
      case 'encounter':
        return Icons.people;
      default:
        return Icons.article;
    }
  }

  Color get _color {
    switch (card.type) {
      case 'food':
        return const Color(0xFFF97316);
      case 'moment':
        return const Color(0xFFA855F7);
      case 'travel':
        return const Color(0xFF3B82F6);
      case 'goal':
        return const Color(0xFF22C55E);
      case 'encounter':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF64748B);
    }
  }

  String get _typeName {
    switch (card.type) {
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
        return '记录';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _color.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_icon, color: _color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (card.summary != null && card.summary!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      card.summary!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _typeName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _color,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
