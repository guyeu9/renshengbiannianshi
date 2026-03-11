import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../app/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/providers/ai_provider.dart';
import '../../../core/services/ai_service.dart' as ai_service;
import '../../../core/router/route_navigation.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import '../config/module_configs.dart';
import '../models/module_chat_params.dart';
import '../models/quick_action_config.dart';
import '../models/stats_data.dart';
import '../services/context_builder.dart';
import '../services/record_retriever.dart';
import '../services/prompt_builder.dart';
import '../services/stats_calculator.dart';

enum MessageRole { user, assistant }

class RecommendationCard {
  final String type;
  final String id;
  final String title;
  final String? summary;
  final String? imageUrl;
  final double? rating;
  final List<String>? tags;
  final String? date;
  final bool? isFavorite;

  RecommendationCard({
    required this.type,
    required this.id,
    required this.title,
    this.summary,
    this.imageUrl,
    this.rating,
    this.tags,
    this.date,
    this.isFavorite,
  });

  factory RecommendationCard.fromJson(Map<String, dynamic> json) {
    return RecommendationCard(
      type: json['type'] ?? '',
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'],
      imageUrl: json['imageUrl'],
      rating: json['rating']?.toDouble(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      date: json['date'],
      isFavorite: json['isFavorite'],
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
  final ModuleChatParams? moduleParams;

  const AiHistorianChatPage({
    super.key,
    this.moduleParams,
  });

  bool get isModuleMode => moduleParams != null;
  bool get isDetailMode => moduleParams?.isDetailMode ?? false;

  @override
  ConsumerState<AiHistorianChatPage> createState() => _AiHistorianChatPageState();
}

class _AiHistorianChatPageState extends ConsumerState<AiHistorianChatPage> {
  final _promptBuilder = PromptBuilder();
  final _statsCalculator = StatsCalculator();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _errorMessage;
  int _totalRecords = 0;
  Map<String, int> _recordStats = {};
  String? _currentSessionId;
  final List<ChatMessageModel> _messages = [];
  bool _showSessionDrawer = false;
  bool _isInitialized = false;
  bool _fullData = true;
  String? _userAvatarPath;
  
  StatsData? _moduleStats;
  List<RecordContext> _moduleRecords = [];
  List<QuickActionConfig> _quickActions = [];
  static const _defaultAvatarUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBbKe_aCd46pUms7LLAFzD6OXtQ8lCfAXJOsCrBecRIq0Rsb6hG4jY_titPPL6OX4UEolhRaXIm5q1CN8mgX1sDnDEpjIu6VsAPEPXD_TgVO70SfpWy3Ip2I0CsCyMuTYopG68o1H3zfeCTGnhMwcli29GRkYeNRSh_bne4ffgw7Lym8TRcy9xvfIRJ7re4r_AZ6HYWFXuNljbmovvrN8K3yGjv8iiZ5MCKo2rG0vQcYlScRiJTep-ftfRgTq7kF_pycqvsKRxWyfNh';

  @override
  void initState() {
    super.initState();
    if (widget.isModuleMode) {
      _loadModuleData();
    } else {
      _loadRecordStats();
    }
    _initializeSession();
    _loadUserAvatar();
  }

  Future<void> _loadModuleData() async {
    final moduleType = widget.moduleParams!.moduleType;
    final config = getModuleConfig(moduleType);
    
    if (config != null) {
      _quickActions = config.quickActions;
    }
    
    final db = ref.read(appDatabaseProvider);
    final retriever = RecordRetriever(db);
    
    if (widget.isDetailMode && widget.moduleParams!.recordIds != null) {
      final recordId = widget.moduleParams!.recordIds!.first;
      final record = await retriever.fetchRecordById(moduleType, recordId);
      if (record != null) {
        _moduleRecords = [record];
      }
    } else {
      _moduleRecords = await retriever.retrieveRecords(
        queryType: QueryType.summary,
        userQuery: '',
        module: moduleType,
        fullData: widget.moduleParams!.fullData,
      );
    }
    
    _moduleStats = await _calculateModuleStats(moduleType, _moduleRecords);
    _totalRecords = _moduleRecords.length;
    
    setState(() {});
  }

  Future<StatsData> _calculateModuleStats(String moduleType, List<RecordContext> records) async {
    switch (moduleType) {
      case 'food':
        return await _statsCalculator.calculateFoodStats(records);
      case 'travel':
        return await _statsCalculator.calculateTravelStats(records);
      case 'moment':
        return await _statsCalculator.calculateMomentStats(records);
      case 'goal':
        return await _statsCalculator.calculateGoalStats(records);
      case 'bond':
        final friendRecords = records.where((r) => r.type == '朋友').toList();
        final encounterRecords = records.where((r) => r.type == '相遇').toList();
        return await _statsCalculator.calculateBondStats(friendRecords, encounterRecords);
      default:
        return StatsData(totalRecords: records.length);
    }
  }

  Future<void> _loadUserAvatar() async {
    if (kIsWeb) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'profile', 'avatar.json'));
      if (await file.exists()) {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded['path'] is String) {
          if (mounted) {
            setState(() {
              _userAvatarPath = decoded['path'];
            });
          }
        }
      }
    } catch (_) {}
  }

  ImageProvider _avatarProvider() {
    final path = _userAvatarPath?.trim() ?? '';
    if (path.isEmpty) {
      return NetworkImage(_defaultAvatarUrl);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    final db = ref.read(appDatabaseProvider);
    
    final moduleType = widget.isModuleMode ? widget.moduleParams!.moduleType : null;
    final sessions = await db.chatDao.getActiveSessionsByModuleType(moduleType);

    if (sessions.isEmpty) {
      await _createNewSession();
    } else {
      _currentSessionId = sessions.first.id;
      await _loadSessionMessages(_currentSessionId!);
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _createNewSession() async {
    final db = ref.read(appDatabaseProvider);
    const uuid = Uuid();
    final now = DateTime.now();
    final sessionId = uuid.v4();

    await db.chatDao.upsertSession(ChatSessionsCompanion(
      id: Value(sessionId),
      title: const Value('新对话'),
      moduleType: Value(widget.isModuleMode ? widget.moduleParams!.moduleType : null),
      createdAt: Value(now),
      updatedAt: Value(now),
      lastMessageAt: Value(now),
    ));

    setState(() {
      _currentSessionId = sessionId;
      _messages.clear();
    });

    _addWelcomeMessage();
  }

  Future<void> _loadSessionMessages(String sessionId) async {
    final db = ref.read(appDatabaseProvider);
    final messages = await db.chatDao.getMessagesBySessionId(sessionId);

    setState(() {
      _messages.clear();
      for (final msg in messages) {
        final recommendations = <RecommendationCard>[];
        if (msg.recommendations != null && msg.recommendations!.isNotEmpty) {
          try {
            final json = jsonDecode(msg.recommendations!) as List;
            recommendations.addAll(
              json.map((e) => RecommendationCard.fromJson(e as Map<String, dynamic>)),
            );
          } catch (e) {
            debugPrint('Failed to parse recommendations: $e');
          }
        }
        _messages.add(ChatMessageModel(
          id: msg.id,
          role: msg.role == 'user' ? MessageRole.user : MessageRole.assistant,
          content: msg.content,
          timestamp: msg.timestamp,
          recommendations: recommendations,
        ));
      }
    });

    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  Future<void> _switchSession(String sessionId) async {
    _currentSessionId = sessionId;
    await _loadSessionMessages(sessionId);
    setState(() {
      _showSessionDrawer = false;
    });
    _scrollToBottom();
  }

  Future<void> _saveMessage(ChatMessageModel message) async {
    if (_currentSessionId == null) return;

    final db = ref.read(appDatabaseProvider);
    final recommendationsJson = message.recommendations.isNotEmpty
        ? jsonEncode(message.recommendations.map((r) => {
              'type': r.type,
              'id': r.id,
              'title': r.title,
              'summary': r.summary,
              'imageUrl': r.imageUrl,
            }).toList())
        : null;

    await db.chatDao.upsertMessage(ChatMessagesCompanion(
      id: Value(message.id),
      sessionId: Value(_currentSessionId!),
      role: Value(message.role == MessageRole.user ? 'user' : 'assistant'),
      content: Value(message.content),
      recommendations: Value(recommendationsJson),
      timestamp: Value(message.timestamp),
      createdAt: Value(DateTime.now()),
    ));

    await db.chatDao.updateSessionLastMessageAt(_currentSessionId!, now: DateTime.now());
    
    if (message.role == MessageRole.user) {
      await _updateSessionTitle(message.content);
    }
  }

  Future<void> _updateSessionTitle(String firstUserMessage) async {
    if (_currentSessionId == null) return;
    
    final db = ref.read(appDatabaseProvider);
    final session = await db.chatDao.findSessionById(_currentSessionId!);
    
    if (session != null && session.title == '新对话') {
      final title = _generateSessionTitle(firstUserMessage);
      
      await db.chatDao.updateSessionTitle(_currentSessionId!, title, now: DateTime.now());
    }
  }

  String _generateSessionTitle(String userMessage) {
    String title = userMessage.trim();
    
    if (title.length > 20) {
      final sentences = title.split(RegExp(r'[。！？\n]'));
      if (sentences.isNotEmpty && sentences.first.length <= 20) {
        title = sentences.first;
      } else {
        title = '${title.substring(0, 20)}...';
      }
    }
    
    title = title.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    title = title.replaceAll(RegExp(r'[#*`\[\]{}]'), '');
    title = title.trim();
    
    if (title.isEmpty) {
      title = '新对话';
    }
    
    return title;
  }

  Future<void> _deleteSession(String sessionId) async {
    final db = ref.read(appDatabaseProvider);
    await db.chatDao.softDeleteSession(sessionId, now: DateTime.now());

    if (_currentSessionId == sessionId) {
      await _initializeSession();
    }
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
    String content;
    
    if (widget.isModuleMode) {
      final moduleName = widget.moduleParams!.moduleName;
      if (widget.isDetailMode) {
        content = '你好！我是你的AI史官。我已加载这条$moduleName记录的详细信息，让我帮你分析它吧！';
      } else {
        content = '你好！我是你的AI史官。我已加载你的$moduleName档案，共$_totalRecords条记录。让我帮你深入分析你的$moduleName数据吧！';
      }
    } else {
      content = '你好！我是你的 AI 史官。我已经阅读了你的人生档案，包含 $_totalRecords 条记录。今天你想回顾哪段记忆？';
    }
    
    final welcomeMessage = ChatMessageModel(
      id: 'welcome_${now.millisecondsSinceEpoch}',
      role: MessageRole.assistant,
      content: content,
      timestamp: now,
    );
    setState(() {
      _messages.add(welcomeMessage);
    });
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
    if (text.isEmpty || _isLoading || _currentSessionId == null) return;

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
    await _saveMessage(userMessage);

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
      String systemPrompt;
      
      if (widget.isModuleMode) {
        systemPrompt = _promptBuilder.buildPrompt(
          moduleType: widget.moduleParams!.moduleType,
          moduleName: widget.moduleParams!.moduleName,
          stats: _moduleStats ?? StatsData(totalRecords: _totalRecords),
          records: _moduleRecords,
          question: text,
          analysisType: widget.moduleParams?.analysisType,
        );
      } else {
        final db = ref.read(appDatabaseProvider);
        final contextBuilder = ContextBuilder(db);
        
        systemPrompt = await contextBuilder.buildSystemPrompt(
          userQuery: text,
          recordStats: _recordStats,
          totalRecords: _totalRecords,
          fullData: _fullData,
        );
      }

      final history = _messages
          .where((m) => m.id != aiMessageId)
          .where((m) => !m.id.startsWith('welcome_'))
          .map((m) => ai_service.ChatMessage(
                role: m.role == MessageRole.user ? 'user' : 'assistant',
                content: m.content,
              ))
          .toList();

      final fullContent = await chatService.chatStream(
        systemPrompt: systemPrompt,
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
        final finalMessage = _messages[index].copyWith(
          content: cleanContent,
          isStreaming: false,
          recommendations: recommendations,
        );
        setState(() {
          _messages[index] = finalMessage;
        });
        await _saveMessage(finalMessage);
      }
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == aiMessageId);
      if (index != -1) {
        final finalMessage = _messages[index].copyWith(
          content: '抱歉，我遇到了一些问题：$e',
          isStreaming: false,
        );
        setState(() {
          _messages[index] = finalMessage;
        });
        await _saveMessage(finalMessage);
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

  Future<void> _sendQuickMessageWithContext(String actionType, String displayMessage) async {
    if (_isLoading || _currentSessionId == null) return;
    
    setState(() {
      _errorMessage = null;
    });

    final userMessage = ChatMessageModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      content: displayMessage,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _scrollToBottom();
    await _saveMessage(userMessage);

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
      String systemPrompt;
      
      if (widget.isModuleMode) {
        systemPrompt = _promptBuilder.buildPrompt(
          moduleType: widget.moduleParams!.moduleType,
          moduleName: widget.moduleParams!.moduleName,
          stats: _moduleStats ?? StatsData(totalRecords: _totalRecords),
          records: _moduleRecords,
          question: displayMessage,
          analysisType: actionType,
        );
      } else {
        final db = ref.read(appDatabaseProvider);
        final contextBuilder = ContextBuilder(db);
        
        final preloadedRecords = await contextBuilder.retrieveForQuickAction(actionType, fullData: _fullData);
        
        systemPrompt = await contextBuilder.buildSystemPrompt(
          userQuery: displayMessage,
          recordStats: _recordStats,
          totalRecords: _totalRecords,
          preloadedRecords: preloadedRecords,
          fullData: _fullData,
        );
      }

      final history = _messages
          .where((m) => m.id != aiMessageId)
          .where((m) => !m.id.startsWith('welcome_'))
          .map((m) => ai_service.ChatMessage(
                role: m.role == MessageRole.user ? 'user' : 'assistant',
                content: m.content,
              ))
          .toList();

      final fullContent = await chatService.chatStream(
        systemPrompt: systemPrompt,
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
        final finalMessage = _messages[index].copyWith(
          content: cleanContent,
          isStreaming: false,
          recommendations: recommendations,
        );
        setState(() {
          _messages[index] = finalMessage;
        });
        await _saveMessage(finalMessage);
      }
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == aiMessageId);
      if (index != -1) {
        final finalMessage = _messages[index].copyWith(
          content: '抱歉，我遇到了一些问题：$e',
          isStreaming: false,
        );
        setState(() {
          _messages[index] = finalMessage;
        });
        await _saveMessage(finalMessage);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
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
            onPressed: () async {
              Navigator.pop(context);
              if (_currentSessionId != null) {
                final db = ref.read(appDatabaseProvider);
                await db.chatDao.deleteMessagesBySessionId(_currentSessionId!);
              }
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
    switch (card.type) {
      case 'food':
        RouteNavigation.goToFoodDetail(context, card.id);
        break;
      case 'moment':
        RouteNavigation.goToMomentDetail(context, card.id);
        break;
      case 'travel':
        RouteNavigation.goToTravelDetail(context, card.id);
        break;
      case 'goal':
        RouteNavigation.goToGoalDetail(context, card.id);
        break;
      case 'encounter':
        RouteNavigation.goToEncounterDetail(context, card.id);
        break;
    }
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
                  onAnalytics: () => RouteNavigation.goToChronicleGenerateConfig(context),
                  onToggleSessions: () => setState(() => _showSessionDrawer = !_showSessionDrawer),
                  hasAiService: hasAiService,
                  fullData: _fullData,
                  onToggleFullData: () => setState(() => _fullData = !_fullData),
                  onGoBack: () => context.go(AppRoutes.home),
                  moduleParams: widget.moduleParams,
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
                          onPressed: () => RouteNavigation.goToAiModelManagement(context),
                          child: const Text('去配置'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      ListView.builder(
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
                                  avatarProvider: _avatarProvider(),
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
                                avatarProvider: _avatarProvider(),
                              ),
                            ],
                          );
                        },
                      ),
                      if (_showSessionDrawer)
                        _SessionDrawer(
                          currentSessionId: _currentSessionId,
                          moduleType: widget.isModuleMode ? widget.moduleParams!.moduleType : null,
                          onSessionTap: _switchSession,
                          onNewSession: _createNewSession,
                          onDeleteSession: _deleteSession,
                          onClose: () => setState(() => _showSessionDrawer = false),
                        ),
                    ],
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
            onQuickMessageWithContext: _sendQuickMessageWithContext,
            enabled: hasAiService && _isInitialized,
            quickActions: _quickActions,
            moduleParams: widget.moduleParams,
          ),
        ],
      ),
    );
  }
}

class _SessionDrawer extends ConsumerWidget {
  const _SessionDrawer({
    required this.currentSessionId,
    required this.moduleType,
    required this.onSessionTap,
    required this.onNewSession,
    required this.onDeleteSession,
    required this.onClose,
  });

  final String? currentSessionId;
  final String? moduleType;
  final void Function(String) onSessionTap;
  final VoidCallback onNewSession;
  final void Function(String) onDeleteSession;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.30),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 280,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          '对话历史',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<ChatSession>>(
                      stream: db.chatDao.watchActiveSessionsByModuleType(moduleType),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final sessions = snapshot.data!;
                        if (sessions.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text('暂无对话', style: TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: sessions.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            final isCurrent = session.id == currentSessionId;
                            return ListTile(
                              leading: Icon(
                                isCurrent ? Icons.chat_bubble : Icons.chat_bubble_outline,
                                color: isCurrent ? AppTheme.primary : Colors.grey.shade500,
                              ),
                              title: Text(
                                session.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  color: isCurrent ? AppTheme.primary : const Color(0xFF334155),
                                ),
                              ),
                              subtitle: session.lastMessageAt != null
                                  ? Text(
                                      _formatDate(session.lastMessageAt!),
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    )
                                  : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                color: Colors.grey.shade400,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('删除对话'),
                                      content: const Text('确定要删除这个对话吗？'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            onDeleteSession(session.id);
                                          },
                                          child: const Text('确定', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              onTap: () => onSessionTap(session.id),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: onNewSession,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('新对话', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} 天前';
    } else {
      return DateFormat('MM-dd').format(date);
    }
  }
}

class _AiChatTopBar extends StatelessWidget {
  const _AiChatTopBar({
    required this.onClear,
    required this.onAnalytics,
    required this.onToggleSessions,
    required this.hasAiService,
    required this.fullData,
    required this.onToggleFullData,
    required this.onGoBack,
    this.moduleParams,
  });

  final VoidCallback onClear;
  final VoidCallback onAnalytics;
  final VoidCallback onToggleSessions;
  final bool hasAiService;
  final bool fullData;
  final VoidCallback onToggleFullData;
  final VoidCallback onGoBack;
  final ModuleChatParams? moduleParams;

  @override
  Widget build(BuildContext context) {
    final title = moduleParams?.moduleName ?? 'AI 史官';
    final subtitle = moduleParams != null 
        ? '专注分析${moduleParams!.moduleName}数据'
        : (hasAiService ? '在线' : '离线 · 请配置AI服务');
    
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
                onTap: onGoBack,
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back, color: Color(0xFF475569), size: 20),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onToggleSessions,
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.menu, color: Color(0xFF475569), size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
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
                          subtitle,
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
              if (moduleParams == null) ...[
                InkWell(
                  onTap: onToggleFullData,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: fullData ? AppTheme.primary.withValues(alpha: 0.15) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: fullData ? AppTheme.primary : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          fullData ? Icons.dataset : Icons.dataset_outlined,
                          size: 16,
                          color: fullData ? AppTheme.primary : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '全量数据',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: fullData ? AppTheme.primary : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
    required this.onQuickMessageWithContext,
    required this.enabled,
    this.quickActions,
    this.moduleParams,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final void Function(String) onQuickMessage;
  final void Function(String actionType, String displayMessage) onQuickMessageWithContext;
  final bool enabled;
  final List<QuickActionConfig>? quickActions;
  final ModuleChatParams? moduleParams;

  List<Widget> _buildSuggestionChips() {
    if (quickActions != null && quickActions!.isNotEmpty) {
      return quickActions!.map((action) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _SuggestionChip(
            icon: action.icon,
            iconColor: action.iconColor,
            label: action.label,
            onTap: enabled ? () => onQuickMessageWithContext(action.analysisType, action.queryTemplate) : null,
          ),
        );
      }).toList();
    }
    
    return [
      _SuggestionChip(
        icon: Icons.mood,
        iconColor: const Color(0xFFA855F7),
        label: '总结上月心情',
        onTap: enabled ? () => onQuickMessageWithContext('mood_summary', '请帮我总结一下上个月的心情变化') : null,
      ),
      const SizedBox(width: 8),
      _SuggestionChip(
        icon: Icons.pie_chart,
        iconColor: const Color(0xFF60A5FA),
        label: '分析年度目标进度',
        onTap: enabled ? () => onQuickMessageWithContext('goal_progress', '请分析一下我今年的目标完成进度') : null,
      ),
      const SizedBox(width: 8),
      _SuggestionChip(
        icon: Icons.history,
        iconColor: const Color(0xFFFB923C),
        label: '那年今日',
        onTap: enabled ? () => onQuickMessageWithContext('on_this_day', '那年今天我做了什么？') : null,
      ),
    ];
  }

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
                        enabled 
                            ? (moduleParams != null 
                                ? '已接入：${moduleParams!.moduleName}模块数据' 
                                : '已接入：美食、旅行、小确幸等全量数据')
                            : '请先配置 AI 服务',
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
                    children: _buildSuggestionChips(),
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
    this.avatarProvider,
  });

  final ChatMessageModel message;
  final void Function(RecommendationCard)? onCardTap;
  final ImageProvider? avatarProvider;

  @override
  Widget build(BuildContext context) {
    if (message.role == MessageRole.user) {
      return _UserMessageBubble(message: message, avatarProvider: avatarProvider);
    }
    return _AiMessageBubble(message: message, onCardTap: onCardTap);
  }
}

class _UserMessageBubble extends StatelessWidget {
  const _UserMessageBubble({required this.message, this.avatarProvider});

  final ChatMessageModel message;
  final ImageProvider? avatarProvider;

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
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
          ),
          child: ClipOval(
            child: Image(
              image: avatarProvider ?? const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBbKe_aCd46pUms7LLAFzD6OXtQ8lCfAXJOsCrBecRIq0Rsb6hG4jY_titPPL6OX4UEolhRaXIm5q1CN8mgX1sDnDEpjIu6VsAPEPXD_TgVO70SfpWy3Ip2I0CsCyMuTYopG68o1H3zfeCTGnhMwcli29GRkYeNRSh_bne4ffgw7Lym8TRcy9xvfIRJ7re4r_AZ6HYWFXuNljbmovvrN8K3yGjv8iiZ5MCKo2rG0vQcYlScRiJTep-ftfRgTq7kF_pycqvsKRxWyfNh'),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppTheme.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppTheme.primary, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  const _AiMessageBubble({required this.message, this.onCardTap});

  final ChatMessageModel message;
  final void Function(RecommendationCard)? onCardTap;

  void _copyContent(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        duration: Duration(seconds: 1),
      ),
    );
  }

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
                        ] else if (message.content.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _copyContent(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.copy_outlined,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
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
