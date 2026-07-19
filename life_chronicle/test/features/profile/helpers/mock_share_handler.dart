import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockShareHandler {
  String? lastSharedText;
  String? lastSharedSubject;
  static const _channel = MethodChannel('dev.fluttercommunity.plus/share');

  void register() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (MethodCall call) async {
      if (call.method == 'share') {
        final args = call.arguments as Map?;
        lastSharedText = args?['text'] as String?;
        lastSharedSubject = args?['subject'] as String?;
      }
      return null;
    });
  }

  void unregister() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }

  void reset() {
    lastSharedText = null;
    lastSharedSubject = null;
  }
}
