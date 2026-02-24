class AiProviderTemplate {
  final String name;
  final String apiType;
  final String serviceType;
  final String baseUrl;
  final String defaultModel;

  const AiProviderTemplate({
    required this.name,
    required this.apiType,
    required this.serviceType,
    required this.baseUrl,
    required this.defaultModel,
  });
}

class AiProviderTemplates {
  static const List<AiProviderTemplate> chatTemplates = [
    AiProviderTemplate(
      name: 'DeepSeek',
      apiType: 'openai',
      serviceType: 'chat',
      baseUrl: 'https://api.deepseek.com',
      defaultModel: 'deepseek-chat',
    ),
    AiProviderTemplate(
      name: '通义千问',
      apiType: 'qwen',
      serviceType: 'chat',
      baseUrl: 'https://dashscope.aliyuncs.com/api/v1',
      defaultModel: 'qwen-turbo',
    ),
    AiProviderTemplate(
      name: 'Claude',
      apiType: 'claude',
      serviceType: 'chat',
      baseUrl: 'https://api.anthropic.com',
      defaultModel: 'claude-3-sonnet-20240229',
    ),
    AiProviderTemplate(
      name: 'Gemini',
      apiType: 'gemini',
      serviceType: 'chat',
      baseUrl: 'https://generativelanguage.googleapis.com',
      defaultModel: 'gemini-pro',
    ),
    AiProviderTemplate(
      name: '智谱 AI',
      apiType: 'openai',
      serviceType: 'chat',
      baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
      defaultModel: 'glm-4',
    ),
    AiProviderTemplate(
      name: '月之暗面',
      apiType: 'openai',
      serviceType: 'chat',
      baseUrl: 'https://api.moonshot.cn',
      defaultModel: 'moonshot-v1-8k',
    ),
  ];

  static const List<AiProviderTemplate> embeddingTemplates = [
    AiProviderTemplate(
      name: 'OpenAI Embedding',
      apiType: 'openai',
      serviceType: 'embedding',
      baseUrl: 'https://api.openai.com',
      defaultModel: 'text-embedding-3-small',
    ),
    AiProviderTemplate(
      name: 'BGE-M3',
      apiType: 'bge',
      serviceType: 'embedding',
      baseUrl: 'https://api.bge-model.com',
      defaultModel: 'bge-m3',
    ),
  ];
}
