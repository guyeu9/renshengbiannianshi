import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

class EncryptionService {
  static const int pbkdf2Iterations = 10000;
  static const int keyLength = 32;
  static const int ivLength = 16;
  static const int saltLength = 16;
  static const String version = '1.0';

  static Uint8List generateSalt() {
    final random = encrypt.SecureRandom(ivLength);
    return random.bytes;
  }

  static Uint8List deriveKey(String password, Uint8List salt) {
    final keyBytes = utf8.encode(password);
    final hmacSha256 = Hmac(sha256, keyBytes);
    
    Uint8List derivedKey = Uint8List(keyLength);
    Uint8List block = Uint8List(0);
    int offset = 0;
    
    while (offset < keyLength) {
      final hmac = hmacSha256.convert([
        ...block,
        ...salt,
        ...utf8.encode('$pbkdf2Iterations'),
      ]);
      block = hmac.bytes as Uint8List;
      
      final copyLength = block.length < keyLength - offset ? block.length : keyLength - offset;
      for (int i = 0; i < copyLength; i++) {
        derivedKey[offset + i] = block[i];
      }
      offset += copyLength;
    }
    
    return derivedKey;
  }

  static Uint8List computeSha256(Uint8List data) {
    final hash = sha256.convert(data);
    return Uint8List.fromList(hash.bytes);
  }

  static Future<File> encryptFile(
    File inputFile,
    String password, {
    String? outputPath,
  }) async {
    final salt = generateSalt();
    final key = deriveKey(password, salt);
    final iv = encrypt.SecureRandom(ivLength).bytes;
    
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc),
    );
    
    final inputBytes = await inputFile.readAsBytes();
    final encrypted = encrypter.encryptBytes(inputBytes, iv: encrypt.IV(iv));
    
    final checksum = computeSha256(inputBytes);
    
    final header = utf8.encode(json.encode({
      'version': version,
      'salt': base64Encode(salt),
      'iv': base64Encode(iv),
      'checksum': base64Encode(checksum),
      'timestamp': DateTime.now().toIso8601String(),
    }));
    
    final headerLengthBytes = Uint8List(4);
    headerLengthBytes.buffer.asByteData().setUint32(0, header.length, Endian.big);
    
    final outputBytes = Uint8List.fromList([
      ...headerLengthBytes,
      ...header,
      ...encrypted.bytes,
    ]);
    
    final outputFile = File(outputPath ?? '${inputFile.path}.enc');
    await outputFile.writeAsBytes(outputBytes);
    return outputFile;
  }

  static Future<File> decryptFile(
    File inputFile,
    String password, {
    String? outputPath,
  }) async {
    final inputBytes = await inputFile.readAsBytes();
    
    final headerLength = ByteData.sublistView(inputBytes, 0, 4).getUint32(0, Endian.big);
    final headerBytes = inputBytes.sublist(4, 4 + headerLength);
    final encryptedBytes = inputBytes.sublist(4 + headerLength);
    
    final header = json.decode(utf8.decode(headerBytes)) as Map<String, dynamic>;
    
    final salt = base64Decode(header['salt'] as String);
    final iv = base64Decode(header['iv'] as String);
    final expectedChecksum = base64Decode(header['checksum'] as String);
    
    final key = deriveKey(password, salt);
    
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc),
    );
    
    final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(encryptedBytes),
      iv: encrypt.IV(iv),
    );
    
    final actualChecksum = computeSha256(Uint8List.fromList(decrypted));
    if (actualChecksum.toString() != expectedChecksum.toString()) {
      throw Exception('Checksum verification failed');
    }
    
    final outputFile = File(outputPath ?? inputFile.path.replaceAll(RegExp(r'\.enc$'), ''));
    await outputFile.writeAsBytes(decrypted);
    return outputFile;
  }

  static Future<File> createZipArchive(
    List<File> files,
    Map<String, dynamic> jsonData,
    String outputPath,
  ) async {
    final archive = Archive();
    
    final jsonString = jsonEncode(jsonData);
    final jsonBytes = utf8.encode(jsonString);
    archive.addFile(ArchiveFile('data.json', jsonBytes.length, jsonBytes));
    
    for (final file in files) {
      final fileName = path.basename(file.path);
      final fileBytes = await file.readAsBytes();
      archive.addFile(ArchiveFile('media/$fileName', fileBytes.length, fileBytes));
    }
    
    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive)!;
    
    final zipFile = File(outputPath);
    await zipFile.writeAsBytes(zipBytes);
    return zipFile;
  }

  static Future<(Map<String, dynamic>, List<File>)> extractZipArchive(
    File zipFile,
    String extractDir,
  ) async {
    final zipBytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(zipBytes);
    
    final extractDirectory = Directory(extractDir);
    if (!await extractDirectory.exists()) {
      await extractDirectory.create(recursive: true);
    }
    
    Map<String, dynamic>? jsonData;
    final mediaFiles = <File>[];
    
    for (final file in archive) {
      if (file.isFile) {
        final filePath = path.join(extractDir, file.name);
        final outputFile = File(filePath);
        
        if (!await outputFile.parent.exists()) {
          await outputFile.parent.create(recursive: true);
        }
        
        await outputFile.writeAsBytes(file.content as List<int>);
        
        if (file.name == 'data.json') {
          final jsonString = await outputFile.readAsString();
          jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        } else if (file.name.startsWith('media/')) {
          mediaFiles.add(outputFile);
        }
      }
    }
    
    if (jsonData == null) {
      throw Exception('data.json not found in archive');
    }
    
    return (jsonData, mediaFiles);
  }
}
