String maskApiKey(String apiKey) {
  if (apiKey.isEmpty) return '';
  if (apiKey.length <= 8) {
    return '****';
  }
  final prefix = apiKey.substring(0, 3);
  final suffix = apiKey.substring(apiKey.length - 4);
  return '$prefix****$suffix';
}

bool isValidApiKeyFormat(String apiKey) {
  if (apiKey.isEmpty) return false;
  final apiKeyRegex = RegExp(r'^[A-Za-z0-9_-]{8,64}$');
  return apiKeyRegex.hasMatch(apiKey);
}
