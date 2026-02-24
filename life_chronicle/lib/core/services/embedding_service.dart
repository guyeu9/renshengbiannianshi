import 'package:life_chronicle/core/database/app_database.dart';

abstract class EmbeddingServiceBase {
  final AiProvider provider;
  
  EmbeddingServiceBase(this.provider);
  
  Future<List<double>> embed(String text);
  
  Future<List<List<double>>> embedBatch(List<String> texts);
  
  String getEmbeddingEndpoint();
  Map<String, String> getHeaders();
  Map<String, dynamic> buildRequestBody(String text);
}
