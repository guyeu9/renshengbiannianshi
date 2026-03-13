import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:life_chronicle/core/services/ai_service.dart';
import 'package:life_chronicle/core/services/embedding_service.dart';
import '../file_logger.dart';

class OpenAiCompatibleService extends AiServiceBase {
  OpenAiCompatibleService(super.provider, {http.Client? client})
      : _client = client ?? http.Client();
  
  final http.Client _client;
  bool _disposed = false;

  void dispose() {
    if (!_disposed) {
      _client.close();
      _disposed = true;
    }
  }

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('OpenAiCompatibleService has been disposed');
    }
  }

  String _normalizeBaseUrl() {
    var base = provider.baseUrl.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (base.endsWith('/v1')) {
      base = base.substring(0, base.length - 3);
    }
    return base;
  }
  
  @override
  String getChatEndpoint() {
    final base = _normalizeBaseUrl();
    return '$base/v1/chat/completions';
  }
  
  @override
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${provider.apiKey}',
    };
  }
  
  @override
  Map<String, dynamic> buildRequestBody(String systemPrompt, List<ChatMessage> messages, {bool stream = false}) {
    return {
      'model': provider.modelName ?? 'gpt-3.5-turbo',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((m) => m.toJson()),
      ],
      'stream': stream,
    };
  }
  
  @override
  Future<String> chat({
    required String systemPrompt,
    required List<ChatMessage> messages,
  }) async {
    await amapDebug('AI服务', '发送请求: model=${provider.modelName}, messages=${messages.length}');
    try {
      final response = await _client.post(
        Uri.parse(getChatEndpoint()),
        headers: getHeaders(),
        body: jsonEncode(buildRequestBody(systemPrompt, messages)),
      );
      
      if (response.statusCode != 200) {
        await amapError('AI服务', 'API错误: ${response.statusCode} - ${response.body}');
        final errorBody = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
        throw Exception('AI服务请求失败 (${response.statusCode}): $errorBody');
      }
      
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        await amapError('AI服务', 'AI返回格式错误');
        throw Exception('AI服务返回格式错误');
      }
      final choices = data['choices'];
      if (choices is! List || choices.isEmpty) {
        await amapError('AI服务', 'AI返回空响应');
        throw Exception('AI服务返回空响应，请检查模型配置');
      }
      final firstChoice = choices.first;
      if (firstChoice is! Map<String, dynamic>) {
        await amapError('AI服务', 'AI返回格式错误');
        throw Exception('AI服务返回格式错误');
      }
      final message = firstChoice['message'];
      if (message is! Map<String, dynamic>) {
        await amapError('AI服务', 'AI返回格式错误');
        throw Exception('AI服务返回格式错误');
      }
      final content = message['content'];
      if (content is! String) {
        await amapError('AI服务', 'AI返回格式错误');
        throw Exception('AI服务返回格式错误');
      }
      await amapDebug('AI服务', '请求成功, 响应长度: ${content.length}');
      return content;
    } catch (e, stack) {
      await amapError('AI服务', '请求异常: $e\n$stack');
      rethrow;
    }
  }
  
  @override
  Future<String> chatStream({
    required String systemPrompt,
    required List<ChatMessage> messages,
    required void Function(String chunk) onChunk,
  }) async {
    final request = http.Request('POST', Uri.parse(getChatEndpoint()));
    request.headers.addAll(getHeaders());
    request.body = jsonEncode(buildRequestBody(systemPrompt, messages, stream: true));
    
    final response = await _client.send(request);
    
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      final errorBody = body.length > 200 ? '${body.substring(0, 200)}...' : body;
      throw Exception('AI服务请求失败 (${response.statusCode}): $errorBody');
    }
    
    final stream = response.stream.transform(utf8.decoder);
    var fullContent = '';
    
    await for (final line in stream.transform(const LineSplitter())) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6);
        if (data == '[DONE]') break;
        
        try {
          final json = jsonDecode(data);
          if (json is Map<String, dynamic>) {
            final choices = json['choices'];
            if (choices is List && choices.isNotEmpty) {
              final firstChoice = choices.first;
              if (firstChoice is Map<String, dynamic>) {
                final delta = firstChoice['delta'];
                if (delta is Map<String, dynamic>) {
                  final content = delta['content'];
                  if (content is String) {
                    fullContent += content;
                    onChunk(content);
                  }
                }
              }
            }
          }
        } catch (e) {
          debugPrint('解析流式响应行失败: $e');
        }
      }
    }
    
    return fullContent;
  }
  
  @override
  Future<List<String>> fetchModels() async {
    final base = _normalizeBaseUrl();
    final response = await _client.get(
      Uri.parse('$base/v1/models'),
      headers: getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch models: ${response.statusCode}');
    }
    
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) return [];
    final models = data['data'];
    if (models is! List) return [];
    return models
        .map((m) {
          if (m is Map<String, dynamic>) {
            final id = m['id'];
            if (id is String) return id;
          }
          return null;
        })
        .whereType<String>()
        .toList();
  }
}

class OpenAiCompatibleEmbeddingService extends EmbeddingServiceBase {
  OpenAiCompatibleEmbeddingService(super.provider, {http.Client? client})
      : _client = client ?? http.Client();
  
  final http.Client _client;
  bool _disposed = false;

  void dispose() {
    if (!_disposed) {
      _client.close();
      _disposed = true;
    }
  }

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('OpenAiCompatibleEmbeddingService has been disposed');
    }
  }
  
  static const List<String> _fallbackModels = [
    'Qwen3-Embedding-8B',
    'Qwen3-Embedding-4B',
    'Qwen3-Embedding-0.6B',
    'jina-embeddings-v4',
    'bge-m3',
  ];

  String _normalizeBaseUrl() {
    var base = provider.baseUrl.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (base.endsWith('/v1')) {
      base = base.substring(0, base.length - 3);
    }
    return base;
  }
  
  @override
  String getEmbeddingEndpoint() {
    final base = _normalizeBaseUrl();
    return '$base/v1/embeddings';
  }
  
  @override
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${provider.apiKey}',
    };
  }
  
  @override
  Map<String, dynamic> buildRequestBody(String text) {
    return {
      'model': provider.modelName ?? 'text-embedding-3-small',
      'input': text,
    };
  }
  
  Future<List<double>> _tryEmbedWithModel(String model, String text) async {
    final response = await _client.post(
      Uri.parse(getEmbeddingEndpoint()),
      headers: getHeaders(),
      body: jsonEncode({
        'model': model,
        'input': text,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Embedding API error: ${response.statusCode}');
    }
    
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) return [];
    final dataList = data['data'];
    if (dataList is! List || dataList.isEmpty) return [];
    final first = dataList.first;
    if (first is! Map<String, dynamic>) return [];
    final embedding = first['embedding'];
    if (embedding is! List) return [];
    return embedding.cast<double>();
  }
  
  @override
  Future<List<double>> embed(String text) async {
    final originalModel = provider.modelName ?? 'Qwen3-Embedding-8B';
    List<String> modelsToTry = [originalModel];
    
    if (provider.baseUrl.contains('ai.gitee.com')) {
      for (final model in _fallbackModels) {
        if (!modelsToTry.contains(model)) {
          modelsToTry.add(model);
        }
      }
    }
    
    for (final model in modelsToTry) {
      try {
        return await _tryEmbedWithModel(model, text);
      } catch (e) {
        if (model == modelsToTry.last) {
          rethrow;
        }
      }
    }
    
    throw Exception('All embedding models failed');
  }
  
  Future<List<List<double>>> _tryEmbedBatchWithModel(String model, List<String> texts) async {
    final response = await _client.post(
      Uri.parse(getEmbeddingEndpoint()),
      headers: getHeaders(),
      body: jsonEncode({
        'model': model,
        'input': texts,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Embedding API error: ${response.statusCode}');
    }
    
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) return [];
    final embeddings = data['data'];
    if (embeddings is! List) return [];
    return embeddings.map((e) {
      if (e is Map<String, dynamic>) {
        final emb = e['embedding'];
        if (emb is List) {
          return emb.cast<double>();
        }
      }
      return <double>[];
    }).toList();
  }
  
  @override
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    final originalModel = provider.modelName ?? 'Qwen3-Embedding-8B';
    List<String> modelsToTry = [originalModel];
    
    if (provider.baseUrl.contains('ai.gitee.com')) {
      for (final model in _fallbackModels) {
        if (!modelsToTry.contains(model)) {
          modelsToTry.add(model);
        }
      }
    }
    
    for (final model in modelsToTry) {
      try {
        return await _tryEmbedBatchWithModel(model, texts);
      } catch (e) {
        if (model == modelsToTry.last) {
          rethrow;
        }
      }
    }
    
    throw Exception('All embedding models failed');
  }
}
