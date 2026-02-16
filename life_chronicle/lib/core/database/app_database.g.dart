// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoodRecordsTable extends FoodRecords
    with TableInfo<$FoodRecordsTable, FoodRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
      'images', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
      'rating', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _pricePerPersonMeta =
      const VerificationMeta('pricePerPerson');
  @override
  late final GeneratedColumn<double> pricePerPerson = GeneratedColumn<double>(
      'price_per_person', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
      'link', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _poiNameMeta =
      const VerificationMeta('poiName');
  @override
  late final GeneratedColumn<String> poiName = GeneratedColumn<String>(
      'poi_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
      'mood', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isWishlistMeta =
      const VerificationMeta('isWishlist');
  @override
  late final GeneratedColumn<bool> isWishlist = GeneratedColumn<bool>(
      'is_wishlist', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_wishlist" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wishlistDoneMeta =
      const VerificationMeta('wishlistDone');
  @override
  late final GeneratedColumn<bool> wishlistDone = GeneratedColumn<bool>(
      'wishlist_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("wishlist_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recordDateMeta =
      const VerificationMeta('recordDate');
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
      'record_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        content,
        images,
        tags,
        rating,
        pricePerPerson,
        link,
        latitude,
        longitude,
        poiName,
        city,
        mood,
        isWishlist,
        wishlistDone,
        recordDate,
        createdAt,
        updatedAt,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_records';
  @override
  VerificationContext validateIntegrity(Insertable<FoodRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('images')) {
      context.handle(_imagesMeta,
          images.isAcceptableOrUnknown(data['images']!, _imagesMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('price_per_person')) {
      context.handle(
          _pricePerPersonMeta,
          pricePerPerson.isAcceptableOrUnknown(
              data['price_per_person']!, _pricePerPersonMeta));
    }
    if (data.containsKey('link')) {
      context.handle(
          _linkMeta, link.isAcceptableOrUnknown(data['link']!, _linkMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('poi_name')) {
      context.handle(_poiNameMeta,
          poiName.isAcceptableOrUnknown(data['poi_name']!, _poiNameMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('mood')) {
      context.handle(
          _moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    }
    if (data.containsKey('is_wishlist')) {
      context.handle(
          _isWishlistMeta,
          isWishlist.isAcceptableOrUnknown(
              data['is_wishlist']!, _isWishlistMeta));
    }
    if (data.containsKey('wishlist_done')) {
      context.handle(
          _wishlistDoneMeta,
          wishlistDone.isAcceptableOrUnknown(
              data['wishlist_done']!, _wishlistDoneMeta));
    }
    if (data.containsKey('record_date')) {
      context.handle(
          _recordDateMeta,
          recordDate.isAcceptableOrUnknown(
              data['record_date']!, _recordDateMeta));
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      images: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating']),
      pricePerPerson: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}price_per_person']),
      link: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      poiName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_name']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      mood: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood']),
      isWishlist: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_wishlist'])!,
      wishlistDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}wishlist_done'])!,
      recordDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}record_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $FoodRecordsTable createAlias(String alias) {
    return $FoodRecordsTable(attachedDatabase, alias);
  }
}

class FoodRecord extends DataClass implements Insertable<FoodRecord> {
  final String id;
  final String title;
  final String? content;
  final String? images;
  final String? tags;
  final double? rating;
  final double? pricePerPerson;
  final String? link;
  final double? latitude;
  final double? longitude;
  final String? poiName;
  final String? city;
  final String? mood;
  final bool isWishlist;
  final bool wishlistDone;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const FoodRecord(
      {required this.id,
      required this.title,
      this.content,
      this.images,
      this.tags,
      this.rating,
      this.pricePerPerson,
      this.link,
      this.latitude,
      this.longitude,
      this.poiName,
      this.city,
      this.mood,
      required this.isWishlist,
      required this.wishlistDone,
      required this.recordDate,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || images != null) {
      map['images'] = Variable<String>(images);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || pricePerPerson != null) {
      map['price_per_person'] = Variable<double>(pricePerPerson);
    }
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || poiName != null) {
      map['poi_name'] = Variable<String>(poiName);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    map['is_wishlist'] = Variable<bool>(isWishlist);
    map['wishlist_done'] = Variable<bool>(wishlistDone);
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  FoodRecordsCompanion toCompanion(bool nullToAbsent) {
    return FoodRecordsCompanion(
      id: Value(id),
      title: Value(title),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      images:
          images == null && nullToAbsent ? const Value.absent() : Value(images),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      pricePerPerson: pricePerPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePerPerson),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      poiName: poiName == null && nullToAbsent
          ? const Value.absent()
          : Value(poiName),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      isWishlist: Value(isWishlist),
      wishlistDone: Value(wishlistDone),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory FoodRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodRecord(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      images: serializer.fromJson<String?>(json['images']),
      tags: serializer.fromJson<String?>(json['tags']),
      rating: serializer.fromJson<double?>(json['rating']),
      pricePerPerson: serializer.fromJson<double?>(json['pricePerPerson']),
      link: serializer.fromJson<String?>(json['link']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      poiName: serializer.fromJson<String?>(json['poiName']),
      city: serializer.fromJson<String?>(json['city']),
      mood: serializer.fromJson<String?>(json['mood']),
      isWishlist: serializer.fromJson<bool>(json['isWishlist']),
      wishlistDone: serializer.fromJson<bool>(json['wishlistDone']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String?>(content),
      'images': serializer.toJson<String?>(images),
      'tags': serializer.toJson<String?>(tags),
      'rating': serializer.toJson<double?>(rating),
      'pricePerPerson': serializer.toJson<double?>(pricePerPerson),
      'link': serializer.toJson<String?>(link),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'poiName': serializer.toJson<String?>(poiName),
      'city': serializer.toJson<String?>(city),
      'mood': serializer.toJson<String?>(mood),
      'isWishlist': serializer.toJson<bool>(isWishlist),
      'wishlistDone': serializer.toJson<bool>(wishlistDone),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  FoodRecord copyWith(
          {String? id,
          String? title,
          Value<String?> content = const Value.absent(),
          Value<String?> images = const Value.absent(),
          Value<String?> tags = const Value.absent(),
          Value<double?> rating = const Value.absent(),
          Value<double?> pricePerPerson = const Value.absent(),
          Value<String?> link = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> poiName = const Value.absent(),
          Value<String?> city = const Value.absent(),
          Value<String?> mood = const Value.absent(),
          bool? isWishlist,
          bool? wishlistDone,
          DateTime? recordDate,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted}) =>
      FoodRecord(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content.present ? content.value : this.content,
        images: images.present ? images.value : this.images,
        tags: tags.present ? tags.value : this.tags,
        rating: rating.present ? rating.value : this.rating,
        pricePerPerson:
            pricePerPerson.present ? pricePerPerson.value : this.pricePerPerson,
        link: link.present ? link.value : this.link,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        poiName: poiName.present ? poiName.value : this.poiName,
        city: city.present ? city.value : this.city,
        mood: mood.present ? mood.value : this.mood,
        isWishlist: isWishlist ?? this.isWishlist,
        wishlistDone: wishlistDone ?? this.wishlistDone,
        recordDate: recordDate ?? this.recordDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  FoodRecord copyWithCompanion(FoodRecordsCompanion data) {
    return FoodRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      images: data.images.present ? data.images.value : this.images,
      tags: data.tags.present ? data.tags.value : this.tags,
      rating: data.rating.present ? data.rating.value : this.rating,
      pricePerPerson: data.pricePerPerson.present
          ? data.pricePerPerson.value
          : this.pricePerPerson,
      link: data.link.present ? data.link.value : this.link,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      poiName: data.poiName.present ? data.poiName.value : this.poiName,
      city: data.city.present ? data.city.value : this.city,
      mood: data.mood.present ? data.mood.value : this.mood,
      isWishlist:
          data.isWishlist.present ? data.isWishlist.value : this.isWishlist,
      wishlistDone: data.wishlistDone.present
          ? data.wishlistDone.value
          : this.wishlistDone,
      recordDate:
          data.recordDate.present ? data.recordDate.value : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('images: $images, ')
          ..write('tags: $tags, ')
          ..write('rating: $rating, ')
          ..write('pricePerPerson: $pricePerPerson, ')
          ..write('link: $link, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('poiName: $poiName, ')
          ..write('city: $city, ')
          ..write('mood: $mood, ')
          ..write('isWishlist: $isWishlist, ')
          ..write('wishlistDone: $wishlistDone, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      content,
      images,
      tags,
      rating,
      pricePerPerson,
      link,
      latitude,
      longitude,
      poiName,
      city,
      mood,
      isWishlist,
      wishlistDone,
      recordDate,
      createdAt,
      updatedAt,
      isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.images == this.images &&
          other.tags == this.tags &&
          other.rating == this.rating &&
          other.pricePerPerson == this.pricePerPerson &&
          other.link == this.link &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.poiName == this.poiName &&
          other.city == this.city &&
          other.mood == this.mood &&
          other.isWishlist == this.isWishlist &&
          other.wishlistDone == this.wishlistDone &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class FoodRecordsCompanion extends UpdateCompanion<FoodRecord> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> content;
  final Value<String?> images;
  final Value<String?> tags;
  final Value<double?> rating;
  final Value<double?> pricePerPerson;
  final Value<String?> link;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> poiName;
  final Value<String?> city;
  final Value<String?> mood;
  final Value<bool> isWishlist;
  final Value<bool> wishlistDone;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const FoodRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.images = const Value.absent(),
    this.tags = const Value.absent(),
    this.rating = const Value.absent(),
    this.pricePerPerson = const Value.absent(),
    this.link = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.poiName = const Value.absent(),
    this.city = const Value.absent(),
    this.mood = const Value.absent(),
    this.isWishlist = const Value.absent(),
    this.wishlistDone = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodRecordsCompanion.insert({
    required String id,
    required String title,
    this.content = const Value.absent(),
    this.images = const Value.absent(),
    this.tags = const Value.absent(),
    this.rating = const Value.absent(),
    this.pricePerPerson = const Value.absent(),
    this.link = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.poiName = const Value.absent(),
    this.city = const Value.absent(),
    this.mood = const Value.absent(),
    this.isWishlist = const Value.absent(),
    this.wishlistDone = const Value.absent(),
    required DateTime recordDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        recordDate = Value(recordDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FoodRecord> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? images,
    Expression<String>? tags,
    Expression<double>? rating,
    Expression<double>? pricePerPerson,
    Expression<String>? link,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? poiName,
    Expression<String>? city,
    Expression<String>? mood,
    Expression<bool>? isWishlist,
    Expression<bool>? wishlistDone,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (images != null) 'images': images,
      if (tags != null) 'tags': tags,
      if (rating != null) 'rating': rating,
      if (pricePerPerson != null) 'price_per_person': pricePerPerson,
      if (link != null) 'link': link,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (poiName != null) 'poi_name': poiName,
      if (city != null) 'city': city,
      if (mood != null) 'mood': mood,
      if (isWishlist != null) 'is_wishlist': isWishlist,
      if (wishlistDone != null) 'wishlist_done': wishlistDone,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? content,
      Value<String?>? images,
      Value<String?>? tags,
      Value<double?>? rating,
      Value<double?>? pricePerPerson,
      Value<String?>? link,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? poiName,
      Value<String?>? city,
      Value<String?>? mood,
      Value<bool>? isWishlist,
      Value<bool>? wishlistDone,
      Value<DateTime>? recordDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return FoodRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      link: link ?? this.link,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      poiName: poiName ?? this.poiName,
      city: city ?? this.city,
      mood: mood ?? this.mood,
      isWishlist: isWishlist ?? this.isWishlist,
      wishlistDone: wishlistDone ?? this.wishlistDone,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (pricePerPerson.present) {
      map['price_per_person'] = Variable<double>(pricePerPerson.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (poiName.present) {
      map['poi_name'] = Variable<String>(poiName.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (isWishlist.present) {
      map['is_wishlist'] = Variable<bool>(isWishlist.value);
    }
    if (wishlistDone.present) {
      map['wishlist_done'] = Variable<bool>(wishlistDone.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodRecordsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('images: $images, ')
          ..write('tags: $tags, ')
          ..write('rating: $rating, ')
          ..write('pricePerPerson: $pricePerPerson, ')
          ..write('link: $link, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('poiName: $poiName, ')
          ..write('city: $city, ')
          ..write('mood: $mood, ')
          ..write('isWishlist: $isWishlist, ')
          ..write('wishlistDone: $wishlistDone, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MomentRecordsTable extends MomentRecords
    with TableInfo<$MomentRecordsTable, MomentRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MomentRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
      'images', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
      'mood', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _moodColorMeta =
      const VerificationMeta('moodColor');
  @override
  late final GeneratedColumn<String> moodColor = GeneratedColumn<String>(
      'mood_color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sceneTagMeta =
      const VerificationMeta('sceneTag');
  @override
  late final GeneratedColumn<String> sceneTag = GeneratedColumn<String>(
      'scene_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordDateMeta =
      const VerificationMeta('recordDate');
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
      'record_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        content,
        images,
        mood,
        moodColor,
        sceneTag,
        latitude,
        longitude,
        city,
        recordDate,
        createdAt,
        updatedAt,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'moment_records';
  @override
  VerificationContext validateIntegrity(Insertable<MomentRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('images')) {
      context.handle(_imagesMeta,
          images.isAcceptableOrUnknown(data['images']!, _imagesMeta));
    }
    if (data.containsKey('mood')) {
      context.handle(
          _moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('mood_color')) {
      context.handle(_moodColorMeta,
          moodColor.isAcceptableOrUnknown(data['mood_color']!, _moodColorMeta));
    }
    if (data.containsKey('scene_tag')) {
      context.handle(_sceneTagMeta,
          sceneTag.isAcceptableOrUnknown(data['scene_tag']!, _sceneTagMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('record_date')) {
      context.handle(
          _recordDateMeta,
          recordDate.isAcceptableOrUnknown(
              data['record_date']!, _recordDateMeta));
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MomentRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MomentRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      images: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images']),
      mood: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood'])!,
      moodColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood_color']),
      sceneTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene_tag']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      recordDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}record_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $MomentRecordsTable createAlias(String alias) {
    return $MomentRecordsTable(attachedDatabase, alias);
  }
}

class MomentRecord extends DataClass implements Insertable<MomentRecord> {
  final String id;
  final String? content;
  final String? images;
  final String mood;
  final String? moodColor;
  final String? sceneTag;
  final double? latitude;
  final double? longitude;
  final String? city;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const MomentRecord(
      {required this.id,
      this.content,
      this.images,
      required this.mood,
      this.moodColor,
      this.sceneTag,
      this.latitude,
      this.longitude,
      this.city,
      required this.recordDate,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || images != null) {
      map['images'] = Variable<String>(images);
    }
    map['mood'] = Variable<String>(mood);
    if (!nullToAbsent || moodColor != null) {
      map['mood_color'] = Variable<String>(moodColor);
    }
    if (!nullToAbsent || sceneTag != null) {
      map['scene_tag'] = Variable<String>(sceneTag);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  MomentRecordsCompanion toCompanion(bool nullToAbsent) {
    return MomentRecordsCompanion(
      id: Value(id),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      images:
          images == null && nullToAbsent ? const Value.absent() : Value(images),
      mood: Value(mood),
      moodColor: moodColor == null && nullToAbsent
          ? const Value.absent()
          : Value(moodColor),
      sceneTag: sceneTag == null && nullToAbsent
          ? const Value.absent()
          : Value(sceneTag),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory MomentRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MomentRecord(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String?>(json['content']),
      images: serializer.fromJson<String?>(json['images']),
      mood: serializer.fromJson<String>(json['mood']),
      moodColor: serializer.fromJson<String?>(json['moodColor']),
      sceneTag: serializer.fromJson<String?>(json['sceneTag']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      city: serializer.fromJson<String?>(json['city']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String?>(content),
      'images': serializer.toJson<String?>(images),
      'mood': serializer.toJson<String>(mood),
      'moodColor': serializer.toJson<String?>(moodColor),
      'sceneTag': serializer.toJson<String?>(sceneTag),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'city': serializer.toJson<String?>(city),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  MomentRecord copyWith(
          {String? id,
          Value<String?> content = const Value.absent(),
          Value<String?> images = const Value.absent(),
          String? mood,
          Value<String?> moodColor = const Value.absent(),
          Value<String?> sceneTag = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> city = const Value.absent(),
          DateTime? recordDate,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted}) =>
      MomentRecord(
        id: id ?? this.id,
        content: content.present ? content.value : this.content,
        images: images.present ? images.value : this.images,
        mood: mood ?? this.mood,
        moodColor: moodColor.present ? moodColor.value : this.moodColor,
        sceneTag: sceneTag.present ? sceneTag.value : this.sceneTag,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        city: city.present ? city.value : this.city,
        recordDate: recordDate ?? this.recordDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  MomentRecord copyWithCompanion(MomentRecordsCompanion data) {
    return MomentRecord(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      images: data.images.present ? data.images.value : this.images,
      mood: data.mood.present ? data.mood.value : this.mood,
      moodColor: data.moodColor.present ? data.moodColor.value : this.moodColor,
      sceneTag: data.sceneTag.present ? data.sceneTag.value : this.sceneTag,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      city: data.city.present ? data.city.value : this.city,
      recordDate:
          data.recordDate.present ? data.recordDate.value : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MomentRecord(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('images: $images, ')
          ..write('mood: $mood, ')
          ..write('moodColor: $moodColor, ')
          ..write('sceneTag: $sceneTag, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('city: $city, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      content,
      images,
      mood,
      moodColor,
      sceneTag,
      latitude,
      longitude,
      city,
      recordDate,
      createdAt,
      updatedAt,
      isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MomentRecord &&
          other.id == this.id &&
          other.content == this.content &&
          other.images == this.images &&
          other.mood == this.mood &&
          other.moodColor == this.moodColor &&
          other.sceneTag == this.sceneTag &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.city == this.city &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class MomentRecordsCompanion extends UpdateCompanion<MomentRecord> {
  final Value<String> id;
  final Value<String?> content;
  final Value<String?> images;
  final Value<String> mood;
  final Value<String?> moodColor;
  final Value<String?> sceneTag;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> city;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const MomentRecordsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.images = const Value.absent(),
    this.mood = const Value.absent(),
    this.moodColor = const Value.absent(),
    this.sceneTag = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.city = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MomentRecordsCompanion.insert({
    required String id,
    this.content = const Value.absent(),
    this.images = const Value.absent(),
    required String mood,
    this.moodColor = const Value.absent(),
    this.sceneTag = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.city = const Value.absent(),
    required DateTime recordDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mood = Value(mood),
        recordDate = Value(recordDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MomentRecord> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<String>? images,
    Expression<String>? mood,
    Expression<String>? moodColor,
    Expression<String>? sceneTag,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? city,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (images != null) 'images': images,
      if (mood != null) 'mood': mood,
      if (moodColor != null) 'mood_color': moodColor,
      if (sceneTag != null) 'scene_tag': sceneTag,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (city != null) 'city': city,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MomentRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? content,
      Value<String?>? images,
      Value<String>? mood,
      Value<String?>? moodColor,
      Value<String?>? sceneTag,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? city,
      Value<DateTime>? recordDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return MomentRecordsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      images: images ?? this.images,
      mood: mood ?? this.mood,
      moodColor: moodColor ?? this.moodColor,
      sceneTag: sceneTag ?? this.sceneTag,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (moodColor.present) {
      map['mood_color'] = Variable<String>(moodColor.value);
    }
    if (sceneTag.present) {
      map['scene_tag'] = Variable<String>(sceneTag.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MomentRecordsCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('images: $images, ')
          ..write('mood: $mood, ')
          ..write('moodColor: $moodColor, ')
          ..write('sceneTag: $sceneTag, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('city: $city, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FriendRecordsTable extends FriendRecords
    with TableInfo<$FriendRecordsTable, FriendRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarPathMeta =
      const VerificationMeta('avatarPath');
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
      'avatar_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _birthdayMeta =
      const VerificationMeta('birthday');
  @override
  late final GeneratedColumn<DateTime> birthday = GeneratedColumn<DateTime>(
      'birthday', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _contactMeta =
      const VerificationMeta('contact');
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
      'contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _meetWayMeta =
      const VerificationMeta('meetWay');
  @override
  late final GeneratedColumn<String> meetWay = GeneratedColumn<String>(
      'meet_way', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _meetDateMeta =
      const VerificationMeta('meetDate');
  @override
  late final GeneratedColumn<DateTime> meetDate = GeneratedColumn<DateTime>(
      'meet_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _impressionTagsMeta =
      const VerificationMeta('impressionTags');
  @override
  late final GeneratedColumn<String> impressionTags = GeneratedColumn<String>(
      'impression_tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMeetDateMeta =
      const VerificationMeta('lastMeetDate');
  @override
  late final GeneratedColumn<DateTime> lastMeetDate = GeneratedColumn<DateTime>(
      'last_meet_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _contactFrequencyMeta =
      const VerificationMeta('contactFrequency');
  @override
  late final GeneratedColumn<String> contactFrequency = GeneratedColumn<String>(
      'contact_frequency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        avatarPath,
        birthday,
        contact,
        meetWay,
        meetDate,
        impressionTags,
        groupName,
        lastMeetDate,
        contactFrequency,
        createdAt,
        updatedAt,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friend_records';
  @override
  VerificationContext validateIntegrity(Insertable<FriendRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
          _avatarPathMeta,
          avatarPath.isAcceptableOrUnknown(
              data['avatar_path']!, _avatarPathMeta));
    }
    if (data.containsKey('birthday')) {
      context.handle(_birthdayMeta,
          birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta));
    }
    if (data.containsKey('contact')) {
      context.handle(_contactMeta,
          contact.isAcceptableOrUnknown(data['contact']!, _contactMeta));
    }
    if (data.containsKey('meet_way')) {
      context.handle(_meetWayMeta,
          meetWay.isAcceptableOrUnknown(data['meet_way']!, _meetWayMeta));
    }
    if (data.containsKey('meet_date')) {
      context.handle(_meetDateMeta,
          meetDate.isAcceptableOrUnknown(data['meet_date']!, _meetDateMeta));
    }
    if (data.containsKey('impression_tags')) {
      context.handle(
          _impressionTagsMeta,
          impressionTags.isAcceptableOrUnknown(
              data['impression_tags']!, _impressionTagsMeta));
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    }
    if (data.containsKey('last_meet_date')) {
      context.handle(
          _lastMeetDateMeta,
          lastMeetDate.isAcceptableOrUnknown(
              data['last_meet_date']!, _lastMeetDateMeta));
    }
    if (data.containsKey('contact_frequency')) {
      context.handle(
          _contactFrequencyMeta,
          contactFrequency.isAcceptableOrUnknown(
              data['contact_frequency']!, _contactFrequencyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FriendRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FriendRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      avatarPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_path']),
      birthday: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birthday']),
      contact: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact']),
      meetWay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meet_way']),
      meetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}meet_date']),
      impressionTags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}impression_tags']),
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name']),
      lastMeetDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_meet_date']),
      contactFrequency: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contact_frequency']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $FriendRecordsTable createAlias(String alias) {
    return $FriendRecordsTable(attachedDatabase, alias);
  }
}

class FriendRecord extends DataClass implements Insertable<FriendRecord> {
  final String id;
  final String name;
  final String? avatarPath;
  final DateTime? birthday;
  final String? contact;
  final String? meetWay;
  final DateTime? meetDate;
  final String? impressionTags;
  final String? groupName;
  final DateTime? lastMeetDate;
  final String? contactFrequency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const FriendRecord(
      {required this.id,
      required this.name,
      this.avatarPath,
      this.birthday,
      this.contact,
      this.meetWay,
      this.meetDate,
      this.impressionTags,
      this.groupName,
      this.lastMeetDate,
      this.contactFrequency,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<DateTime>(birthday);
    }
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    if (!nullToAbsent || meetWay != null) {
      map['meet_way'] = Variable<String>(meetWay);
    }
    if (!nullToAbsent || meetDate != null) {
      map['meet_date'] = Variable<DateTime>(meetDate);
    }
    if (!nullToAbsent || impressionTags != null) {
      map['impression_tags'] = Variable<String>(impressionTags);
    }
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    if (!nullToAbsent || lastMeetDate != null) {
      map['last_meet_date'] = Variable<DateTime>(lastMeetDate);
    }
    if (!nullToAbsent || contactFrequency != null) {
      map['contact_frequency'] = Variable<String>(contactFrequency);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  FriendRecordsCompanion toCompanion(bool nullToAbsent) {
    return FriendRecordsCompanion(
      id: Value(id),
      name: Value(name),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      birthday: birthday == null && nullToAbsent
          ? const Value.absent()
          : Value(birthday),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
      meetWay: meetWay == null && nullToAbsent
          ? const Value.absent()
          : Value(meetWay),
      meetDate: meetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(meetDate),
      impressionTags: impressionTags == null && nullToAbsent
          ? const Value.absent()
          : Value(impressionTags),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
      lastMeetDate: lastMeetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMeetDate),
      contactFrequency: contactFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(contactFrequency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory FriendRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      birthday: serializer.fromJson<DateTime?>(json['birthday']),
      contact: serializer.fromJson<String?>(json['contact']),
      meetWay: serializer.fromJson<String?>(json['meetWay']),
      meetDate: serializer.fromJson<DateTime?>(json['meetDate']),
      impressionTags: serializer.fromJson<String?>(json['impressionTags']),
      groupName: serializer.fromJson<String?>(json['groupName']),
      lastMeetDate: serializer.fromJson<DateTime?>(json['lastMeetDate']),
      contactFrequency: serializer.fromJson<String?>(json['contactFrequency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'birthday': serializer.toJson<DateTime?>(birthday),
      'contact': serializer.toJson<String?>(contact),
      'meetWay': serializer.toJson<String?>(meetWay),
      'meetDate': serializer.toJson<DateTime?>(meetDate),
      'impressionTags': serializer.toJson<String?>(impressionTags),
      'groupName': serializer.toJson<String?>(groupName),
      'lastMeetDate': serializer.toJson<DateTime?>(lastMeetDate),
      'contactFrequency': serializer.toJson<String?>(contactFrequency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  FriendRecord copyWith(
          {String? id,
          String? name,
          Value<String?> avatarPath = const Value.absent(),
          Value<DateTime?> birthday = const Value.absent(),
          Value<String?> contact = const Value.absent(),
          Value<String?> meetWay = const Value.absent(),
          Value<DateTime?> meetDate = const Value.absent(),
          Value<String?> impressionTags = const Value.absent(),
          Value<String?> groupName = const Value.absent(),
          Value<DateTime?> lastMeetDate = const Value.absent(),
          Value<String?> contactFrequency = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted}) =>
      FriendRecord(
        id: id ?? this.id,
        name: name ?? this.name,
        avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
        birthday: birthday.present ? birthday.value : this.birthday,
        contact: contact.present ? contact.value : this.contact,
        meetWay: meetWay.present ? meetWay.value : this.meetWay,
        meetDate: meetDate.present ? meetDate.value : this.meetDate,
        impressionTags:
            impressionTags.present ? impressionTags.value : this.impressionTags,
        groupName: groupName.present ? groupName.value : this.groupName,
        lastMeetDate:
            lastMeetDate.present ? lastMeetDate.value : this.lastMeetDate,
        contactFrequency: contactFrequency.present
            ? contactFrequency.value
            : this.contactFrequency,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  FriendRecord copyWithCompanion(FriendRecordsCompanion data) {
    return FriendRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarPath:
          data.avatarPath.present ? data.avatarPath.value : this.avatarPath,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      contact: data.contact.present ? data.contact.value : this.contact,
      meetWay: data.meetWay.present ? data.meetWay.value : this.meetWay,
      meetDate: data.meetDate.present ? data.meetDate.value : this.meetDate,
      impressionTags: data.impressionTags.present
          ? data.impressionTags.value
          : this.impressionTags,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      lastMeetDate: data.lastMeetDate.present
          ? data.lastMeetDate.value
          : this.lastMeetDate,
      contactFrequency: data.contactFrequency.present
          ? data.contactFrequency.value
          : this.contactFrequency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FriendRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('birthday: $birthday, ')
          ..write('contact: $contact, ')
          ..write('meetWay: $meetWay, ')
          ..write('meetDate: $meetDate, ')
          ..write('impressionTags: $impressionTags, ')
          ..write('groupName: $groupName, ')
          ..write('lastMeetDate: $lastMeetDate, ')
          ..write('contactFrequency: $contactFrequency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      avatarPath,
      birthday,
      contact,
      meetWay,
      meetDate,
      impressionTags,
      groupName,
      lastMeetDate,
      contactFrequency,
      createdAt,
      updatedAt,
      isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarPath == this.avatarPath &&
          other.birthday == this.birthday &&
          other.contact == this.contact &&
          other.meetWay == this.meetWay &&
          other.meetDate == this.meetDate &&
          other.impressionTags == this.impressionTags &&
          other.groupName == this.groupName &&
          other.lastMeetDate == this.lastMeetDate &&
          other.contactFrequency == this.contactFrequency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class FriendRecordsCompanion extends UpdateCompanion<FriendRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> avatarPath;
  final Value<DateTime?> birthday;
  final Value<String?> contact;
  final Value<String?> meetWay;
  final Value<DateTime?> meetDate;
  final Value<String?> impressionTags;
  final Value<String?> groupName;
  final Value<DateTime?> lastMeetDate;
  final Value<String?> contactFrequency;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const FriendRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.birthday = const Value.absent(),
    this.contact = const Value.absent(),
    this.meetWay = const Value.absent(),
    this.meetDate = const Value.absent(),
    this.impressionTags = const Value.absent(),
    this.groupName = const Value.absent(),
    this.lastMeetDate = const Value.absent(),
    this.contactFrequency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendRecordsCompanion.insert({
    required String id,
    required String name,
    this.avatarPath = const Value.absent(),
    this.birthday = const Value.absent(),
    this.contact = const Value.absent(),
    this.meetWay = const Value.absent(),
    this.meetDate = const Value.absent(),
    this.impressionTags = const Value.absent(),
    this.groupName = const Value.absent(),
    this.lastMeetDate = const Value.absent(),
    this.contactFrequency = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FriendRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? avatarPath,
    Expression<DateTime>? birthday,
    Expression<String>? contact,
    Expression<String>? meetWay,
    Expression<DateTime>? meetDate,
    Expression<String>? impressionTags,
    Expression<String>? groupName,
    Expression<DateTime>? lastMeetDate,
    Expression<String>? contactFrequency,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (birthday != null) 'birthday': birthday,
      if (contact != null) 'contact': contact,
      if (meetWay != null) 'meet_way': meetWay,
      if (meetDate != null) 'meet_date': meetDate,
      if (impressionTags != null) 'impression_tags': impressionTags,
      if (groupName != null) 'group_name': groupName,
      if (lastMeetDate != null) 'last_meet_date': lastMeetDate,
      if (contactFrequency != null) 'contact_frequency': contactFrequency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? avatarPath,
      Value<DateTime?>? birthday,
      Value<String?>? contact,
      Value<String?>? meetWay,
      Value<DateTime?>? meetDate,
      Value<String?>? impressionTags,
      Value<String?>? groupName,
      Value<DateTime?>? lastMeetDate,
      Value<String?>? contactFrequency,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return FriendRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      birthday: birthday ?? this.birthday,
      contact: contact ?? this.contact,
      meetWay: meetWay ?? this.meetWay,
      meetDate: meetDate ?? this.meetDate,
      impressionTags: impressionTags ?? this.impressionTags,
      groupName: groupName ?? this.groupName,
      lastMeetDate: lastMeetDate ?? this.lastMeetDate,
      contactFrequency: contactFrequency ?? this.contactFrequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (meetWay.present) {
      map['meet_way'] = Variable<String>(meetWay.value);
    }
    if (meetDate.present) {
      map['meet_date'] = Variable<DateTime>(meetDate.value);
    }
    if (impressionTags.present) {
      map['impression_tags'] = Variable<String>(impressionTags.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (lastMeetDate.present) {
      map['last_meet_date'] = Variable<DateTime>(lastMeetDate.value);
    }
    if (contactFrequency.present) {
      map['contact_frequency'] = Variable<String>(contactFrequency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('birthday: $birthday, ')
          ..write('contact: $contact, ')
          ..write('meetWay: $meetWay, ')
          ..write('meetDate: $meetDate, ')
          ..write('impressionTags: $impressionTags, ')
          ..write('groupName: $groupName, ')
          ..write('lastMeetDate: $lastMeetDate, ')
          ..write('contactFrequency: $contactFrequency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimelineEventsTable extends TimelineEvents
    with TableInfo<$TimelineEventsTable, TimelineEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startAtMeta =
      const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
      'start_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
      'end_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordDateMeta =
      const VerificationMeta('recordDate');
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
      'record_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        eventType,
        startAt,
        endAt,
        note,
        recordDate,
        createdAt,
        updatedAt,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_events';
  @override
  VerificationContext validateIntegrity(Insertable<TimelineEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta,
          startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    }
    if (data.containsKey('end_at')) {
      context.handle(
          _endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('record_date')) {
      context.handle(
          _recordDateMeta,
          recordDate.isAcceptableOrUnknown(
              data['record_date']!, _recordDateMeta));
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      startAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_at']),
      endAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_at']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      recordDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}record_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $TimelineEventsTable createAlias(String alias) {
    return $TimelineEventsTable(attachedDatabase, alias);
  }
}

class TimelineEvent extends DataClass implements Insertable<TimelineEvent> {
  final String id;
  final String title;
  final String eventType;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? note;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const TimelineEvent(
      {required this.id,
      required this.title,
      required this.eventType,
      this.startAt,
      this.endAt,
      this.note,
      required this.recordDate,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || startAt != null) {
      map['start_at'] = Variable<DateTime>(startAt);
    }
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TimelineEventsCompanion toCompanion(bool nullToAbsent) {
    return TimelineEventsCompanion(
      id: Value(id),
      title: Value(title),
      eventType: Value(eventType),
      startAt: startAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startAt),
      endAt:
          endAt == null && nullToAbsent ? const Value.absent() : Value(endAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory TimelineEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineEvent(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      eventType: serializer.fromJson<String>(json['eventType']),
      startAt: serializer.fromJson<DateTime?>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      note: serializer.fromJson<String?>(json['note']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'eventType': serializer.toJson<String>(eventType),
      'startAt': serializer.toJson<DateTime?>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'note': serializer.toJson<String?>(note),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  TimelineEvent copyWith(
          {String? id,
          String? title,
          String? eventType,
          Value<DateTime?> startAt = const Value.absent(),
          Value<DateTime?> endAt = const Value.absent(),
          Value<String?> note = const Value.absent(),
          DateTime? recordDate,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted}) =>
      TimelineEvent(
        id: id ?? this.id,
        title: title ?? this.title,
        eventType: eventType ?? this.eventType,
        startAt: startAt.present ? startAt.value : this.startAt,
        endAt: endAt.present ? endAt.value : this.endAt,
        note: note.present ? note.value : this.note,
        recordDate: recordDate ?? this.recordDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  TimelineEvent copyWithCompanion(TimelineEventsCompanion data) {
    return TimelineEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      note: data.note.present ? data.note.value : this.note,
      recordDate:
          data.recordDate.present ? data.recordDate.value : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('eventType: $eventType, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('note: $note, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, eventType, startAt, endAt, note,
      recordDate, createdAt, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.eventType == this.eventType &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.note == this.note &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class TimelineEventsCompanion extends UpdateCompanion<TimelineEvent> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> eventType;
  final Value<DateTime?> startAt;
  final Value<DateTime?> endAt;
  final Value<String?> note;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const TimelineEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.eventType = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.note = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimelineEventsCompanion.insert({
    required String id,
    required String title,
    required String eventType,
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime recordDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        eventType = Value(eventType),
        recordDate = Value(recordDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TimelineEvent> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? eventType,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<String>? note,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (eventType != null) 'event_type': eventType,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (note != null) 'note': note,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimelineEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? eventType,
      Value<DateTime?>? startAt,
      Value<DateTime?>? endAt,
      Value<String?>? note,
      Value<DateTime>? recordDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return TimelineEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      eventType: eventType ?? this.eventType,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      note: note ?? this.note,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('eventType: $eventType, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('note: $note, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityLinksTable extends EntityLinks
    with TableInfo<$EntityLinksTable, EntityLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetTypeMeta =
      const VerificationMeta('targetType');
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
      'target_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _linkTypeMeta =
      const VerificationMeta('linkType');
  @override
  late final GeneratedColumn<String> linkType = GeneratedColumn<String>(
      'link_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sourceType, sourceId, targetType, targetId, linkType, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_links';
  @override
  VerificationContext validateIntegrity(Insertable<EntityLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
          _targetTypeMeta,
          targetType.isAcceptableOrUnknown(
              data['target_type']!, _targetTypeMeta));
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('link_type')) {
      context.handle(_linkTypeMeta,
          linkType.isAcceptableOrUnknown(data['link_type']!, _linkTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {sourceType, sourceId, targetType, targetId},
      ];
  @override
  EntityLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityLink(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      targetType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_type'])!,
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id'])!,
      linkType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EntityLinksTable createAlias(String alias) {
    return $EntityLinksTable(attachedDatabase, alias);
  }
}

class EntityLink extends DataClass implements Insertable<EntityLink> {
  final String id;
  final String sourceType;
  final String sourceId;
  final String targetType;
  final String targetId;
  final String linkType;
  final DateTime createdAt;
  const EntityLink(
      {required this.id,
      required this.sourceType,
      required this.sourceId,
      required this.targetType,
      required this.targetId,
      required this.linkType,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    map['link_type'] = Variable<String>(linkType);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EntityLinksCompanion toCompanion(bool nullToAbsent) {
    return EntityLinksCompanion(
      id: Value(id),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      targetType: Value(targetType),
      targetId: Value(targetId),
      linkType: Value(linkType),
      createdAt: Value(createdAt),
    );
  }

  factory EntityLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityLink(
      id: serializer.fromJson<String>(json['id']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
      linkType: serializer.fromJson<String>(json['linkType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
      'linkType': serializer.toJson<String>(linkType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EntityLink copyWith(
          {String? id,
          String? sourceType,
          String? sourceId,
          String? targetType,
          String? targetId,
          String? linkType,
          DateTime? createdAt}) =>
      EntityLink(
        id: id ?? this.id,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
        targetType: targetType ?? this.targetType,
        targetId: targetId ?? this.targetId,
        linkType: linkType ?? this.linkType,
        createdAt: createdAt ?? this.createdAt,
      );
  EntityLink copyWithCompanion(EntityLinksCompanion data) {
    return EntityLink(
      id: data.id.present ? data.id.value : this.id,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      targetType:
          data.targetType.present ? data.targetType.value : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      linkType: data.linkType.present ? data.linkType.value : this.linkType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityLink(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('linkType: $linkType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, sourceType, sourceId, targetType, targetId, linkType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityLink &&
          other.id == this.id &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.linkType == this.linkType &&
          other.createdAt == this.createdAt);
}

class EntityLinksCompanion extends UpdateCompanion<EntityLink> {
  final Value<String> id;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<String> linkType;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EntityLinksCompanion({
    this.id = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.linkType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntityLinksCompanion.insert({
    required String id,
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    this.linkType = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        targetType = Value(targetType),
        targetId = Value(targetId),
        createdAt = Value(createdAt);
  static Insertable<EntityLink> custom({
    Expression<String>? id,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? linkType,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (linkType != null) 'link_type': linkType,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntityLinksCompanion copyWith(
      {Value<String>? id,
      Value<String>? sourceType,
      Value<String>? sourceId,
      Value<String>? targetType,
      Value<String>? targetId,
      Value<String>? linkType,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return EntityLinksCompanion(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      linkType: linkType ?? this.linkType,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (linkType.present) {
      map['link_type'] = Variable<String>(linkType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityLinksCompanion(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('linkType: $linkType, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinkLogsTable extends LinkLogs with TableInfo<$LinkLogsTable, LinkLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinkLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetTypeMeta =
      const VerificationMeta('targetType');
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
      'target_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _linkTypeMeta =
      const VerificationMeta('linkType');
  @override
  late final GeneratedColumn<String> linkType = GeneratedColumn<String>(
      'link_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourceType,
        sourceId,
        targetType,
        targetId,
        action,
        linkType,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'link_logs';
  @override
  VerificationContext validateIntegrity(Insertable<LinkLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
          _targetTypeMeta,
          targetType.isAcceptableOrUnknown(
              data['target_type']!, _targetTypeMeta));
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('link_type')) {
      context.handle(_linkTypeMeta,
          linkType.isAcceptableOrUnknown(data['link_type']!, _linkTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LinkLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinkLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      targetType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_type'])!,
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      linkType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link_type']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LinkLogsTable createAlias(String alias) {
    return $LinkLogsTable(attachedDatabase, alias);
  }
}

class LinkLog extends DataClass implements Insertable<LinkLog> {
  final String id;
  final String sourceType;
  final String sourceId;
  final String targetType;
  final String targetId;
  final String action;
  final String? linkType;
  final DateTime createdAt;
  const LinkLog(
      {required this.id,
      required this.sourceType,
      required this.sourceId,
      required this.targetType,
      required this.targetId,
      required this.action,
      this.linkType,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || linkType != null) {
      map['link_type'] = Variable<String>(linkType);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LinkLogsCompanion toCompanion(bool nullToAbsent) {
    return LinkLogsCompanion(
      id: Value(id),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      targetType: Value(targetType),
      targetId: Value(targetId),
      action: Value(action),
      linkType: linkType == null && nullToAbsent
          ? const Value.absent()
          : Value(linkType),
      createdAt: Value(createdAt),
    );
  }

  factory LinkLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinkLog(
      id: serializer.fromJson<String>(json['id']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
      action: serializer.fromJson<String>(json['action']),
      linkType: serializer.fromJson<String?>(json['linkType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
      'action': serializer.toJson<String>(action),
      'linkType': serializer.toJson<String?>(linkType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LinkLog copyWith(
          {String? id,
          String? sourceType,
          String? sourceId,
          String? targetType,
          String? targetId,
          String? action,
          Value<String?> linkType = const Value.absent(),
          DateTime? createdAt}) =>
      LinkLog(
        id: id ?? this.id,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
        targetType: targetType ?? this.targetType,
        targetId: targetId ?? this.targetId,
        action: action ?? this.action,
        linkType: linkType.present ? linkType.value : this.linkType,
        createdAt: createdAt ?? this.createdAt,
      );
  LinkLog copyWithCompanion(LinkLogsCompanion data) {
    return LinkLog(
      id: data.id.present ? data.id.value : this.id,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      targetType:
          data.targetType.present ? data.targetType.value : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      action: data.action.present ? data.action.value : this.action,
      linkType: data.linkType.present ? data.linkType.value : this.linkType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinkLog(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('action: $action, ')
          ..write('linkType: $linkType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceType, sourceId, targetType,
      targetId, action, linkType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinkLog &&
          other.id == this.id &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.action == this.action &&
          other.linkType == this.linkType &&
          other.createdAt == this.createdAt);
}

class LinkLogsCompanion extends UpdateCompanion<LinkLog> {
  final Value<String> id;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<String> action;
  final Value<String?> linkType;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LinkLogsCompanion({
    this.id = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.action = const Value.absent(),
    this.linkType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinkLogsCompanion.insert({
    required String id,
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    required String action,
    this.linkType = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        targetType = Value(targetType),
        targetId = Value(targetId),
        action = Value(action),
        createdAt = Value(createdAt);
  static Insertable<LinkLog> custom({
    Expression<String>? id,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? action,
    Expression<String>? linkType,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (action != null) 'action': action,
      if (linkType != null) 'link_type': linkType,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinkLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sourceType,
      Value<String>? sourceId,
      Value<String>? targetType,
      Value<String>? targetId,
      Value<String>? action,
      Value<String?>? linkType,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LinkLogsCompanion(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      action: action ?? this.action,
      linkType: linkType ?? this.linkType,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (linkType.present) {
      map['link_type'] = Variable<String>(linkType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinkLogsCompanion(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('action: $action, ')
          ..write('linkType: $linkType, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodRecordsTable foodRecords = $FoodRecordsTable(this);
  late final $MomentRecordsTable momentRecords = $MomentRecordsTable(this);
  late final $FriendRecordsTable friendRecords = $FriendRecordsTable(this);
  late final $TimelineEventsTable timelineEvents = $TimelineEventsTable(this);
  late final $EntityLinksTable entityLinks = $EntityLinksTable(this);
  late final $LinkLogsTable linkLogs = $LinkLogsTable(this);
  late final FoodDao foodDao = FoodDao(this as AppDatabase);
  late final MomentDao momentDao = MomentDao(this as AppDatabase);
  late final FriendDao friendDao = FriendDao(this as AppDatabase);
  late final LinkDao linkDao = LinkDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        foodRecords,
        momentRecords,
        friendRecords,
        timelineEvents,
        entityLinks,
        linkLogs
      ];
}

typedef $$FoodRecordsTableCreateCompanionBuilder = FoodRecordsCompanion
    Function({
  required String id,
  required String title,
  Value<String?> content,
  Value<String?> images,
  Value<String?> tags,
  Value<double?> rating,
  Value<double?> pricePerPerson,
  Value<String?> link,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> poiName,
  Value<String?> city,
  Value<String?> mood,
  Value<bool> isWishlist,
  Value<bool> wishlistDone,
  required DateTime recordDate,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$FoodRecordsTableUpdateCompanionBuilder = FoodRecordsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String?> content,
  Value<String?> images,
  Value<String?> tags,
  Value<double?> rating,
  Value<double?> pricePerPerson,
  Value<String?> link,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> poiName,
  Value<String?> city,
  Value<String?> mood,
  Value<bool> isWishlist,
  Value<bool> wishlistDone,
  Value<DateTime> recordDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$FoodRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodRecordsTable> {
  $$FoodRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get images => $composableBuilder(
      column: $table.images, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pricePerPerson => $composableBuilder(
      column: $table.pricePerPerson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get link => $composableBuilder(
      column: $table.link, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poiName => $composableBuilder(
      column: $table.poiName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wishlistDone => $composableBuilder(
      column: $table.wishlistDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
}

class $$FoodRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodRecordsTable> {
  $$FoodRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get images => $composableBuilder(
      column: $table.images, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pricePerPerson => $composableBuilder(
      column: $table.pricePerPerson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get link => $composableBuilder(
      column: $table.link, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poiName => $composableBuilder(
      column: $table.poiName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wishlistDone => $composableBuilder(
      column: $table.wishlistDone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$FoodRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodRecordsTable> {
  $$FoodRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<double> get pricePerPerson => $composableBuilder(
      column: $table.pricePerPerson, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get poiName =>
      $composableBuilder(column: $table.poiName, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => column);

  GeneratedColumn<bool> get wishlistDone => $composableBuilder(
      column: $table.wishlistDone, builder: (column) => column);

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$FoodRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoodRecordsTable,
    FoodRecord,
    $$FoodRecordsTableFilterComposer,
    $$FoodRecordsTableOrderingComposer,
    $$FoodRecordsTableAnnotationComposer,
    $$FoodRecordsTableCreateCompanionBuilder,
    $$FoodRecordsTableUpdateCompanionBuilder,
    (FoodRecord, BaseReferences<_$AppDatabase, $FoodRecordsTable, FoodRecord>),
    FoodRecord,
    PrefetchHooks Function()> {
  $$FoodRecordsTableTableManager(_$AppDatabase db, $FoodRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> images = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<double?> rating = const Value.absent(),
            Value<double?> pricePerPerson = const Value.absent(),
            Value<String?> link = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> poiName = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> mood = const Value.absent(),
            Value<bool> isWishlist = const Value.absent(),
            Value<bool> wishlistDone = const Value.absent(),
            Value<DateTime> recordDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoodRecordsCompanion(
            id: id,
            title: title,
            content: content,
            images: images,
            tags: tags,
            rating: rating,
            pricePerPerson: pricePerPerson,
            link: link,
            latitude: latitude,
            longitude: longitude,
            poiName: poiName,
            city: city,
            mood: mood,
            isWishlist: isWishlist,
            wishlistDone: wishlistDone,
            recordDate: recordDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> content = const Value.absent(),
            Value<String?> images = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<double?> rating = const Value.absent(),
            Value<double?> pricePerPerson = const Value.absent(),
            Value<String?> link = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> poiName = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> mood = const Value.absent(),
            Value<bool> isWishlist = const Value.absent(),
            Value<bool> wishlistDone = const Value.absent(),
            required DateTime recordDate,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoodRecordsCompanion.insert(
            id: id,
            title: title,
            content: content,
            images: images,
            tags: tags,
            rating: rating,
            pricePerPerson: pricePerPerson,
            link: link,
            latitude: latitude,
            longitude: longitude,
            poiName: poiName,
            city: city,
            mood: mood,
            isWishlist: isWishlist,
            wishlistDone: wishlistDone,
            recordDate: recordDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoodRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoodRecordsTable,
    FoodRecord,
    $$FoodRecordsTableFilterComposer,
    $$FoodRecordsTableOrderingComposer,
    $$FoodRecordsTableAnnotationComposer,
    $$FoodRecordsTableCreateCompanionBuilder,
    $$FoodRecordsTableUpdateCompanionBuilder,
    (FoodRecord, BaseReferences<_$AppDatabase, $FoodRecordsTable, FoodRecord>),
    FoodRecord,
    PrefetchHooks Function()>;
typedef $$MomentRecordsTableCreateCompanionBuilder = MomentRecordsCompanion
    Function({
  required String id,
  Value<String?> content,
  Value<String?> images,
  required String mood,
  Value<String?> moodColor,
  Value<String?> sceneTag,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> city,
  required DateTime recordDate,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$MomentRecordsTableUpdateCompanionBuilder = MomentRecordsCompanion
    Function({
  Value<String> id,
  Value<String?> content,
  Value<String?> images,
  Value<String> mood,
  Value<String?> moodColor,
  Value<String?> sceneTag,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> city,
  Value<DateTime> recordDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$MomentRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MomentRecordsTable> {
  $$MomentRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get images => $composableBuilder(
      column: $table.images, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get moodColor => $composableBuilder(
      column: $table.moodColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sceneTag => $composableBuilder(
      column: $table.sceneTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
}

class $$MomentRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MomentRecordsTable> {
  $$MomentRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get images => $composableBuilder(
      column: $table.images, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moodColor => $composableBuilder(
      column: $table.moodColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sceneTag => $composableBuilder(
      column: $table.sceneTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$MomentRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MomentRecordsTable> {
  $$MomentRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get moodColor =>
      $composableBuilder(column: $table.moodColor, builder: (column) => column);

  GeneratedColumn<String> get sceneTag =>
      $composableBuilder(column: $table.sceneTag, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$MomentRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MomentRecordsTable,
    MomentRecord,
    $$MomentRecordsTableFilterComposer,
    $$MomentRecordsTableOrderingComposer,
    $$MomentRecordsTableAnnotationComposer,
    $$MomentRecordsTableCreateCompanionBuilder,
    $$MomentRecordsTableUpdateCompanionBuilder,
    (
      MomentRecord,
      BaseReferences<_$AppDatabase, $MomentRecordsTable, MomentRecord>
    ),
    MomentRecord,
    PrefetchHooks Function()> {
  $$MomentRecordsTableTableManager(_$AppDatabase db, $MomentRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MomentRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MomentRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MomentRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> images = const Value.absent(),
            Value<String> mood = const Value.absent(),
            Value<String?> moodColor = const Value.absent(),
            Value<String?> sceneTag = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<DateTime> recordDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MomentRecordsCompanion(
            id: id,
            content: content,
            images: images,
            mood: mood,
            moodColor: moodColor,
            sceneTag: sceneTag,
            latitude: latitude,
            longitude: longitude,
            city: city,
            recordDate: recordDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> content = const Value.absent(),
            Value<String?> images = const Value.absent(),
            required String mood,
            Value<String?> moodColor = const Value.absent(),
            Value<String?> sceneTag = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> city = const Value.absent(),
            required DateTime recordDate,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MomentRecordsCompanion.insert(
            id: id,
            content: content,
            images: images,
            mood: mood,
            moodColor: moodColor,
            sceneTag: sceneTag,
            latitude: latitude,
            longitude: longitude,
            city: city,
            recordDate: recordDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MomentRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MomentRecordsTable,
    MomentRecord,
    $$MomentRecordsTableFilterComposer,
    $$MomentRecordsTableOrderingComposer,
    $$MomentRecordsTableAnnotationComposer,
    $$MomentRecordsTableCreateCompanionBuilder,
    $$MomentRecordsTableUpdateCompanionBuilder,
    (
      MomentRecord,
      BaseReferences<_$AppDatabase, $MomentRecordsTable, MomentRecord>
    ),
    MomentRecord,
    PrefetchHooks Function()>;
typedef $$FriendRecordsTableCreateCompanionBuilder = FriendRecordsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> avatarPath,
  Value<DateTime?> birthday,
  Value<String?> contact,
  Value<String?> meetWay,
  Value<DateTime?> meetDate,
  Value<String?> impressionTags,
  Value<String?> groupName,
  Value<DateTime?> lastMeetDate,
  Value<String?> contactFrequency,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$FriendRecordsTableUpdateCompanionBuilder = FriendRecordsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> avatarPath,
  Value<DateTime?> birthday,
  Value<String?> contact,
  Value<String?> meetWay,
  Value<DateTime?> meetDate,
  Value<String?> impressionTags,
  Value<String?> groupName,
  Value<DateTime?> lastMeetDate,
  Value<String?> contactFrequency,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$FriendRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FriendRecordsTable> {
  $$FriendRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthday => $composableBuilder(
      column: $table.birthday, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contact => $composableBuilder(
      column: $table.contact, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meetWay => $composableBuilder(
      column: $table.meetWay, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get meetDate => $composableBuilder(
      column: $table.meetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get impressionTags => $composableBuilder(
      column: $table.impressionTags,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMeetDate => $composableBuilder(
      column: $table.lastMeetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactFrequency => $composableBuilder(
      column: $table.contactFrequency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
}

class $$FriendRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendRecordsTable> {
  $$FriendRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthday => $composableBuilder(
      column: $table.birthday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contact => $composableBuilder(
      column: $table.contact, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meetWay => $composableBuilder(
      column: $table.meetWay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get meetDate => $composableBuilder(
      column: $table.meetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get impressionTags => $composableBuilder(
      column: $table.impressionTags,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMeetDate => $composableBuilder(
      column: $table.lastMeetDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactFrequency => $composableBuilder(
      column: $table.contactFrequency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$FriendRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendRecordsTable> {
  $$FriendRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => column);

  GeneratedColumn<DateTime> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<String> get meetWay =>
      $composableBuilder(column: $table.meetWay, builder: (column) => column);

  GeneratedColumn<DateTime> get meetDate =>
      $composableBuilder(column: $table.meetDate, builder: (column) => column);

  GeneratedColumn<String> get impressionTags => $composableBuilder(
      column: $table.impressionTags, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMeetDate => $composableBuilder(
      column: $table.lastMeetDate, builder: (column) => column);

  GeneratedColumn<String> get contactFrequency => $composableBuilder(
      column: $table.contactFrequency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$FriendRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FriendRecordsTable,
    FriendRecord,
    $$FriendRecordsTableFilterComposer,
    $$FriendRecordsTableOrderingComposer,
    $$FriendRecordsTableAnnotationComposer,
    $$FriendRecordsTableCreateCompanionBuilder,
    $$FriendRecordsTableUpdateCompanionBuilder,
    (
      FriendRecord,
      BaseReferences<_$AppDatabase, $FriendRecordsTable, FriendRecord>
    ),
    FriendRecord,
    PrefetchHooks Function()> {
  $$FriendRecordsTableTableManager(_$AppDatabase db, $FriendRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FriendRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FriendRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FriendRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> avatarPath = const Value.absent(),
            Value<DateTime?> birthday = const Value.absent(),
            Value<String?> contact = const Value.absent(),
            Value<String?> meetWay = const Value.absent(),
            Value<DateTime?> meetDate = const Value.absent(),
            Value<String?> impressionTags = const Value.absent(),
            Value<String?> groupName = const Value.absent(),
            Value<DateTime?> lastMeetDate = const Value.absent(),
            Value<String?> contactFrequency = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FriendRecordsCompanion(
            id: id,
            name: name,
            avatarPath: avatarPath,
            birthday: birthday,
            contact: contact,
            meetWay: meetWay,
            meetDate: meetDate,
            impressionTags: impressionTags,
            groupName: groupName,
            lastMeetDate: lastMeetDate,
            contactFrequency: contactFrequency,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> avatarPath = const Value.absent(),
            Value<DateTime?> birthday = const Value.absent(),
            Value<String?> contact = const Value.absent(),
            Value<String?> meetWay = const Value.absent(),
            Value<DateTime?> meetDate = const Value.absent(),
            Value<String?> impressionTags = const Value.absent(),
            Value<String?> groupName = const Value.absent(),
            Value<DateTime?> lastMeetDate = const Value.absent(),
            Value<String?> contactFrequency = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FriendRecordsCompanion.insert(
            id: id,
            name: name,
            avatarPath: avatarPath,
            birthday: birthday,
            contact: contact,
            meetWay: meetWay,
            meetDate: meetDate,
            impressionTags: impressionTags,
            groupName: groupName,
            lastMeetDate: lastMeetDate,
            contactFrequency: contactFrequency,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FriendRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FriendRecordsTable,
    FriendRecord,
    $$FriendRecordsTableFilterComposer,
    $$FriendRecordsTableOrderingComposer,
    $$FriendRecordsTableAnnotationComposer,
    $$FriendRecordsTableCreateCompanionBuilder,
    $$FriendRecordsTableUpdateCompanionBuilder,
    (
      FriendRecord,
      BaseReferences<_$AppDatabase, $FriendRecordsTable, FriendRecord>
    ),
    FriendRecord,
    PrefetchHooks Function()>;
typedef $$TimelineEventsTableCreateCompanionBuilder = TimelineEventsCompanion
    Function({
  required String id,
  required String title,
  required String eventType,
  Value<DateTime?> startAt,
  Value<DateTime?> endAt,
  Value<String?> note,
  required DateTime recordDate,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$TimelineEventsTableUpdateCompanionBuilder = TimelineEventsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> eventType,
  Value<DateTime?> startAt,
  Value<DateTime?> endAt,
  Value<String?> note,
  Value<DateTime> recordDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$TimelineEventsTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineEventsTable> {
  $$TimelineEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
}

class $$TimelineEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineEventsTable> {
  $$TimelineEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$TimelineEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineEventsTable> {
  $$TimelineEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$TimelineEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TimelineEventsTable,
    TimelineEvent,
    $$TimelineEventsTableFilterComposer,
    $$TimelineEventsTableOrderingComposer,
    $$TimelineEventsTableAnnotationComposer,
    $$TimelineEventsTableCreateCompanionBuilder,
    $$TimelineEventsTableUpdateCompanionBuilder,
    (
      TimelineEvent,
      BaseReferences<_$AppDatabase, $TimelineEventsTable, TimelineEvent>
    ),
    TimelineEvent,
    PrefetchHooks Function()> {
  $$TimelineEventsTableTableManager(
      _$AppDatabase db, $TimelineEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<DateTime?> startAt = const Value.absent(),
            Value<DateTime?> endAt = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> recordDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TimelineEventsCompanion(
            id: id,
            title: title,
            eventType: eventType,
            startAt: startAt,
            endAt: endAt,
            note: note,
            recordDate: recordDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String eventType,
            Value<DateTime?> startAt = const Value.absent(),
            Value<DateTime?> endAt = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required DateTime recordDate,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TimelineEventsCompanion.insert(
            id: id,
            title: title,
            eventType: eventType,
            startAt: startAt,
            endAt: endAt,
            note: note,
            recordDate: recordDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TimelineEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TimelineEventsTable,
    TimelineEvent,
    $$TimelineEventsTableFilterComposer,
    $$TimelineEventsTableOrderingComposer,
    $$TimelineEventsTableAnnotationComposer,
    $$TimelineEventsTableCreateCompanionBuilder,
    $$TimelineEventsTableUpdateCompanionBuilder,
    (
      TimelineEvent,
      BaseReferences<_$AppDatabase, $TimelineEventsTable, TimelineEvent>
    ),
    TimelineEvent,
    PrefetchHooks Function()>;
typedef $$EntityLinksTableCreateCompanionBuilder = EntityLinksCompanion
    Function({
  required String id,
  required String sourceType,
  required String sourceId,
  required String targetType,
  required String targetId,
  Value<String> linkType,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$EntityLinksTableUpdateCompanionBuilder = EntityLinksCompanion
    Function({
  Value<String> id,
  Value<String> sourceType,
  Value<String> sourceId,
  Value<String> targetType,
  Value<String> targetId,
  Value<String> linkType,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$EntityLinksTableFilterComposer
    extends Composer<_$AppDatabase, $EntityLinksTable> {
  $$EntityLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkType => $composableBuilder(
      column: $table.linkType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$EntityLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $EntityLinksTable> {
  $$EntityLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkType => $composableBuilder(
      column: $table.linkType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$EntityLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntityLinksTable> {
  $$EntityLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get linkType =>
      $composableBuilder(column: $table.linkType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EntityLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EntityLinksTable,
    EntityLink,
    $$EntityLinksTableFilterComposer,
    $$EntityLinksTableOrderingComposer,
    $$EntityLinksTableAnnotationComposer,
    $$EntityLinksTableCreateCompanionBuilder,
    $$EntityLinksTableUpdateCompanionBuilder,
    (EntityLink, BaseReferences<_$AppDatabase, $EntityLinksTable, EntityLink>),
    EntityLink,
    PrefetchHooks Function()> {
  $$EntityLinksTableTableManager(_$AppDatabase db, $EntityLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> targetType = const Value.absent(),
            Value<String> targetId = const Value.absent(),
            Value<String> linkType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntityLinksCompanion(
            id: id,
            sourceType: sourceType,
            sourceId: sourceId,
            targetType: targetType,
            targetId: targetId,
            linkType: linkType,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sourceType,
            required String sourceId,
            required String targetType,
            required String targetId,
            Value<String> linkType = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              EntityLinksCompanion.insert(
            id: id,
            sourceType: sourceType,
            sourceId: sourceId,
            targetType: targetType,
            targetId: targetId,
            linkType: linkType,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EntityLinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EntityLinksTable,
    EntityLink,
    $$EntityLinksTableFilterComposer,
    $$EntityLinksTableOrderingComposer,
    $$EntityLinksTableAnnotationComposer,
    $$EntityLinksTableCreateCompanionBuilder,
    $$EntityLinksTableUpdateCompanionBuilder,
    (EntityLink, BaseReferences<_$AppDatabase, $EntityLinksTable, EntityLink>),
    EntityLink,
    PrefetchHooks Function()>;
typedef $$LinkLogsTableCreateCompanionBuilder = LinkLogsCompanion Function({
  required String id,
  required String sourceType,
  required String sourceId,
  required String targetType,
  required String targetId,
  required String action,
  Value<String?> linkType,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$LinkLogsTableUpdateCompanionBuilder = LinkLogsCompanion Function({
  Value<String> id,
  Value<String> sourceType,
  Value<String> sourceId,
  Value<String> targetType,
  Value<String> targetId,
  Value<String> action,
  Value<String?> linkType,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LinkLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LinkLogsTable> {
  $$LinkLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkType => $composableBuilder(
      column: $table.linkType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LinkLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LinkLogsTable> {
  $$LinkLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkType => $composableBuilder(
      column: $table.linkType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LinkLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LinkLogsTable> {
  $$LinkLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get linkType =>
      $composableBuilder(column: $table.linkType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LinkLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LinkLogsTable,
    LinkLog,
    $$LinkLogsTableFilterComposer,
    $$LinkLogsTableOrderingComposer,
    $$LinkLogsTableAnnotationComposer,
    $$LinkLogsTableCreateCompanionBuilder,
    $$LinkLogsTableUpdateCompanionBuilder,
    (LinkLog, BaseReferences<_$AppDatabase, $LinkLogsTable, LinkLog>),
    LinkLog,
    PrefetchHooks Function()> {
  $$LinkLogsTableTableManager(_$AppDatabase db, $LinkLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinkLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinkLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinkLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> targetType = const Value.absent(),
            Value<String> targetId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String?> linkType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LinkLogsCompanion(
            id: id,
            sourceType: sourceType,
            sourceId: sourceId,
            targetType: targetType,
            targetId: targetId,
            action: action,
            linkType: linkType,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sourceType,
            required String sourceId,
            required String targetType,
            required String targetId,
            required String action,
            Value<String?> linkType = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LinkLogsCompanion.insert(
            id: id,
            sourceType: sourceType,
            sourceId: sourceId,
            targetType: targetType,
            targetId: targetId,
            action: action,
            linkType: linkType,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LinkLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LinkLogsTable,
    LinkLog,
    $$LinkLogsTableFilterComposer,
    $$LinkLogsTableOrderingComposer,
    $$LinkLogsTableAnnotationComposer,
    $$LinkLogsTableCreateCompanionBuilder,
    $$LinkLogsTableUpdateCompanionBuilder,
    (LinkLog, BaseReferences<_$AppDatabase, $LinkLogsTable, LinkLog>),
    LinkLog,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodRecordsTableTableManager get foodRecords =>
      $$FoodRecordsTableTableManager(_db, _db.foodRecords);
  $$MomentRecordsTableTableManager get momentRecords =>
      $$MomentRecordsTableTableManager(_db, _db.momentRecords);
  $$FriendRecordsTableTableManager get friendRecords =>
      $$FriendRecordsTableTableManager(_db, _db.friendRecords);
  $$TimelineEventsTableTableManager get timelineEvents =>
      $$TimelineEventsTableTableManager(_db, _db.timelineEvents);
  $$EntityLinksTableTableManager get entityLinks =>
      $$EntityLinksTableTableManager(_db, _db.entityLinks);
  $$LinkLogsTableTableManager get linkLogs =>
      $$LinkLogsTableTableManager(_db, _db.linkLogs);
}

mixin _$FoodDaoMixin on DatabaseAccessor<AppDatabase> {
  $FoodRecordsTable get foodRecords => attachedDatabase.foodRecords;
  FoodDaoManager get managers => FoodDaoManager(this);
}

class FoodDaoManager {
  final _$FoodDaoMixin _db;
  FoodDaoManager(this._db);
  $$FoodRecordsTableTableManager get foodRecords =>
      $$FoodRecordsTableTableManager(_db.attachedDatabase, _db.foodRecords);
}

mixin _$MomentDaoMixin on DatabaseAccessor<AppDatabase> {
  $MomentRecordsTable get momentRecords => attachedDatabase.momentRecords;
  MomentDaoManager get managers => MomentDaoManager(this);
}

class MomentDaoManager {
  final _$MomentDaoMixin _db;
  MomentDaoManager(this._db);
  $$MomentRecordsTableTableManager get momentRecords =>
      $$MomentRecordsTableTableManager(_db.attachedDatabase, _db.momentRecords);
}

mixin _$FriendDaoMixin on DatabaseAccessor<AppDatabase> {
  $FriendRecordsTable get friendRecords => attachedDatabase.friendRecords;
  FriendDaoManager get managers => FriendDaoManager(this);
}

class FriendDaoManager {
  final _$FriendDaoMixin _db;
  FriendDaoManager(this._db);
  $$FriendRecordsTableTableManager get friendRecords =>
      $$FriendRecordsTableTableManager(_db.attachedDatabase, _db.friendRecords);
}

mixin _$LinkDaoMixin on DatabaseAccessor<AppDatabase> {
  $EntityLinksTable get entityLinks => attachedDatabase.entityLinks;
  $LinkLogsTable get linkLogs => attachedDatabase.linkLogs;
  LinkDaoManager get managers => LinkDaoManager(this);
}

class LinkDaoManager {
  final _$LinkDaoMixin _db;
  LinkDaoManager(this._db);
  $$EntityLinksTableTableManager get entityLinks =>
      $$EntityLinksTableTableManager(_db.attachedDatabase, _db.entityLinks);
  $$LinkLogsTableTableManager get linkLogs =>
      $$LinkLogsTableTableManager(_db.attachedDatabase, _db.linkLogs);
}
