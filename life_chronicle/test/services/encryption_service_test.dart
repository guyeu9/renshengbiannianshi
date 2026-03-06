import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/services/backup/encryption_service.dart';
import 'package:path/path.dart' as path;

void main() {
  group('EncryptionService', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('encryption_test_');
    });

    tearDownAll(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('generateSalt', () {
      test('should generate salt of correct length', () {
        final salt = EncryptionService.generateSalt();
        expect(salt.length, equals(EncryptionService.saltLength));
      });

      test('should generate different salts each time', () {
        final salt1 = EncryptionService.generateSalt();
        final salt2 = EncryptionService.generateSalt();
        expect(salt1, isNot(equals(salt2)));
      });
    });

    group('deriveKey', () {
      test('should derive key of correct length', () {
        final salt = EncryptionService.generateSalt();
        final key = EncryptionService.deriveKey('test_password', salt);
        expect(key.length, equals(EncryptionService.keyLength));
      });

      test('should derive same key for same password and salt', () {
        final salt = EncryptionService.generateSalt();
        final key1 = EncryptionService.deriveKey('test_password', salt);
        final key2 = EncryptionService.deriveKey('test_password', salt);
        expect(key1, equals(key2));
      });

      test('should derive different keys for different passwords', () {
        final salt = EncryptionService.generateSalt();
        final key1 = EncryptionService.deriveKey('password1', salt);
        final key2 = EncryptionService.deriveKey('password2', salt);
        expect(key1, isNot(equals(key2)));
      });

      test('should derive different keys for different salts', () {
        final salt1 = EncryptionService.generateSalt();
        final salt2 = EncryptionService.generateSalt();
        final key1 = EncryptionService.deriveKey('test_password', salt1);
        final key2 = EncryptionService.deriveKey('test_password', salt2);
        expect(key1, isNot(equals(key2)));
      });
    });

    group('computeSha256', () {
      test('should compute correct SHA256 hash', () {
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        final hash = EncryptionService.computeSha256(data);
        expect(hash.length, equals(32));
      });

      test('should produce same hash for same input', () {
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        final hash1 = EncryptionService.computeSha256(data);
        final hash2 = EncryptionService.computeSha256(data);
        expect(hash1, equals(hash2));
      });

      test('should produce different hash for different input', () {
        final data1 = Uint8List.fromList([1, 2, 3, 4, 5]);
        final data2 = Uint8List.fromList([5, 4, 3, 2, 1]);
        final hash1 = EncryptionService.computeSha256(data1);
        final hash2 = EncryptionService.computeSha256(data2);
        expect(hash1, isNot(equals(hash2)));
      });
    });

    group('encryptFile and decryptFile', () {
      test('should encrypt and decrypt file correctly', () async {
        final testContent = 'Hello, this is a test file content!';
        final inputFile = File(path.join(tempDir.path, 'test_input.txt'));
        await inputFile.writeAsString(testContent);

        final encryptedFile = await EncryptionService.encryptFile(
          inputFile,
          'test_password',
        );

        expect(await encryptedFile.exists(), isTrue);
        expect(encryptedFile.path, endsWith('.enc'));

        final encryptedContent = await encryptedFile.readAsBytes();
        expect(encryptedContent.length, greaterThan(testContent.length));

        final decryptedFile = await EncryptionService.decryptFile(
          encryptedFile,
          'test_password',
        );

        expect(await decryptedFile.exists(), isTrue);
        expect(decryptedFile.path, equals(inputFile.path));

        final decryptedContent = await decryptedFile.readAsString();
        expect(decryptedContent, equals(testContent));

        await inputFile.delete();
        await encryptedFile.delete();
      });

      test('should throw exception for wrong password', () async {
        final testContent = 'Secret content';
        final inputFile = File(path.join(tempDir.path, 'test_wrong_pass.txt'));
        await inputFile.writeAsString(testContent);

        final encryptedFile = await EncryptionService.encryptFile(
          inputFile,
          'correct_password',
        );

        expect(
          () => EncryptionService.decryptFile(encryptedFile, 'wrong_password'),
          throwsA(anyOf(isA<Exception>(), isA<ArgumentError>())),
        );

        await inputFile.delete();
        await encryptedFile.delete();
      });

      test('should encrypt to custom output path', () async {
        final testContent = 'Custom path test';
        final inputFile = File(path.join(tempDir.path, 'custom_input.txt'));
        await inputFile.writeAsString(testContent);

        final customOutputPath = path.join(tempDir.path, 'custom_output.enc');
        final encryptedFile = await EncryptionService.encryptFile(
          inputFile,
          'test_password',
          outputPath: customOutputPath,
        );

        expect(encryptedFile.path, equals(customOutputPath));

        await inputFile.delete();
        await encryptedFile.delete();
      });
    });

    group('createZipArchive and extractZipArchive', () {
      test('should create and extract zip archive correctly', () async {
        final testFiles = <File>[];
        for (int i = 0; i < 3; i++) {
          final file = File(path.join(tempDir.path, 'test_file_$i.txt'));
          await file.writeAsString('Content $i');
          testFiles.add(file);
        }

        final jsonData = {
          'version': '1.0',
          'timestamp': DateTime.now().toIso8601String(),
          'records': [
            {'id': '1', 'name': 'Test 1'},
            {'id': '2', 'name': 'Test 2'},
          ],
        };

        final zipPath = path.join(tempDir.path, 'test_archive.zip');
        final zipFile = await EncryptionService.createZipArchive(
          testFiles,
          jsonData,
          zipPath,
        );

        expect(await zipFile.exists(), isTrue);
        expect(zipFile.path, equals(zipPath));

        final extractDir = path.join(tempDir.path, 'extracted');
        final (extractedJson, extractedFiles) = await EncryptionService.extractZipArchive(
          zipFile,
          extractDir,
        );

        expect(extractedJson, isNotNull);
        expect(extractedJson['version'], equals('1.0'));
        expect(extractedJson['records'], isA<List>());
        expect(extractedFiles.length, equals(3));

        for (final file in testFiles) {
          await file.delete();
        }
        await zipFile.delete();
        await Directory(extractDir).delete(recursive: true);
      });

      test('should throw exception when data.json not found', () async {
        final emptyZipPath = path.join(tempDir.path, 'empty.zip');
        final emptyZipFile = File(emptyZipPath);

        await emptyZipFile.writeAsBytes([80, 75, 5, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

        final extractDir = path.join(tempDir.path, 'empty_extract');
        expect(
          () => EncryptionService.extractZipArchive(emptyZipFile, extractDir),
          throwsA(isA<Exception>()),
        );

        await emptyZipFile.delete();
      });
    });
  });
}
