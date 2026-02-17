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
  TextColumn get city => text().nullable()();
  TextColumn get mood => text().nullable()();
  BoolColumn get isWishlist => boolean().withDefault(const Constant(false))();
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
  TextColumn get sceneTag => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get city => text().nullable()();
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
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get mood => text().nullable()();
  RealColumn get expenseTransport => real().nullable()();
  RealColumn get expenseHotel => real().nullable()();
  RealColumn get expenseFood => real().nullable()();
  RealColumn get expenseTicket => real().nullable()();
  BoolColumn get isWishlist => boolean().withDefault(const Constant(false))();
  BoolColumn get wishlistDone => boolean().withDefault(const Constant(false))();
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

class TimelineEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get eventType => text()();
  DateTimeColumn get startAt => dateTime().nullable()();
  DateTimeColumn get endAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
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
