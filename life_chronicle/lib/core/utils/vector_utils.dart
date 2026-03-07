import 'dart:typed_data';

double cosineSimilarity(List<double> a, List<double> b) {
  if (a.length != b.length) {
    throw ArgumentError('Vectors must have the same dimension');
  }

  double dotProduct = 0;
  double normA = 0;
  double normB = 0;

  for (int i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }

  final denominator = (normA * normB);
  if (denominator == 0) return 0;

  return dotProduct / denominator;
}

List<({String id, double similarity})> batchCosineSimilarity(
  List<double> query,
  List<({String id, List<double> vector})> candidates, {
  int? limit,
}) {
  final results = <({String id, double similarity})>[];

  for (final candidate in candidates) {
    final sim = cosineSimilarity(query, candidate.vector);
    results.add((id: candidate.id, similarity: sim));
  }

  results.sort((a, b) => b.similarity.compareTo(a.similarity));

  if (limit != null && results.length > limit) {
    return results.sublist(0, limit);
  }

  return results;
}

Uint8List vectorToBlob(List<double> vector) {
  final float32List = Float32List.fromList(vector);
  return float32List.buffer.asUint8List();
}

List<double> blobToVector(Uint8List blob) {
  final float32List = Float32List.view(blob.buffer);
  return float32List.toList();
}

List<double> blobToVectorFromList(List<int> blob) {
  final uint8List = Uint8List.fromList(blob);
  return blobToVector(uint8List);
}
