import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'db_connection_io.dart' if (dart.library.html) 'db_connection_web.dart' as dbconn;
import 'tables.dart';
import '../services/backup/change_log_recorder.dart';
import '../services/vector_index_manager.dart';
import '../services/embedding_service.dart';

part 'app_database.g.dart';
part 'daos/food_dao.dart';
part 'daos/moment_dao.dart';
part 'daos/friend_dao.dart';
part 'daos/link_dao.dart';
part 'daos/ai_provider_dao.dart';
part 'daos/change_log_dao.dart';
part 'daos/sync_state_dao.dart';
part 'daos/checklist_dao.dart';
part 'daos/goal_postponement_dao.dart';
part 'daos/goal_review_dao.dart';
part 'daos/backup_log_dao.dart';
part 'daos/annual_review_dao.dart';
part 'daos/embedding_dao.dart';
part 'daos/travel_dao.dart';
part 'daos/goal_dao.dart';
part 'daos/chat_dao.dart';

@DriftDatabase(
  tables: [FoodRecords, MomentRecords, FriendRecords, TravelRecords, Trips, GoalRecords, TimelineEvents, EntityLinks, LinkLogs, UserProfiles, AiProviders, ChangeLogs, SyncState, ChecklistItems, GoalPostponements, GoalReviews, BackupLogs, AnnualReviews, RecordEmbeddings, ChatSessions, ChatMessages],
  daos: [FoodDao, MomentDao, FriendDao, LinkDao, AiProviderDao, ChangeLogDao, SyncStateDao, ChecklistDao, GoalPostponementDao, GoalReviewDao, BackupLogDao, AnnualReviewDao, EmbeddingDao, TravelDao, GoalDao, ChatDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(dbconn.openConnection());
  AppDatabase.connect(super.executor);

  VectorIndexManager? _vectorIndexManager;
  VectorIndexManager? get vectorIndexManager => _vectorIndexManager;

  Future<void> initializeVectorIndexManager(EmbeddingServiceBase? Function() embeddingServiceGetter) async {
    if (_vectorIndexManager != null) return;
    _vectorIndexManager = VectorIndexManager(this, embeddingServiceGetter);
    await _vectorIndexManager!.initialize();
  }

  @override
  int get schemaVersion => 27;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          
          if (details.wasCreated) {
            final now = DateTime.now();
            const uuid = Uuid();
            
            // 新用户：插入默认 embedding 服务
            await into(aiProviders).insert(
              AiProvidersCompanion(
                id: Value(uuid.v4()),
                name: const Value('模力方舟'),
                apiType: const Value('openai'),
                serviceType: const Value('embedding'),
                baseUrl: const Value('https://ai.gitee.com/v1'),
                apiKey: const Value('AAMX6RZWNFGZ9H1CERSNPTQOQSIHSR5TBTNI8Y8G'),
                modelName: const Value('Qwen3-Embedding-8B'),
                isActive: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
            
            // 新用户：插入默认 chat 服务
            await into(aiProviders).insert(
              AiProvidersCompanion(
                id: Value(uuid.v4()),
                name: const Value('默认'),
                apiType: const Value('openai'),
                serviceType: const Value('chat'),
                baseUrl: const Value('https://api.zscc.in'),
                apiKey: const Value('sk-tTHwWh4n0iWjlTRuxraXrJKx5PAjHFEdM3MhL0N2oB1Xp5oj'),
                modelName: const Value('gemini-3-flash'),
                isActive: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
          } else {
            // 老用户：确保默认服务存在
            await _ensureDefaultEmbeddingProvider();
            await _ensureDefaultChatProvider();
          }
        },
        onUpgrade: (m, from, to) async {
          Future<bool> tableExists(String name) async {
            final rows = await customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
              variables: [Variable.withString(name)],
            ).get();
            return rows.isNotEmpty;
          }

          Future<bool> columnExists(String table, String column) async {
            final rows = await customSelect('PRAGMA table_info("$table")').get();
            return rows.any((r) => r.data['name'] == column);
          }

          Future<void> ensureTable(TableInfo<Table, dynamic> table) async {
            final name = table.actualTableName;
            if (!await tableExists(name)) {
              await m.createTable(table);
            }
          }

          Future<void> ensureColumn<T extends Object>({
            required TableInfo<Table, dynamic> table,
            required GeneratedColumn<T> column,
          }) async {
            if (!await columnExists(table.actualTableName, column.name)) {
              await m.addColumn(table, column);
            }
          }

          await ensureTable(foodRecords);
          await ensureTable(momentRecords);
          await ensureTable(friendRecords);
          await ensureTable(travelRecords);
          await ensureTable(trips);
          await ensureTable(goalRecords);
          await ensureTable(timelineEvents);
          await ensureTable(entityLinks);
          await ensureTable(linkLogs);
          await ensureTable(userProfiles);

          await ensureTable(aiProviders);
          await ensureTable(changeLogs);
          await ensureTable(syncState);
          await ensureTable(checklistItems);
          await ensureTable(goalPostponements);
          await ensureTable(goalReviews);
          await ensureTable(backupLogs);
          await ensureTable(annualReviews);

          await ensureColumn(table: foodRecords, column: foodRecords.isFavorite);
          await ensureColumn(table: momentRecords, column: momentRecords.isFavorite);
          await ensureColumn(table: friendRecords, column: friendRecords.isFavorite);
          await ensureColumn(table: travelRecords, column: travelRecords.isFavorite);

          await ensureColumn(table: foodRecords, column: foodRecords.poiName);
          await ensureColumn(table: foodRecords, column: foodRecords.poiAddress);

          await ensureColumn(table: momentRecords, column: momentRecords.poiName);
          await ensureColumn(table: momentRecords, column: momentRecords.poiAddress);
          await ensureColumn(table: momentRecords, column: momentRecords.latitude);
          await ensureColumn(table: momentRecords, column: momentRecords.longitude);

          await ensureColumn(table: travelRecords, column: travelRecords.poiName);
          await ensureColumn(table: travelRecords, column: travelRecords.poiAddress);
          await ensureColumn(table: travelRecords, column: travelRecords.latitude);
          await ensureColumn(table: travelRecords, column: travelRecords.longitude);

          await ensureColumn(table: timelineEvents, column: timelineEvents.poiName);
          await ensureColumn(table: timelineEvents, column: timelineEvents.poiAddress);
          await ensureColumn(table: timelineEvents, column: timelineEvents.latitude);
          await ensureColumn(table: timelineEvents, column: timelineEvents.longitude);

          if (await columnExists('food_records', 'poi_address') && await columnExists('food_records', 'city')) {
            await customStatement('UPDATE food_records SET poi_address = city WHERE poi_address IS NULL AND city IS NOT NULL');
          }
          if (await columnExists('food_records', 'poi_name') && await columnExists('food_records', 'city')) {
            await customStatement('UPDATE food_records SET poi_name = city WHERE poi_name IS NULL AND city IS NOT NULL');
          }
          if (await columnExists('moment_records', 'poi_name') && await columnExists('moment_records', 'city')) {
            await customStatement('UPDATE moment_records SET poi_name = city WHERE poi_name IS NULL AND city IS NOT NULL');
          }
          if (await columnExists('travel_records', 'poi_name') && await columnExists('travel_records', 'destination')) {
            await customStatement('UPDATE travel_records SET poi_name = destination WHERE poi_name IS NULL AND destination IS NOT NULL');
          }

          await ensureColumn(table: travelRecords, column: travelRecords.tags);
          await ensureColumn(table: timelineEvents, column: timelineEvents.tags);

          if (await columnExists('travel_records', 'tags') && await columnExists('travel_records', 'destination')) {
            await customStatement(
              "UPDATE travel_records SET tags = json_array(destination) WHERE tags IS NULL AND destination IS NOT NULL AND destination != ''",
            );
          }
          if (await columnExists('timeline_events', 'tags') && await columnExists('timeline_events', 'note')) {
            await customStatement(
              "UPDATE timeline_events SET tags = json_array(substr(note, instr(note, '分类：') + 9)) WHERE tags IS NULL AND note LIKE '%分类：%'",
            );
          }

          await ensureColumn(table: travelRecords, column: travelRecords.isJournal);

          await ensureColumn(table: foodRecords, column: foodRecords.country);
          await ensureColumn(table: travelRecords, column: travelRecords.country);

          await ensureColumn(table: travelRecords, column: travelRecords.flightLink);
          await ensureColumn(table: travelRecords, column: travelRecords.hotelLink);

          await ensureColumn(table: goalRecords, column: goalRecords.tags);

          await ensureColumn(table: goalRecords, column: goalRecords.isFavorite);
          await ensureColumn(table: timelineEvents, column: timelineEvents.isFavorite);

          if (await columnExists('moment_records', 'scene_tag')) {
            await customStatement(
              "UPDATE moment_records SET scene_tag = json_array(scene_tag) WHERE scene_tag IS NOT NULL AND scene_tag != '' AND json_valid(scene_tag) = 0",
            );
            await customStatement('ALTER TABLE moment_records RENAME COLUMN scene_tag TO tags');
          }

          if (from < 21) {
            await _createIndexes();
          }

          if (from < 22) {
            await _createFTSTables();
          }

          if (from < 23) {
            await _createEmbeddingsTable();
          }

          if (from < 24) {
            await ensureTable(chatSessions);
            await ensureTable(chatMessages);
          }

          if (from < 25) {
            await ensureColumn(table: goalRecords, column: goalRecords.completedAt);
          }

          if (from < 26) {
            if (!await columnExists('chat_sessions', 'module_type')) {
              await customStatement('ALTER TABLE chat_sessions ADD COLUMN module_type TEXT');
            }
          }

          if (from < 27) {
            if (!await columnExists('annual_reviews', 'title')) {
              await customStatement('ALTER TABLE annual_reviews ADD COLUMN title TEXT NOT NULL DEFAULT \'\'');
            }
            if (!await columnExists('annual_reviews', 'stats')) {
              await customStatement('ALTER TABLE annual_reviews ADD COLUMN stats TEXT');
            }
            if (!await columnExists('annual_reviews', 'keywords')) {
              await customStatement('ALTER TABLE annual_reviews ADD COLUMN keywords TEXT');
            }
          }

          // 修复历史数据：将逗号分隔的images字段转换为JSON数组格式
          if (await columnExists('travel_records', 'images')) {
            await customStatement('''
              UPDATE travel_records 
              SET images = json_array(images) 
              WHERE images IS NOT NULL 
              AND images != '' 
              AND json_valid(images) = 0
            ''');
          }
          if (await columnExists('travel_records', 'tags')) {
            await customStatement('''
              UPDATE travel_records 
              SET tags = json_array(tags) 
              WHERE tags IS NOT NULL 
              AND tags != '' 
              AND json_valid(tags) = 0
            ''');
          }
          if (await columnExists('food_records', 'images')) {
            await customStatement('''
              UPDATE food_records 
              SET images = json_array(images) 
              WHERE images IS NOT NULL 
              AND images != '' 
              AND json_valid(images) = 0
            ''');
          }
          if (await columnExists('food_records', 'tags')) {
            await customStatement('''
              UPDATE food_records 
              SET tags = json_array(tags) 
              WHERE tags IS NOT NULL 
              AND tags != '' 
              AND json_valid(tags) = 0
            ''');
          }
          if (await columnExists('moment_records', 'images')) {
            await customStatement('''
              UPDATE moment_records 
              SET images = json_array(images) 
              WHERE images IS NOT NULL 
              AND images != '' 
              AND json_valid(images) = 0
            ''');
          }
          if (await columnExists('moment_records', 'tags')) {
            await customStatement('''
              UPDATE moment_records 
              SET tags = json_array(tags) 
              WHERE tags IS NOT NULL 
              AND tags != '' 
              AND json_valid(tags) = 0
            ''');
          }
          if (await columnExists('friend_records', 'images')) {
            await customStatement('''
              UPDATE friend_records 
              SET images = json_array(images) 
              WHERE images IS NOT NULL 
              AND images != '' 
              AND json_valid(images) = 0
            ''');
          }
        },
      );

  Future<void> _createEmbeddingsTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS record_embeddings (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        embedding BLOB NOT NULL,
        dimension INTEGER NOT NULL,
        model_name TEXT NOT NULL,
        source_text TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_record_embeddings_entity 
      ON record_embeddings (entity_type, entity_id)
    ''');

    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_record_embeddings_entity_type 
      ON record_embeddings (entity_type)
    ''');
  }

  Future<void> _createFTSTables() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS food_records_fts USING fts5(
        title, content, poi_name, city,
        content='food_records',
        content_rowid='rowid',
        tokenize='unicode61'
      )
    ''');

    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS moment_records_fts USING fts5(
        content, poi_name, city,
        content='moment_records',
        content_rowid='rowid',
        tokenize='unicode61'
      )
    ''');

    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS travel_records_fts USING fts5(
        title, content, destination, poi_name, city,
        content='travel_records',
        content_rowid='rowid',
        tokenize='unicode61'
      )
    ''');

    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS goal_records_fts USING fts5(
        title, note, summary,
        content='goal_records',
        content_rowid='rowid',
        tokenize='unicode61'
      )
    ''');

    await _populateFTSData();
  }

  Future<void> _populateFTSData() async {
    await customStatement('''
      INSERT INTO food_records_fts(food_records_fts) VALUES('rebuild')
    ''');

    await customStatement('''
      INSERT INTO moment_records_fts(moment_records_fts) VALUES('rebuild')
    ''');

    await customStatement('''
      INSERT INTO travel_records_fts(travel_records_fts) VALUES('rebuild')
    ''');

    await customStatement('''
      INSERT INTO goal_records_fts(goal_records_fts) VALUES('rebuild')
    ''');
  }

  Future<void> _ensureDefaultEmbeddingProvider() async {
    final existingMoark = await (select(aiProviders)
          ..where((t) => t.name.equals('模力方舟') & t.serviceType.equals('embedding')))
        .get();

    if (existingMoark.isEmpty) {
      final now = DateTime.now();
      const uuid = Uuid();
      await into(aiProviders).insert(
        AiProvidersCompanion(
          id: Value(uuid.v4()),
          name: const Value('模力方舟'),
          apiType: const Value('openai'),
          serviceType: const Value('embedding'),
          baseUrl: const Value('https://ai.gitee.com/v1'),
          apiKey: const Value('AAMX6RZWNFGZ9H1CERSNPTQOQSIHSR5TBTNI8Y8G'),
          modelName: const Value('Qwen3-Embedding-8B'),
          isActive: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Future<void> _ensureDefaultChatProvider() async {
    final existingDefault = await (select(aiProviders)
          ..where((t) => t.name.equals('默认') & t.serviceType.equals('chat')))
        .get();

    if (existingDefault.isEmpty) {
      final now = DateTime.now();
      const uuid = Uuid();
      await into(aiProviders).insert(
        AiProvidersCompanion(
          id: Value(uuid.v4()),
          name: const Value('默认'),
          apiType: const Value('openai'),
          serviceType: const Value('chat'),
          baseUrl: const Value('https://api.zscc.in'),
          apiKey: const Value('sk-tTHwWh4n0iWjlTRuxraXrJKx5PAjHFEdM3MhL0N2oB1Xp5oj'),
          modelName: const Value('gemini-3-flash'),
          isActive: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Future<void> _createIndexes() async {
    await customStatement('CREATE INDEX IF NOT EXISTS idx_food_records_record_date ON food_records (record_date)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_food_records_is_deleted ON food_records (is_deleted)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_food_records_is_favorite ON food_records (is_favorite)');

    await customStatement('CREATE INDEX IF NOT EXISTS idx_moment_records_record_date ON moment_records (record_date)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_moment_records_is_deleted ON moment_records (is_deleted)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_moment_records_is_favorite ON moment_records (is_favorite)');

    await customStatement('CREATE INDEX IF NOT EXISTS idx_friend_records_is_deleted ON friend_records (is_deleted)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_friend_records_is_favorite ON friend_records (is_favorite)');

    await customStatement('CREATE INDEX IF NOT EXISTS idx_travel_records_record_date ON travel_records (record_date)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_travel_records_is_deleted ON travel_records (is_deleted)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_travel_records_is_favorite ON travel_records (is_favorite)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_travel_records_trip_id ON travel_records (trip_id)');

    await customStatement('CREATE INDEX IF NOT EXISTS idx_goal_records_record_date ON goal_records (record_date)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_goal_records_is_deleted ON goal_records (is_deleted)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_goal_records_is_favorite ON goal_records (is_favorite)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_goal_records_parent_id ON goal_records (parent_id)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_goal_records_level ON goal_records (level)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_goal_records_is_completed ON goal_records (is_completed)');

    await customStatement('CREATE INDEX IF NOT EXISTS idx_timeline_events_record_date ON timeline_events (record_date)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_timeline_events_is_deleted ON timeline_events (is_deleted)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_timeline_events_event_type ON timeline_events (event_type)');

    await customStatement('CREATE INDEX IF NOT EXISTS idx_entity_links_source ON entity_links (source_type, source_id)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_entity_links_target ON entity_links (target_type, target_id)');

    await customStatement('CREATE INDEX IF NOT EXISTS idx_change_logs_synced ON change_logs (synced)');
  }

  Future<List<TimelineEvent>> listEventsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return (select(timelineEvents)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.startAt, nulls: NullsOrder.last)]))
        .get();
  }

  Stream<List<TimelineEvent>> watchEventsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return (select(timelineEvents)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.startAt, nulls: NullsOrder.last)]))
        .watch();
  }

  @Deprecated('Use travelDao.watchAllActive() instead')
  Stream<List<TravelRecord>> watchAllActiveTravelRecords() => travelDao.watchAllActive();

  @Deprecated('Use travelDao.watchById(id) instead')
  Stream<TravelRecord?> watchTravelById(String id) => travelDao.watchById(id);

  @Deprecated('Use travelDao.watchTrips() instead')
  Stream<List<TravelRecord>> watchTravelTrips() => travelDao.watchTrips();

  @Deprecated('Use travelDao.watchJournals(tripId) instead')
  Stream<List<TravelRecord>> watchTravelJournals(String tripId) => travelDao.watchJournals(tripId);

  @Deprecated('Use travelDao.watchByRecordDateRange(start, endExclusive) instead')
  Stream<List<TravelRecord>> watchTravelRecordsByRange(DateTime start, DateTime endExclusive) =>
      travelDao.watchByRecordDateRange(start, endExclusive);

  Stream<List<TimelineEvent>> watchEventsForMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    return (select(timelineEvents)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(end)))
        .watch();
  }

  Stream<List<TimelineEvent>> watchEncounterEvents() {
    return (select(timelineEvents)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.eventType.equals('encounter'))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch();
  }

  @Deprecated('Use goalDao.watchAllActive() instead')
  Stream<List<GoalRecord>> watchAllActiveGoalRecords() => goalDao.watchAllActive();

  @Deprecated('Use goalDao.watchUncompletedYearGoals() instead')
  Stream<List<GoalRecord>> watchUncompletedYearGoals() => goalDao.watchUncompletedYearGoals();

  Stream<List<TimelineEvent>> watchEncountersForFriend(String friendId) {
    final query = select(timelineEvents).join([
      innerJoin(
        entityLinks,
        entityLinks.sourceId.equalsExp(timelineEvents.id) &
            entityLinks.sourceType.equals('encounter') &
            entityLinks.targetType.equals('friend') &
            entityLinks.targetId.equals(friendId),
      )
    ]);

    query.where(timelineEvents.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(timelineEvents.recordDate)]);

    return query.map((row) => row.readTable(timelineEvents)).watch();
  }

  @Deprecated('Use goalDao.updateFavorite(id, isFavorite: isFavorite, now: now) instead')
  Future<void> updateGoalFavorite(String id, {required bool isFavorite, required DateTime now}) =>
      goalDao.updateFavorite(id, isFavorite: isFavorite, now: now);

  Future<void> updateEncounterFavorite(String id, {required bool isFavorite, required DateTime now}) async {
    await (update(timelineEvents)..where((t) => t.id.equals(id))).write(
      TimelineEventsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(now),
      ),
    );
  }

  Stream<List<FoodRecord>> watchFoodRecordsWithFriends() async* {
    final links = await (select(entityLinks)
          ..where((t) => t.sourceType.equals('food') & t.targetType.equals('friend')))
        .get();
    final foodIds = links.map((l) => l.sourceId).toSet().toList();
    if (foodIds.isEmpty) {
      yield const <FoodRecord>[];
      return;
    }
    yield* (select(foodRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.id.isIn(foodIds))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch();
  }

  Stream<List<MomentRecord>> watchMomentRecordsWithFriends() async* {
    final links = await (select(entityLinks)
          ..where((t) => t.sourceType.equals('moment') & t.targetType.equals('friend')))
        .get();
    final momentIds = links.map((l) => l.sourceId).toSet().toList();
    if (momentIds.isEmpty) {
      yield const <MomentRecord>[];
      return;
    }
    yield* (select(momentRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.id.isIn(momentIds))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch();
  }

  Stream<List<TravelRecord>> watchTravelRecordsWithFriends() async* {
    final links = await (select(entityLinks)
          ..where((t) => t.sourceType.equals('travel') & t.targetType.equals('friend')))
        .get();
    final travelIds = links.map((l) => l.sourceId).toSet().toList();
    if (travelIds.isEmpty) {
      yield const <TravelRecord>[];
      return;
    }
    yield* (select(travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.id.isIn(travelIds))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch();
  }
}
