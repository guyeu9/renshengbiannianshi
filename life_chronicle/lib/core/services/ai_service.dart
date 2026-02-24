import 'dart:async';

import 'package:life_chronicle/core/database/app_database.dart';

class ChatMessage {
  final String role;
  final String content;
  
  ChatMessage({required this.role, required this.content});
  
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

abstract class AiServiceBase {
  final AiProvider provider;
  
  AiServiceBase(this.provider);
  
  Future<String> chat({
    required String systemPrompt,
    required List<ChatMessage> messages,
  });
  
  Future<String> chatStream({
    required String systemPrompt,
    required List<ChatMessage> messages,
    required void Function(String chunk) onChunk,
  });
  
  Future<List<String>> fetchModels();
  
  String getChatEndpoint();
  Map<String, String> getHeaders();
  Map<String, dynamic> buildRequestBody(String systemPrompt, List<ChatMessage> messages, {bool stream = false});
}
