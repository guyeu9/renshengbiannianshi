// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:life_chronicle/app/app.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
    
    // Mock path_provider
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '.';
      },
    );
  });

  tearDownAll(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
  });

  testWidgets('App boots with bottom navigation', (WidgetTester tester) async {
    final db = FakeAppDatabase();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const LifeChronicleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('日程'), findsWidgets);
    expect(find.text('美食'), findsWidgets);
    expect(find.text('小确幸'), findsWidgets);
    expect(find.text('旅行'), findsWidgets);
    expect(find.text('目标'), findsWidgets);
    expect(find.text('羁绊'), findsWidgets);
  });

  test('Database upgrade recreates required tables', () async {
    final dir = await Directory.systemTemp.createTemp('life_chronicle_db_test_');
    final file = File('${dir.path}/life_chronicle_test.sqlite');

    final now = DateTime(2026, 2, 20, 12);

    final db1 = AppDatabase.connect(NativeDatabase(file));
    await db1.customStatement('DROP TABLE timeline_events');
    await db1.customStatement('DROP TABLE entity_links');
    await db1.customStatement('DROP TABLE link_logs');
    await db1.customStatement('PRAGMA user_version = 3');
    await db1.close();

    final db2 = AppDatabase.connect(NativeDatabase(file));
    await db2.into(db2.timelineEvents).insert(
          TimelineEventsCompanion.insert(
            id: 'e1',
            title: 't',
            eventType: 'moment',
            recordDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db2.into(db2.entityLinks).insert(
          EntityLinksCompanion.insert(
            id: 'l1',
            sourceType: 'moment',
            sourceId: 'e1',
            targetType: 'friend',
            targetId: 'f1',
            createdAt: now,
          ),
        );
    await db2.into(db2.linkLogs).insert(
          LinkLogsCompanion.insert(
            id: 'log1',
            sourceType: 'moment',
            sourceId: 'e1',
            targetType: 'friend',
            targetId: 'f1',
            action: 'create',
            createdAt: now,
          ),
        );
    await db2.close();

    await dir.delete(recursive: true);
  });
}

class FakeAppDatabase extends Fake implements AppDatabase {
  @override
  Stream<List<TimelineEvent>> watchEventsForDate(DateTime date) {
    return Stream.value([]);
  }

  @override
  Stream<List<TimelineEvent>> watchEventsForMonth(DateTime month) {
    return Stream.value([]);
  }

  @override
  Stream<List<TravelRecord>> watchAllActiveTravelRecords() {
    return Stream.value([]);
  }
  
  @override
  FriendDao get friendDao => FakeFriendDao();

  @override
  MomentDao get momentDao => FakeMomentDao();

  @override
  FoodDao get foodDao => FakeFoodDao();

  @override
  LinkDao get linkDao => FakeLinkDao();
  
  @override
  Future<void> close() async {}
}

class FakeFriendDao extends Fake implements FriendDao {
  @override
  Stream<List<FriendRecord>> watchAllActive() {
    return Stream.value([]);
  }
}

class FakeMomentDao extends Fake implements MomentDao {
  @override
  Stream<List<MomentRecord>> watchAllActive() {
    return Stream.value([]);
  }
}

class FakeFoodDao extends Fake implements FoodDao {
  @override
  Stream<List<FoodRecord>> watchAllActive() {
    return Stream.value([]);
  }
}

class FakeLinkDao extends Fake implements LinkDao {
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  static final Uint8List _imageBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ]);

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse(_imageBytes);
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  final Uint8List _imageBytes;

  _MockHttpClientResponse(this._imageBytes);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _imageBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([_imageBytes]).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
