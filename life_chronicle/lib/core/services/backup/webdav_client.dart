import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class WebDavFile {
  final String name;
  final String path;
  final int? size;
  final DateTime? lastModified;
  final bool isDirectory;

  WebDavFile({
    required this.name,
    required this.path,
    this.size,
    this.lastModified,
    this.isDirectory = false,
  });

  factory WebDavFile.fromDavXml(Map<String, dynamic> xml) {
    return WebDavFile(
      name: xml['name'] as String,
      path: xml['path'] as String,
      size: xml['size'] as int?,
      lastModified: xml['lastModified'] as DateTime?,
      isDirectory: xml['isDirectory'] as bool? ?? false,
    );
  }
}

class WebDavClient {
  final String baseUrl;
  final String username;
  final String password;
  final http.Client _client;

  WebDavClient({
    required this.baseUrl,
    required this.username,
    required this.password,
    http.Client? client,
  }) : _client = client ?? http.Client();

  String get _basicAuth => 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  Future<bool> testConnection() async {
    try {
      final response = await _client.send(
        http.Request('PROPFIND', Uri.parse(baseUrl))
          ..headers['Authorization'] = _basicAuth
          ..headers['Depth'] = '0',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  Future<List<WebDavFile>> listFiles(String path) async {
    final url = _joinUrl(baseUrl, path);
    final response = await _client.send(
      http.Request('PROPFIND', Uri.parse(url))
        ..headers['Authorization'] = _basicAuth
        ..headers['Depth'] = '1',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to list files: ${response.statusCode}');
    }

    final body = await response.stream.bytesToString();
    return _parseDavResponse(body);
  }

  Future<void> uploadFile(File localFile, String remotePath) async {
    final url = _joinUrl(baseUrl, remotePath);
    final request = http.Request('PUT', Uri.parse(url))
      ..headers['Authorization'] = _basicAuth
      ..bodyBytes = await localFile.readAsBytes();

    final response = await _client.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }

  Future<File> downloadFile(String remotePath, String localPath) async {
    final url = _joinUrl(baseUrl, remotePath);
    final response = await _client.get(
      Uri.parse(url),
      headers: {'Authorization': _basicAuth},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to download file: ${response.statusCode}');
    }

    final localFile = File(localPath);
    if (!await localFile.parent.exists()) {
      await localFile.parent.create(recursive: true);
    }
    await localFile.writeAsBytes(response.bodyBytes);
    return localFile;
  }

  Future<void> deleteFile(String remotePath) async {
    final url = _joinUrl(baseUrl, remotePath);
    final response = await _client.delete(
      Uri.parse(url),
      headers: {'Authorization': _basicAuth},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete file: ${response.statusCode}');
    }
  }

  Future<void> createDirectory(String remotePath) async {
    final url = _joinUrl(baseUrl, remotePath);
    final response = await _client.send(
      http.Request('MKCOL', Uri.parse(url))
        ..headers['Authorization'] = _basicAuth,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode != 405) {
        throw Exception('Failed to create directory: ${response.statusCode}');
      }
    }
  }

  Future<bool> exists(String remotePath) async {
    try {
      final url = _joinUrl(baseUrl, remotePath);
      final response = await _client.send(
        http.Request('PROPFIND', Uri.parse(url))
          ..headers['Authorization'] = _basicAuth
          ..headers['Depth'] = '0',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  List<WebDavFile> _parseDavResponse(String xml) {
    final files = <WebDavFile>[];
    final RegExp hrefPattern = RegExp(r'<d:href>(.*?)</d:href>');
    final RegExp displayNamePattern = RegExp(r'<d:displayname>(.*?)</d:displayname>');
    final RegExp getContentLengthPattern = RegExp(r'<d:getcontentlength>(\d+)</d:getcontentlength>');
    final RegExp getLastModifiedPattern = RegExp(r'<d:getlastmodified>(.*?)</d:getlastmodified>');
    final RegExp resourcetypePattern = RegExp(r'<d:resourcetype>(.*?)</d:resourcetype>', dotAll: true);

    final responses = xml.split('<d:response>').skip(1);
    
    for (final response in responses) {
      final hrefMatch = hrefPattern.firstMatch(response);
      final displayNameMatch = displayNamePattern.firstMatch(response);
      final sizeMatch = getContentLengthPattern.firstMatch(response);
      final lastModifiedMatch = getLastModifiedPattern.firstMatch(response);
      final resourcetypeMatch = resourcetypePattern.firstMatch(response);

      if (hrefMatch != null && displayNameMatch != null) {
        final path = hrefMatch.group(1)!;
        final name = displayNameMatch.group(1)!;
        final size = sizeMatch != null ? int.tryParse(sizeMatch.group(1)!) : null;
        final lastModified = lastModifiedMatch != null
            ? DateTime.tryParse(lastModifiedMatch.group(1)!)
            : null;
        final isDirectory = resourcetypeMatch != null &&
            resourcetypeMatch.group(1)!.contains('<d:collection/>');

        files.add(WebDavFile(
          name: name,
          path: path,
          size: size,
          lastModified: lastModified,
          isDirectory: isDirectory,
        ));
      }
    }

    return files;
  }

  String _joinUrl(String base, String path) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (base.endsWith('/')) {
      return '$base$path';
    }
    return '$base/$path';
  }

  void close() {
    _client.close();
  }
}
