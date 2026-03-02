import 'package:drift/drift.dart';

class FoodRecords extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  TextColumn get images => text().nullable()();
  TextColumn get tags => text().nullable()();
  RealColumn get rating => real().nullable()();
  RealColumn get pricePerPerson => real().nullable()();
  TextColumn get link => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get poiName => text().nullable()();
  TextColumn get poiAddress => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get mood => text().nullable()();
  BoolColumn get isWishlist => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get wishlistDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get recordDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MomentRecords extends Table {
  TextColumn get id => text()();
  TextColumn get content => text().nullable()();
  TextColumn get images => text().nullable()();
  TextColumn get mood => text()();
  TextColumn get moodColor => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get poiName => text().nullable()();
  TextColumn get poiAddress => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get city => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get recordDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class FriendRecords extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get avatarPath => text().nullable()();
  DateTimeColumn get birthday => dateTime().nullable()();
  TextColumn get contact => text().nullable()();
  TextColumn get meetWay => text().nullable()();
  DateTimeColumn get meetDate => dateTime().nullable()();
  TextColumn get impressionTags => text().nullable()();
  TextColumn get groupName => text().nullable()();
  DateTimeColumn get lastMeetDate => dateTime().nullable()();
  TextColumn get contactFrequency => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TravelRecords extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get title => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get images => text().nullable()();
  TextColumn get destination => text().nullable()();
  TextColumn get poiName => text().nullable()();
  TextColumn get poiAddress => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get mood => text().nullable()();
  TextColumn get tags => text().nullable()();
  RealColumn get expenseTransport => real().nullable()();
  RealColumn get expenseHotel => real().nullable()();
  RealColumn get expenseFood => real().nullable()();
  RealColumn get expenseTicket => real().nullable()();
  BoolColumn get isWishlist => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get wishlistDone => boolean().withDefault(const Constant(false))();
  BoolColumn get isJournal => boolean().withDefault(const Constant(false))();
  DateTimeColumn get planDate => dateTime().nullable()();
  DateTimeColumn get recordDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get destinations => text().nullable()();
  RealColumn get totalExpense => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class GoalRecords extends Table {
  TextColumn get id => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get level => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get tags => text().nullable()();
  RealColumn get progress => real().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isPostponed => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get remindFrequency => text().nullable()();
  IntColumn get targetYear => integer().nullable()();
  IntColumn get targetQuarter => integer().nullable()();
  IntColumn get targetMonth => integer().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get recordDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TimelineEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get eventType => text()();
  DateTimeColumn get startAt => dateTime().nullable()();
  DateTimeColumn get endAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get poiName => text().nullable()();
  TextColumn get poiAddress => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get recordDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class EntityLinks extends Table {
  TextColumn get id => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get targetType => text()();
  TextColumn get targetId => text()();
  TextColumn get linkType => text().withDefault(const Constant('manual'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {sourceType, sourceId, targetType, targetId},
      ];
}

class LinkLogs extends Table {
  TextColumn get id => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get targetType => text()();
  TextColumn get targetId => text()();
  TextColumn get action => text()();
  TextColumn get linkType => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get birthday => dateTime().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get relationshipStatus => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AiProviders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get apiType => text()();
  TextColumn get serviceType => text()();
  TextColumn get baseUrl => text()();
  TextColumn get apiKey => text()();
  TextColumn get modelName => text().nullable()();
  TextColumn get extraConfig => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChecklistItems extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get travelId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChangeLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get changedFields => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

class SyncState extends Table {
  TextColumn get id => text()();
  DateTimeColumn get lastSyncTime => dateTime().nullable()();
  IntColumn get lastSyncChangeId => integer().nullable()();
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class GoalPostponements extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text()();
  DateTimeColumn get oldDueDate => dateTime().nullable()();
  DateTimeColumn get newDueDate => dateTime().nullable()();
  TextColumn get reason => text().nullable()();
  IntColumn get daysAdded => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class GoalReviews extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text()();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  DateTimeColumn get reviewDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BackupLogs extends Table {
  TextColumn get id => text()();
  TextColumn get backupType => text()();
  TextColumn get storageType => text()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get recordCount => integer().nullable()();
  IntColumn get mediaCount => integer().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AnnualReviews extends Table {
  TextColumn get id => text()();
  IntColumn get year => integer()();
  TextColumn get content => text().nullable()();
  TextColumn get images => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
