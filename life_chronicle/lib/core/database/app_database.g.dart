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
  static const VerificationMeta _poiAddressMeta =
      const VerificationMeta('poiAddress');
  @override
  late final GeneratedColumn<String> poiAddress = GeneratedColumn<String>(
      'poi_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _countryMeta =
      const VerificationMeta('country');
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
      'country', aliasedName, true,
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
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
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
        poiAddress,
        city,
        country,
        mood,
        isWishlist,
        isFavorite,
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
    if (data.containsKey('poi_address')) {
      context.handle(
          _poiAddressMeta,
          poiAddress.isAcceptableOrUnknown(
              data['poi_address']!, _poiAddressMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('country')) {
      context.handle(_countryMeta,
          country.isAcceptableOrUnknown(data['country']!, _countryMeta));
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
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
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
      poiAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_address']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      country: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country']),
      mood: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood']),
      isWishlist: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_wishlist'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
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
  final String? poiAddress;
  final String? city;
  final String? country;
  final String? mood;
  final bool isWishlist;
  final bool isFavorite;
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
      this.poiAddress,
      this.city,
      this.country,
      this.mood,
      required this.isWishlist,
      required this.isFavorite,
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
    if (!nullToAbsent || poiAddress != null) {
      map['poi_address'] = Variable<String>(poiAddress);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    map['is_wishlist'] = Variable<bool>(isWishlist);
    map['is_favorite'] = Variable<bool>(isFavorite);
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
      poiAddress: poiAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(poiAddress),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      isWishlist: Value(isWishlist),
      isFavorite: Value(isFavorite),
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
      poiAddress: serializer.fromJson<String?>(json['poiAddress']),
      city: serializer.fromJson<String?>(json['city']),
      country: serializer.fromJson<String?>(json['country']),
      mood: serializer.fromJson<String?>(json['mood']),
      isWishlist: serializer.fromJson<bool>(json['isWishlist']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
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
      'poiAddress': serializer.toJson<String?>(poiAddress),
      'city': serializer.toJson<String?>(city),
      'country': serializer.toJson<String?>(country),
      'mood': serializer.toJson<String?>(mood),
      'isWishlist': serializer.toJson<bool>(isWishlist),
      'isFavorite': serializer.toJson<bool>(isFavorite),
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
          Value<String?> poiAddress = const Value.absent(),
          Value<String?> city = const Value.absent(),
          Value<String?> country = const Value.absent(),
          Value<String?> mood = const Value.absent(),
          bool? isWishlist,
          bool? isFavorite,
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
        poiAddress: poiAddress.present ? poiAddress.value : this.poiAddress,
        city: city.present ? city.value : this.city,
        country: country.present ? country.value : this.country,
        mood: mood.present ? mood.value : this.mood,
        isWishlist: isWishlist ?? this.isWishlist,
        isFavorite: isFavorite ?? this.isFavorite,
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
      poiAddress:
          data.poiAddress.present ? data.poiAddress.value : this.poiAddress,
      city: data.city.present ? data.city.value : this.city,
      country: data.country.present ? data.country.value : this.country,
      mood: data.mood.present ? data.mood.value : this.mood,
      isWishlist:
          data.isWishlist.present ? data.isWishlist.value : this.isWishlist,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
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
          ..write('poiAddress: $poiAddress, ')
          ..write('city: $city, ')
          ..write('country: $country, ')
          ..write('mood: $mood, ')
          ..write('isWishlist: $isWishlist, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('wishlistDone: $wishlistDone, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
        poiAddress,
        city,
        country,
        mood,
        isWishlist,
        isFavorite,
        wishlistDone,
        recordDate,
        createdAt,
        updatedAt,
        isDeleted
      ]);
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
          other.poiAddress == this.poiAddress &&
          other.city == this.city &&
          other.country == this.country &&
          other.mood == this.mood &&
          other.isWishlist == this.isWishlist &&
          other.isFavorite == this.isFavorite &&
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
  final Value<String?> poiAddress;
  final Value<String?> city;
  final Value<String?> country;
  final Value<String?> mood;
  final Value<bool> isWishlist;
  final Value<bool> isFavorite;
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
    this.poiAddress = const Value.absent(),
    this.city = const Value.absent(),
    this.country = const Value.absent(),
    this.mood = const Value.absent(),
    this.isWishlist = const Value.absent(),
    this.isFavorite = const Value.absent(),
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
    this.poiAddress = const Value.absent(),
    this.city = const Value.absent(),
    this.country = const Value.absent(),
    this.mood = const Value.absent(),
    this.isWishlist = const Value.absent(),
    this.isFavorite = const Value.absent(),
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
    Expression<String>? poiAddress,
    Expression<String>? city,
    Expression<String>? country,
    Expression<String>? mood,
    Expression<bool>? isWishlist,
    Expression<bool>? isFavorite,
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
      if (poiAddress != null) 'poi_address': poiAddress,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (mood != null) 'mood': mood,
      if (isWishlist != null) 'is_wishlist': isWishlist,
      if (isFavorite != null) 'is_favorite': isFavorite,
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
      Value<String?>? poiAddress,
      Value<String?>? city,
      Value<String?>? country,
      Value<String?>? mood,
      Value<bool>? isWishlist,
      Value<bool>? isFavorite,
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
      poiAddress: poiAddress ?? this.poiAddress,
      city: city ?? this.city,
      country: country ?? this.country,
      mood: mood ?? this.mood,
      isWishlist: isWishlist ?? this.isWishlist,
      isFavorite: isFavorite ?? this.isFavorite,
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
    if (poiAddress.present) {
      map['poi_address'] = Variable<String>(poiAddress.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (isWishlist.present) {
      map['is_wishlist'] = Variable<bool>(isWishlist.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
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
          ..write('poiAddress: $poiAddress, ')
          ..write('city: $city, ')
          ..write('country: $country, ')
          ..write('mood: $mood, ')
          ..write('isWishlist: $isWishlist, ')
          ..write('isFavorite: $isFavorite, ')
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
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _poiNameMeta =
      const VerificationMeta('poiName');
  @override
  late final GeneratedColumn<String> poiName = GeneratedColumn<String>(
      'poi_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _poiAddressMeta =
      const VerificationMeta('poiAddress');
  @override
  late final GeneratedColumn<String> poiAddress = GeneratedColumn<String>(
      'poi_address', aliasedName, true,
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
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
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
        content,
        images,
        mood,
        moodColor,
        tags,
        poiName,
        poiAddress,
        latitude,
        longitude,
        city,
        isFavorite,
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
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('poi_name')) {
      context.handle(_poiNameMeta,
          poiName.isAcceptableOrUnknown(data['poi_name']!, _poiNameMeta));
    }
    if (data.containsKey('poi_address')) {
      context.handle(
          _poiAddressMeta,
          poiAddress.isAcceptableOrUnknown(
              data['poi_address']!, _poiAddressMeta));
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
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
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
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      poiName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_name']),
      poiAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_address']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
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
  final String? tags;
  final String? poiName;
  final String? poiAddress;
  final double? latitude;
  final double? longitude;
  final String? city;
  final bool isFavorite;
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
      this.tags,
      this.poiName,
      this.poiAddress,
      this.latitude,
      this.longitude,
      this.city,
      required this.isFavorite,
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
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || poiName != null) {
      map['poi_name'] = Variable<String>(poiName);
    }
    if (!nullToAbsent || poiAddress != null) {
      map['poi_address'] = Variable<String>(poiAddress);
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
    map['is_favorite'] = Variable<bool>(isFavorite);
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
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      poiName: poiName == null && nullToAbsent
          ? const Value.absent()
          : Value(poiName),
      poiAddress: poiAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(poiAddress),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      isFavorite: Value(isFavorite),
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
      tags: serializer.fromJson<String?>(json['tags']),
      poiName: serializer.fromJson<String?>(json['poiName']),
      poiAddress: serializer.fromJson<String?>(json['poiAddress']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      city: serializer.fromJson<String?>(json['city']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
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
      'tags': serializer.toJson<String?>(tags),
      'poiName': serializer.toJson<String?>(poiName),
      'poiAddress': serializer.toJson<String?>(poiAddress),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'city': serializer.toJson<String?>(city),
      'isFavorite': serializer.toJson<bool>(isFavorite),
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
          Value<String?> tags = const Value.absent(),
          Value<String?> poiName = const Value.absent(),
          Value<String?> poiAddress = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> city = const Value.absent(),
          bool? isFavorite,
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
        tags: tags.present ? tags.value : this.tags,
        poiName: poiName.present ? poiName.value : this.poiName,
        poiAddress: poiAddress.present ? poiAddress.value : this.poiAddress,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        city: city.present ? city.value : this.city,
        isFavorite: isFavorite ?? this.isFavorite,
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
      tags: data.tags.present ? data.tags.value : this.tags,
      poiName: data.poiName.present ? data.poiName.value : this.poiName,
      poiAddress:
          data.poiAddress.present ? data.poiAddress.value : this.poiAddress,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      city: data.city.present ? data.city.value : this.city,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
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
          ..write('tags: $tags, ')
          ..write('poiName: $poiName, ')
          ..write('poiAddress: $poiAddress, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('city: $city, ')
          ..write('isFavorite: $isFavorite, ')
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
      tags,
      poiName,
      poiAddress,
      latitude,
      longitude,
      city,
      isFavorite,
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
          other.tags == this.tags &&
          other.poiName == this.poiName &&
          other.poiAddress == this.poiAddress &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.city == this.city &&
          other.isFavorite == this.isFavorite &&
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
  final Value<String?> tags;
  final Value<String?> poiName;
  final Value<String?> poiAddress;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> city;
  final Value<bool> isFavorite;
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
    this.tags = const Value.absent(),
    this.poiName = const Value.absent(),
    this.poiAddress = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.city = const Value.absent(),
    this.isFavorite = const Value.absent(),
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
    this.tags = const Value.absent(),
    this.poiName = const Value.absent(),
    this.poiAddress = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.city = const Value.absent(),
    this.isFavorite = const Value.absent(),
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
    Expression<String>? tags,
    Expression<String>? poiName,
    Expression<String>? poiAddress,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? city,
    Expression<bool>? isFavorite,
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
      if (tags != null) 'tags': tags,
      if (poiName != null) 'poi_name': poiName,
      if (poiAddress != null) 'poi_address': poiAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (city != null) 'city': city,
      if (isFavorite != null) 'is_favorite': isFavorite,
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
      Value<String?>? tags,
      Value<String?>? poiName,
      Value<String?>? poiAddress,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? city,
      Value<bool>? isFavorite,
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
      tags: tags ?? this.tags,
      poiName: poiName ?? this.poiName,
      poiAddress: poiAddress ?? this.poiAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      isFavorite: isFavorite ?? this.isFavorite,
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
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (poiName.present) {
      map['poi_name'] = Variable<String>(poiName.value);
    }
    if (poiAddress.present) {
      map['poi_address'] = Variable<String>(poiAddress.value);
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
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
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
          ..write('tags: $tags, ')
          ..write('poiName: $poiName, ')
          ..write('poiAddress: $poiAddress, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('city: $city, ')
          ..write('isFavorite: $isFavorite, ')
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
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
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
        isFavorite,
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
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
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
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
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
  final bool isFavorite;
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
      required this.isFavorite,
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
    map['is_favorite'] = Variable<bool>(isFavorite);
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
      isFavorite: Value(isFavorite),
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
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
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
      'isFavorite': serializer.toJson<bool>(isFavorite),
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
          bool? isFavorite,
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
        isFavorite: isFavorite ?? this.isFavorite,
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
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
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
          ..write('isFavorite: $isFavorite, ')
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
      isFavorite,
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
          other.isFavorite == this.isFavorite &&
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
  final Value<bool> isFavorite;
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
    this.isFavorite = const Value.absent(),
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
    this.isFavorite = const Value.absent(),
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
    Expression<bool>? isFavorite,
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
      if (isFavorite != null) 'is_favorite': isFavorite,
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
      Value<bool>? isFavorite,
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
      isFavorite: isFavorite ?? this.isFavorite,
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
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
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
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TravelRecordsTable extends TravelRecords
    with TableInfo<$TravelRecordsTable, TravelRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TravelRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
      'trip_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _destinationMeta =
      const VerificationMeta('destination');
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
      'destination', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _poiNameMeta =
      const VerificationMeta('poiName');
  @override
  late final GeneratedColumn<String> poiName = GeneratedColumn<String>(
      'poi_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _poiAddressMeta =
      const VerificationMeta('poiAddress');
  @override
  late final GeneratedColumn<String> poiAddress = GeneratedColumn<String>(
      'poi_address', aliasedName, true,
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
  static const VerificationMeta _countryMeta =
      const VerificationMeta('country');
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
      'country', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
      'mood', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expenseTransportMeta =
      const VerificationMeta('expenseTransport');
  @override
  late final GeneratedColumn<double> expenseTransport = GeneratedColumn<double>(
      'expense_transport', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _expenseHotelMeta =
      const VerificationMeta('expenseHotel');
  @override
  late final GeneratedColumn<double> expenseHotel = GeneratedColumn<double>(
      'expense_hotel', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _expenseFoodMeta =
      const VerificationMeta('expenseFood');
  @override
  late final GeneratedColumn<double> expenseFood = GeneratedColumn<double>(
      'expense_food', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _expenseTicketMeta =
      const VerificationMeta('expenseTicket');
  @override
  late final GeneratedColumn<double> expenseTicket = GeneratedColumn<double>(
      'expense_ticket', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _flightLinkMeta =
      const VerificationMeta('flightLink');
  @override
  late final GeneratedColumn<String> flightLink = GeneratedColumn<String>(
      'flight_link', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hotelLinkMeta =
      const VerificationMeta('hotelLink');
  @override
  late final GeneratedColumn<String> hotelLink = GeneratedColumn<String>(
      'hotel_link', aliasedName, true,
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
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
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
  static const VerificationMeta _isJournalMeta =
      const VerificationMeta('isJournal');
  @override
  late final GeneratedColumn<bool> isJournal = GeneratedColumn<bool>(
      'is_journal', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_journal" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _planDateMeta =
      const VerificationMeta('planDate');
  @override
  late final GeneratedColumn<DateTime> planDate = GeneratedColumn<DateTime>(
      'plan_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        tripId,
        title,
        content,
        images,
        destination,
        poiName,
        poiAddress,
        latitude,
        longitude,
        city,
        country,
        mood,
        tags,
        expenseTransport,
        expenseHotel,
        expenseFood,
        expenseTicket,
        flightLink,
        hotelLink,
        isWishlist,
        isFavorite,
        wishlistDone,
        isJournal,
        planDate,
        recordDate,
        createdAt,
        updatedAt,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'travel_records';
  @override
  VerificationContext validateIntegrity(Insertable<TravelRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('images')) {
      context.handle(_imagesMeta,
          images.isAcceptableOrUnknown(data['images']!, _imagesMeta));
    }
    if (data.containsKey('destination')) {
      context.handle(
          _destinationMeta,
          destination.isAcceptableOrUnknown(
              data['destination']!, _destinationMeta));
    }
    if (data.containsKey('poi_name')) {
      context.handle(_poiNameMeta,
          poiName.isAcceptableOrUnknown(data['poi_name']!, _poiNameMeta));
    }
    if (data.containsKey('poi_address')) {
      context.handle(
          _poiAddressMeta,
          poiAddress.isAcceptableOrUnknown(
              data['poi_address']!, _poiAddressMeta));
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
    if (data.containsKey('country')) {
      context.handle(_countryMeta,
          country.isAcceptableOrUnknown(data['country']!, _countryMeta));
    }
    if (data.containsKey('mood')) {
      context.handle(
          _moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('expense_transport')) {
      context.handle(
          _expenseTransportMeta,
          expenseTransport.isAcceptableOrUnknown(
              data['expense_transport']!, _expenseTransportMeta));
    }
    if (data.containsKey('expense_hotel')) {
      context.handle(
          _expenseHotelMeta,
          expenseHotel.isAcceptableOrUnknown(
              data['expense_hotel']!, _expenseHotelMeta));
    }
    if (data.containsKey('expense_food')) {
      context.handle(
          _expenseFoodMeta,
          expenseFood.isAcceptableOrUnknown(
              data['expense_food']!, _expenseFoodMeta));
    }
    if (data.containsKey('expense_ticket')) {
      context.handle(
          _expenseTicketMeta,
          expenseTicket.isAcceptableOrUnknown(
              data['expense_ticket']!, _expenseTicketMeta));
    }
    if (data.containsKey('flight_link')) {
      context.handle(
          _flightLinkMeta,
          flightLink.isAcceptableOrUnknown(
              data['flight_link']!, _flightLinkMeta));
    }
    if (data.containsKey('hotel_link')) {
      context.handle(_hotelLinkMeta,
          hotelLink.isAcceptableOrUnknown(data['hotel_link']!, _hotelLinkMeta));
    }
    if (data.containsKey('is_wishlist')) {
      context.handle(
          _isWishlistMeta,
          isWishlist.isAcceptableOrUnknown(
              data['is_wishlist']!, _isWishlistMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('wishlist_done')) {
      context.handle(
          _wishlistDoneMeta,
          wishlistDone.isAcceptableOrUnknown(
              data['wishlist_done']!, _wishlistDoneMeta));
    }
    if (data.containsKey('is_journal')) {
      context.handle(_isJournalMeta,
          isJournal.isAcceptableOrUnknown(data['is_journal']!, _isJournalMeta));
    }
    if (data.containsKey('plan_date')) {
      context.handle(_planDateMeta,
          planDate.isAcceptableOrUnknown(data['plan_date']!, _planDateMeta));
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
  TravelRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TravelRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      images: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images']),
      destination: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destination']),
      poiName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_name']),
      poiAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_address']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      country: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country']),
      mood: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      expenseTransport: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}expense_transport']),
      expenseHotel: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}expense_hotel']),
      expenseFood: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}expense_food']),
      expenseTicket: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}expense_ticket']),
      flightLink: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flight_link']),
      hotelLink: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hotel_link']),
      isWishlist: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_wishlist'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      wishlistDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}wishlist_done'])!,
      isJournal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_journal'])!,
      planDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}plan_date']),
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
  $TravelRecordsTable createAlias(String alias) {
    return $TravelRecordsTable(attachedDatabase, alias);
  }
}

class TravelRecord extends DataClass implements Insertable<TravelRecord> {
  final String id;
  final String tripId;
  final String? title;
  final String? content;
  final String? images;
  final String? destination;
  final String? poiName;
  final String? poiAddress;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String? mood;
  final String? tags;
  final double? expenseTransport;
  final double? expenseHotel;
  final double? expenseFood;
  final double? expenseTicket;
  final String? flightLink;
  final String? hotelLink;
  final bool isWishlist;
  final bool isFavorite;
  final bool wishlistDone;
  final bool isJournal;
  final DateTime? planDate;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const TravelRecord(
      {required this.id,
      required this.tripId,
      this.title,
      this.content,
      this.images,
      this.destination,
      this.poiName,
      this.poiAddress,
      this.latitude,
      this.longitude,
      this.city,
      this.country,
      this.mood,
      this.tags,
      this.expenseTransport,
      this.expenseHotel,
      this.expenseFood,
      this.expenseTicket,
      this.flightLink,
      this.hotelLink,
      required this.isWishlist,
      required this.isFavorite,
      required this.wishlistDone,
      required this.isJournal,
      this.planDate,
      required this.recordDate,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || images != null) {
      map['images'] = Variable<String>(images);
    }
    if (!nullToAbsent || destination != null) {
      map['destination'] = Variable<String>(destination);
    }
    if (!nullToAbsent || poiName != null) {
      map['poi_name'] = Variable<String>(poiName);
    }
    if (!nullToAbsent || poiAddress != null) {
      map['poi_address'] = Variable<String>(poiAddress);
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
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || expenseTransport != null) {
      map['expense_transport'] = Variable<double>(expenseTransport);
    }
    if (!nullToAbsent || expenseHotel != null) {
      map['expense_hotel'] = Variable<double>(expenseHotel);
    }
    if (!nullToAbsent || expenseFood != null) {
      map['expense_food'] = Variable<double>(expenseFood);
    }
    if (!nullToAbsent || expenseTicket != null) {
      map['expense_ticket'] = Variable<double>(expenseTicket);
    }
    if (!nullToAbsent || flightLink != null) {
      map['flight_link'] = Variable<String>(flightLink);
    }
    if (!nullToAbsent || hotelLink != null) {
      map['hotel_link'] = Variable<String>(hotelLink);
    }
    map['is_wishlist'] = Variable<bool>(isWishlist);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['wishlist_done'] = Variable<bool>(wishlistDone);
    map['is_journal'] = Variable<bool>(isJournal);
    if (!nullToAbsent || planDate != null) {
      map['plan_date'] = Variable<DateTime>(planDate);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TravelRecordsCompanion toCompanion(bool nullToAbsent) {
    return TravelRecordsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      images:
          images == null && nullToAbsent ? const Value.absent() : Value(images),
      destination: destination == null && nullToAbsent
          ? const Value.absent()
          : Value(destination),
      poiName: poiName == null && nullToAbsent
          ? const Value.absent()
          : Value(poiName),
      poiAddress: poiAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(poiAddress),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      expenseTransport: expenseTransport == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseTransport),
      expenseHotel: expenseHotel == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseHotel),
      expenseFood: expenseFood == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseFood),
      expenseTicket: expenseTicket == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseTicket),
      flightLink: flightLink == null && nullToAbsent
          ? const Value.absent()
          : Value(flightLink),
      hotelLink: hotelLink == null && nullToAbsent
          ? const Value.absent()
          : Value(hotelLink),
      isWishlist: Value(isWishlist),
      isFavorite: Value(isFavorite),
      wishlistDone: Value(wishlistDone),
      isJournal: Value(isJournal),
      planDate: planDate == null && nullToAbsent
          ? const Value.absent()
          : Value(planDate),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory TravelRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TravelRecord(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      title: serializer.fromJson<String?>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      images: serializer.fromJson<String?>(json['images']),
      destination: serializer.fromJson<String?>(json['destination']),
      poiName: serializer.fromJson<String?>(json['poiName']),
      poiAddress: serializer.fromJson<String?>(json['poiAddress']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      city: serializer.fromJson<String?>(json['city']),
      country: serializer.fromJson<String?>(json['country']),
      mood: serializer.fromJson<String?>(json['mood']),
      tags: serializer.fromJson<String?>(json['tags']),
      expenseTransport: serializer.fromJson<double?>(json['expenseTransport']),
      expenseHotel: serializer.fromJson<double?>(json['expenseHotel']),
      expenseFood: serializer.fromJson<double?>(json['expenseFood']),
      expenseTicket: serializer.fromJson<double?>(json['expenseTicket']),
      flightLink: serializer.fromJson<String?>(json['flightLink']),
      hotelLink: serializer.fromJson<String?>(json['hotelLink']),
      isWishlist: serializer.fromJson<bool>(json['isWishlist']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      wishlistDone: serializer.fromJson<bool>(json['wishlistDone']),
      isJournal: serializer.fromJson<bool>(json['isJournal']),
      planDate: serializer.fromJson<DateTime?>(json['planDate']),
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
      'tripId': serializer.toJson<String>(tripId),
      'title': serializer.toJson<String?>(title),
      'content': serializer.toJson<String?>(content),
      'images': serializer.toJson<String?>(images),
      'destination': serializer.toJson<String?>(destination),
      'poiName': serializer.toJson<String?>(poiName),
      'poiAddress': serializer.toJson<String?>(poiAddress),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'city': serializer.toJson<String?>(city),
      'country': serializer.toJson<String?>(country),
      'mood': serializer.toJson<String?>(mood),
      'tags': serializer.toJson<String?>(tags),
      'expenseTransport': serializer.toJson<double?>(expenseTransport),
      'expenseHotel': serializer.toJson<double?>(expenseHotel),
      'expenseFood': serializer.toJson<double?>(expenseFood),
      'expenseTicket': serializer.toJson<double?>(expenseTicket),
      'flightLink': serializer.toJson<String?>(flightLink),
      'hotelLink': serializer.toJson<String?>(hotelLink),
      'isWishlist': serializer.toJson<bool>(isWishlist),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'wishlistDone': serializer.toJson<bool>(wishlistDone),
      'isJournal': serializer.toJson<bool>(isJournal),
      'planDate': serializer.toJson<DateTime?>(planDate),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  TravelRecord copyWith(
          {String? id,
          String? tripId,
          Value<String?> title = const Value.absent(),
          Value<String?> content = const Value.absent(),
          Value<String?> images = const Value.absent(),
          Value<String?> destination = const Value.absent(),
          Value<String?> poiName = const Value.absent(),
          Value<String?> poiAddress = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> city = const Value.absent(),
          Value<String?> country = const Value.absent(),
          Value<String?> mood = const Value.absent(),
          Value<String?> tags = const Value.absent(),
          Value<double?> expenseTransport = const Value.absent(),
          Value<double?> expenseHotel = const Value.absent(),
          Value<double?> expenseFood = const Value.absent(),
          Value<double?> expenseTicket = const Value.absent(),
          Value<String?> flightLink = const Value.absent(),
          Value<String?> hotelLink = const Value.absent(),
          bool? isWishlist,
          bool? isFavorite,
          bool? wishlistDone,
          bool? isJournal,
          Value<DateTime?> planDate = const Value.absent(),
          DateTime? recordDate,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted}) =>
      TravelRecord(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        title: title.present ? title.value : this.title,
        content: content.present ? content.value : this.content,
        images: images.present ? images.value : this.images,
        destination: destination.present ? destination.value : this.destination,
        poiName: poiName.present ? poiName.value : this.poiName,
        poiAddress: poiAddress.present ? poiAddress.value : this.poiAddress,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        city: city.present ? city.value : this.city,
        country: country.present ? country.value : this.country,
        mood: mood.present ? mood.value : this.mood,
        tags: tags.present ? tags.value : this.tags,
        expenseTransport: expenseTransport.present
            ? expenseTransport.value
            : this.expenseTransport,
        expenseHotel:
            expenseHotel.present ? expenseHotel.value : this.expenseHotel,
        expenseFood: expenseFood.present ? expenseFood.value : this.expenseFood,
        expenseTicket:
            expenseTicket.present ? expenseTicket.value : this.expenseTicket,
        flightLink: flightLink.present ? flightLink.value : this.flightLink,
        hotelLink: hotelLink.present ? hotelLink.value : this.hotelLink,
        isWishlist: isWishlist ?? this.isWishlist,
        isFavorite: isFavorite ?? this.isFavorite,
        wishlistDone: wishlistDone ?? this.wishlistDone,
        isJournal: isJournal ?? this.isJournal,
        planDate: planDate.present ? planDate.value : this.planDate,
        recordDate: recordDate ?? this.recordDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  TravelRecord copyWithCompanion(TravelRecordsCompanion data) {
    return TravelRecord(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      images: data.images.present ? data.images.value : this.images,
      destination:
          data.destination.present ? data.destination.value : this.destination,
      poiName: data.poiName.present ? data.poiName.value : this.poiName,
      poiAddress:
          data.poiAddress.present ? data.poiAddress.value : this.poiAddress,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      city: data.city.present ? data.city.value : this.city,
      country: data.country.present ? data.country.value : this.country,
      mood: data.mood.present ? data.mood.value : this.mood,
      tags: data.tags.present ? data.tags.value : this.tags,
      expenseTransport: data.expenseTransport.present
          ? data.expenseTransport.value
          : this.expenseTransport,
      expenseHotel: data.expenseHotel.present
          ? data.expenseHotel.value
          : this.expenseHotel,
      expenseFood:
          data.expenseFood.present ? data.expenseFood.value : this.expenseFood,
      expenseTicket: data.expenseTicket.present
          ? data.expenseTicket.value
          : this.expenseTicket,
      flightLink:
          data.flightLink.present ? data.flightLink.value : this.flightLink,
      hotelLink: data.hotelLink.present ? data.hotelLink.value : this.hotelLink,
      isWishlist:
          data.isWishlist.present ? data.isWishlist.value : this.isWishlist,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      wishlistDone: data.wishlistDone.present
          ? data.wishlistDone.value
          : this.wishlistDone,
      isJournal: data.isJournal.present ? data.isJournal.value : this.isJournal,
      planDate: data.planDate.present ? data.planDate.value : this.planDate,
      recordDate:
          data.recordDate.present ? data.recordDate.value : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TravelRecord(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('images: $images, ')
          ..write('destination: $destination, ')
          ..write('poiName: $poiName, ')
          ..write('poiAddress: $poiAddress, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('city: $city, ')
          ..write('country: $country, ')
          ..write('mood: $mood, ')
          ..write('tags: $tags, ')
          ..write('expenseTransport: $expenseTransport, ')
          ..write('expenseHotel: $expenseHotel, ')
          ..write('expenseFood: $expenseFood, ')
          ..write('expenseTicket: $expenseTicket, ')
          ..write('flightLink: $flightLink, ')
          ..write('hotelLink: $hotelLink, ')
          ..write('isWishlist: $isWishlist, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('wishlistDone: $wishlistDone, ')
          ..write('isJournal: $isJournal, ')
          ..write('planDate: $planDate, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        tripId,
        title,
        content,
        images,
        destination,
        poiName,
        poiAddress,
        latitude,
        longitude,
        city,
        country,
        mood,
        tags,
        expenseTransport,
        expenseHotel,
        expenseFood,
        expenseTicket,
        flightLink,
        hotelLink,
        isWishlist,
        isFavorite,
        wishlistDone,
        isJournal,
        planDate,
        recordDate,
        createdAt,
        updatedAt,
        isDeleted
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TravelRecord &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.title == this.title &&
          other.content == this.content &&
          other.images == this.images &&
          other.destination == this.destination &&
          other.poiName == this.poiName &&
          other.poiAddress == this.poiAddress &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.city == this.city &&
          other.country == this.country &&
          other.mood == this.mood &&
          other.tags == this.tags &&
          other.expenseTransport == this.expenseTransport &&
          other.expenseHotel == this.expenseHotel &&
          other.expenseFood == this.expenseFood &&
          other.expenseTicket == this.expenseTicket &&
          other.flightLink == this.flightLink &&
          other.hotelLink == this.hotelLink &&
          other.isWishlist == this.isWishlist &&
          other.isFavorite == this.isFavorite &&
          other.wishlistDone == this.wishlistDone &&
          other.isJournal == this.isJournal &&
          other.planDate == this.planDate &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class TravelRecordsCompanion extends UpdateCompanion<TravelRecord> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String?> title;
  final Value<String?> content;
  final Value<String?> images;
  final Value<String?> destination;
  final Value<String?> poiName;
  final Value<String?> poiAddress;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> city;
  final Value<String?> country;
  final Value<String?> mood;
  final Value<String?> tags;
  final Value<double?> expenseTransport;
  final Value<double?> expenseHotel;
  final Value<double?> expenseFood;
  final Value<double?> expenseTicket;
  final Value<String?> flightLink;
  final Value<String?> hotelLink;
  final Value<bool> isWishlist;
  final Value<bool> isFavorite;
  final Value<bool> wishlistDone;
  final Value<bool> isJournal;
  final Value<DateTime?> planDate;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const TravelRecordsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.images = const Value.absent(),
    this.destination = const Value.absent(),
    this.poiName = const Value.absent(),
    this.poiAddress = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.city = const Value.absent(),
    this.country = const Value.absent(),
    this.mood = const Value.absent(),
    this.tags = const Value.absent(),
    this.expenseTransport = const Value.absent(),
    this.expenseHotel = const Value.absent(),
    this.expenseFood = const Value.absent(),
    this.expenseTicket = const Value.absent(),
    this.flightLink = const Value.absent(),
    this.hotelLink = const Value.absent(),
    this.isWishlist = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.wishlistDone = const Value.absent(),
    this.isJournal = const Value.absent(),
    this.planDate = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TravelRecordsCompanion.insert({
    required String id,
    required String tripId,
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.images = const Value.absent(),
    this.destination = const Value.absent(),
    this.poiName = const Value.absent(),
    this.poiAddress = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.city = const Value.absent(),
    this.country = const Value.absent(),
    this.mood = const Value.absent(),
    this.tags = const Value.absent(),
    this.expenseTransport = const Value.absent(),
    this.expenseHotel = const Value.absent(),
    this.expenseFood = const Value.absent(),
    this.expenseTicket = const Value.absent(),
    this.flightLink = const Value.absent(),
    this.hotelLink = const Value.absent(),
    this.isWishlist = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.wishlistDone = const Value.absent(),
    this.isJournal = const Value.absent(),
    this.planDate = const Value.absent(),
    required DateTime recordDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        recordDate = Value(recordDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TravelRecord> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? images,
    Expression<String>? destination,
    Expression<String>? poiName,
    Expression<String>? poiAddress,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? city,
    Expression<String>? country,
    Expression<String>? mood,
    Expression<String>? tags,
    Expression<double>? expenseTransport,
    Expression<double>? expenseHotel,
    Expression<double>? expenseFood,
    Expression<double>? expenseTicket,
    Expression<String>? flightLink,
    Expression<String>? hotelLink,
    Expression<bool>? isWishlist,
    Expression<bool>? isFavorite,
    Expression<bool>? wishlistDone,
    Expression<bool>? isJournal,
    Expression<DateTime>? planDate,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (images != null) 'images': images,
      if (destination != null) 'destination': destination,
      if (poiName != null) 'poi_name': poiName,
      if (poiAddress != null) 'poi_address': poiAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (mood != null) 'mood': mood,
      if (tags != null) 'tags': tags,
      if (expenseTransport != null) 'expense_transport': expenseTransport,
      if (expenseHotel != null) 'expense_hotel': expenseHotel,
      if (expenseFood != null) 'expense_food': expenseFood,
      if (expenseTicket != null) 'expense_ticket': expenseTicket,
      if (flightLink != null) 'flight_link': flightLink,
      if (hotelLink != null) 'hotel_link': hotelLink,
      if (isWishlist != null) 'is_wishlist': isWishlist,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (wishlistDone != null) 'wishlist_done': wishlistDone,
      if (isJournal != null) 'is_journal': isJournal,
      if (planDate != null) 'plan_date': planDate,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TravelRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String?>? title,
      Value<String?>? content,
      Value<String?>? images,
      Value<String?>? destination,
      Value<String?>? poiName,
      Value<String?>? poiAddress,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? city,
      Value<String?>? country,
      Value<String?>? mood,
      Value<String?>? tags,
      Value<double?>? expenseTransport,
      Value<double?>? expenseHotel,
      Value<double?>? expenseFood,
      Value<double?>? expenseTicket,
      Value<String?>? flightLink,
      Value<String?>? hotelLink,
      Value<bool>? isWishlist,
      Value<bool>? isFavorite,
      Value<bool>? wishlistDone,
      Value<bool>? isJournal,
      Value<DateTime?>? planDate,
      Value<DateTime>? recordDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return TravelRecordsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      destination: destination ?? this.destination,
      poiName: poiName ?? this.poiName,
      poiAddress: poiAddress ?? this.poiAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      expenseTransport: expenseTransport ?? this.expenseTransport,
      expenseHotel: expenseHotel ?? this.expenseHotel,
      expenseFood: expenseFood ?? this.expenseFood,
      expenseTicket: expenseTicket ?? this.expenseTicket,
      flightLink: flightLink ?? this.flightLink,
      hotelLink: hotelLink ?? this.hotelLink,
      isWishlist: isWishlist ?? this.isWishlist,
      isFavorite: isFavorite ?? this.isFavorite,
      wishlistDone: wishlistDone ?? this.wishlistDone,
      isJournal: isJournal ?? this.isJournal,
      planDate: planDate ?? this.planDate,
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
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
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
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (poiName.present) {
      map['poi_name'] = Variable<String>(poiName.value);
    }
    if (poiAddress.present) {
      map['poi_address'] = Variable<String>(poiAddress.value);
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
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (expenseTransport.present) {
      map['expense_transport'] = Variable<double>(expenseTransport.value);
    }
    if (expenseHotel.present) {
      map['expense_hotel'] = Variable<double>(expenseHotel.value);
    }
    if (expenseFood.present) {
      map['expense_food'] = Variable<double>(expenseFood.value);
    }
    if (expenseTicket.present) {
      map['expense_ticket'] = Variable<double>(expenseTicket.value);
    }
    if (flightLink.present) {
      map['flight_link'] = Variable<String>(flightLink.value);
    }
    if (hotelLink.present) {
      map['hotel_link'] = Variable<String>(hotelLink.value);
    }
    if (isWishlist.present) {
      map['is_wishlist'] = Variable<bool>(isWishlist.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (wishlistDone.present) {
      map['wishlist_done'] = Variable<bool>(wishlistDone.value);
    }
    if (isJournal.present) {
      map['is_journal'] = Variable<bool>(isJournal.value);
    }
    if (planDate.present) {
      map['plan_date'] = Variable<DateTime>(planDate.value);
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
    return (StringBuffer('TravelRecordsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('images: $images, ')
          ..write('destination: $destination, ')
          ..write('poiName: $poiName, ')
          ..write('poiAddress: $poiAddress, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('city: $city, ')
          ..write('country: $country, ')
          ..write('mood: $mood, ')
          ..write('tags: $tags, ')
          ..write('expenseTransport: $expenseTransport, ')
          ..write('expenseHotel: $expenseHotel, ')
          ..write('expenseFood: $expenseFood, ')
          ..write('expenseTicket: $expenseTicket, ')
          ..write('flightLink: $flightLink, ')
          ..write('hotelLink: $hotelLink, ')
          ..write('isWishlist: $isWishlist, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('wishlistDone: $wishlistDone, ')
          ..write('isJournal: $isJournal, ')
          ..write('planDate: $planDate, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _destinationsMeta =
      const VerificationMeta('destinations');
  @override
  late final GeneratedColumn<String> destinations = GeneratedColumn<String>(
      'destinations', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalExpenseMeta =
      const VerificationMeta('totalExpense');
  @override
  late final GeneratedColumn<double> totalExpense = GeneratedColumn<double>(
      'total_expense', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        startDate,
        endDate,
        destinations,
        totalExpense,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(Insertable<Trip> instance,
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
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('destinations')) {
      context.handle(
          _destinationsMeta,
          destinations.isAcceptableOrUnknown(
              data['destinations']!, _destinationsMeta));
    }
    if (data.containsKey('total_expense')) {
      context.handle(
          _totalExpenseMeta,
          totalExpense.isAcceptableOrUnknown(
              data['total_expense']!, _totalExpenseMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      destinations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destinations']),
      totalExpense: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_expense']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class Trip extends DataClass implements Insertable<Trip> {
  final String id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? destinations;
  final double? totalExpense;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Trip(
      {required this.id,
      required this.name,
      this.startDate,
      this.endDate,
      this.destinations,
      this.totalExpense,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || destinations != null) {
      map['destinations'] = Variable<String>(destinations);
    }
    if (!nullToAbsent || totalExpense != null) {
      map['total_expense'] = Variable<double>(totalExpense);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      name: Value(name),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      destinations: destinations == null && nullToAbsent
          ? const Value.absent()
          : Value(destinations),
      totalExpense: totalExpense == null && nullToAbsent
          ? const Value.absent()
          : Value(totalExpense),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      destinations: serializer.fromJson<String?>(json['destinations']),
      totalExpense: serializer.fromJson<double?>(json['totalExpense']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'destinations': serializer.toJson<String?>(destinations),
      'totalExpense': serializer.toJson<double?>(totalExpense),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Trip copyWith(
          {String? id,
          String? name,
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          Value<String?> destinations = const Value.absent(),
          Value<double?> totalExpense = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Trip(
        id: id ?? this.id,
        name: name ?? this.name,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        destinations:
            destinations.present ? destinations.value : this.destinations,
        totalExpense:
            totalExpense.present ? totalExpense.value : this.totalExpense,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      destinations: data.destinations.present
          ? data.destinations.value
          : this.destinations,
      totalExpense: data.totalExpense.present
          ? data.totalExpense.value
          : this.totalExpense,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('destinations: $destinations, ')
          ..write('totalExpense: $totalExpense, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, startDate, endDate, destinations,
      totalExpense, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.destinations == this.destinations &&
          other.totalExpense == this.totalExpense &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> destinations;
  final Value<double?> totalExpense;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.destinations = const Value.absent(),
    this.totalExpense = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String name,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.destinations = const Value.absent(),
    this.totalExpense = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Trip> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? destinations,
    Expression<double>? totalExpense,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (destinations != null) 'destinations': destinations,
      if (totalExpense != null) 'total_expense': totalExpense,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime?>? startDate,
      Value<DateTime?>? endDate,
      Value<String?>? destinations,
      Value<double?>? totalExpense,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TripsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destinations: destinations ?? this.destinations,
      totalExpense: totalExpense ?? this.totalExpense,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (destinations.present) {
      map['destinations'] = Variable<String>(destinations.value);
    }
    if (totalExpense.present) {
      map['total_expense'] = Variable<double>(totalExpense.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('destinations: $destinations, ')
          ..write('totalExpense: $totalExpense, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalRecordsTable extends GoalRecords
    with TableInfo<$GoalRecordsTable, GoalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
      'level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
      'progress', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPostponedMeta =
      const VerificationMeta('isPostponed');
  @override
  late final GeneratedColumn<bool> isPostponed = GeneratedColumn<bool>(
      'is_postponed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_postponed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _remindFrequencyMeta =
      const VerificationMeta('remindFrequency');
  @override
  late final GeneratedColumn<String> remindFrequency = GeneratedColumn<String>(
      'remind_frequency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _targetYearMeta =
      const VerificationMeta('targetYear');
  @override
  late final GeneratedColumn<int> targetYear = GeneratedColumn<int>(
      'target_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _targetQuarterMeta =
      const VerificationMeta('targetQuarter');
  @override
  late final GeneratedColumn<int> targetQuarter = GeneratedColumn<int>(
      'target_quarter', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _targetMonthMeta =
      const VerificationMeta('targetMonth');
  @override
  late final GeneratedColumn<int> targetMonth = GeneratedColumn<int>(
      'target_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _recordDateMeta =
      const VerificationMeta('recordDate');
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
      'record_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        parentId,
        level,
        title,
        note,
        summary,
        category,
        tags,
        progress,
        isCompleted,
        isPostponed,
        isFavorite,
        remindFrequency,
        targetYear,
        targetQuarter,
        targetMonth,
        dueDate,
        recordDate,
        completedAt,
        createdAt,
        updatedAt,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_records';
  @override
  VerificationContext validateIntegrity(Insertable<GoalRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_postponed')) {
      context.handle(
          _isPostponedMeta,
          isPostponed.isAcceptableOrUnknown(
              data['is_postponed']!, _isPostponedMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('remind_frequency')) {
      context.handle(
          _remindFrequencyMeta,
          remindFrequency.isAcceptableOrUnknown(
              data['remind_frequency']!, _remindFrequencyMeta));
    }
    if (data.containsKey('target_year')) {
      context.handle(
          _targetYearMeta,
          targetYear.isAcceptableOrUnknown(
              data['target_year']!, _targetYearMeta));
    }
    if (data.containsKey('target_quarter')) {
      context.handle(
          _targetQuarterMeta,
          targetQuarter.isAcceptableOrUnknown(
              data['target_quarter']!, _targetQuarterMeta));
    }
    if (data.containsKey('target_month')) {
      context.handle(
          _targetMonthMeta,
          targetMonth.isAcceptableOrUnknown(
              data['target_month']!, _targetMonthMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('record_date')) {
      context.handle(
          _recordDateMeta,
          recordDate.isAcceptableOrUnknown(
              data['record_date']!, _recordDateMeta));
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
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
  GoalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isPostponed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_postponed'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      remindFrequency: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remind_frequency']),
      targetYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_year']),
      targetQuarter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_quarter']),
      targetMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_month']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      recordDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}record_date'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $GoalRecordsTable createAlias(String alias) {
    return $GoalRecordsTable(attachedDatabase, alias);
  }
}

class GoalRecord extends DataClass implements Insertable<GoalRecord> {
  final String id;
  final String? parentId;
  final String level;
  final String title;
  final String? note;
  final String? summary;
  final String? category;
  final String? tags;
  final double progress;
  final bool isCompleted;
  final bool isPostponed;
  final bool isFavorite;
  final String? remindFrequency;
  final int? targetYear;
  final int? targetQuarter;
  final int? targetMonth;
  final DateTime? dueDate;
  final DateTime recordDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const GoalRecord(
      {required this.id,
      this.parentId,
      required this.level,
      required this.title,
      this.note,
      this.summary,
      this.category,
      this.tags,
      required this.progress,
      required this.isCompleted,
      required this.isPostponed,
      required this.isFavorite,
      this.remindFrequency,
      this.targetYear,
      this.targetQuarter,
      this.targetMonth,
      this.dueDate,
      required this.recordDate,
      this.completedAt,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['level'] = Variable<String>(level);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['progress'] = Variable<double>(progress);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_postponed'] = Variable<bool>(isPostponed);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || remindFrequency != null) {
      map['remind_frequency'] = Variable<String>(remindFrequency);
    }
    if (!nullToAbsent || targetYear != null) {
      map['target_year'] = Variable<int>(targetYear);
    }
    if (!nullToAbsent || targetQuarter != null) {
      map['target_quarter'] = Variable<int>(targetQuarter);
    }
    if (!nullToAbsent || targetMonth != null) {
      map['target_month'] = Variable<int>(targetMonth);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  GoalRecordsCompanion toCompanion(bool nullToAbsent) {
    return GoalRecordsCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      level: Value(level),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      progress: Value(progress),
      isCompleted: Value(isCompleted),
      isPostponed: Value(isPostponed),
      isFavorite: Value(isFavorite),
      remindFrequency: remindFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(remindFrequency),
      targetYear: targetYear == null && nullToAbsent
          ? const Value.absent()
          : Value(targetYear),
      targetQuarter: targetQuarter == null && nullToAbsent
          ? const Value.absent()
          : Value(targetQuarter),
      targetMonth: targetMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMonth),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      recordDate: Value(recordDate),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory GoalRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRecord(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      level: serializer.fromJson<String>(json['level']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      summary: serializer.fromJson<String?>(json['summary']),
      category: serializer.fromJson<String?>(json['category']),
      tags: serializer.fromJson<String?>(json['tags']),
      progress: serializer.fromJson<double>(json['progress']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isPostponed: serializer.fromJson<bool>(json['isPostponed']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      remindFrequency: serializer.fromJson<String?>(json['remindFrequency']),
      targetYear: serializer.fromJson<int?>(json['targetYear']),
      targetQuarter: serializer.fromJson<int?>(json['targetQuarter']),
      targetMonth: serializer.fromJson<int?>(json['targetMonth']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
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
      'parentId': serializer.toJson<String?>(parentId),
      'level': serializer.toJson<String>(level),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'summary': serializer.toJson<String?>(summary),
      'category': serializer.toJson<String?>(category),
      'tags': serializer.toJson<String?>(tags),
      'progress': serializer.toJson<double>(progress),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isPostponed': serializer.toJson<bool>(isPostponed),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'remindFrequency': serializer.toJson<String?>(remindFrequency),
      'targetYear': serializer.toJson<int?>(targetYear),
      'targetQuarter': serializer.toJson<int?>(targetQuarter),
      'targetMonth': serializer.toJson<int?>(targetMonth),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  GoalRecord copyWith(
          {String? id,
          Value<String?> parentId = const Value.absent(),
          String? level,
          String? title,
          Value<String?> note = const Value.absent(),
          Value<String?> summary = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> tags = const Value.absent(),
          double? progress,
          bool? isCompleted,
          bool? isPostponed,
          bool? isFavorite,
          Value<String?> remindFrequency = const Value.absent(),
          Value<int?> targetYear = const Value.absent(),
          Value<int?> targetQuarter = const Value.absent(),
          Value<int?> targetMonth = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          DateTime? recordDate,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted}) =>
      GoalRecord(
        id: id ?? this.id,
        parentId: parentId.present ? parentId.value : this.parentId,
        level: level ?? this.level,
        title: title ?? this.title,
        note: note.present ? note.value : this.note,
        summary: summary.present ? summary.value : this.summary,
        category: category.present ? category.value : this.category,
        tags: tags.present ? tags.value : this.tags,
        progress: progress ?? this.progress,
        isCompleted: isCompleted ?? this.isCompleted,
        isPostponed: isPostponed ?? this.isPostponed,
        isFavorite: isFavorite ?? this.isFavorite,
        remindFrequency: remindFrequency.present
            ? remindFrequency.value
            : this.remindFrequency,
        targetYear: targetYear.present ? targetYear.value : this.targetYear,
        targetQuarter:
            targetQuarter.present ? targetQuarter.value : this.targetQuarter,
        targetMonth: targetMonth.present ? targetMonth.value : this.targetMonth,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        recordDate: recordDate ?? this.recordDate,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  GoalRecord copyWithCompanion(GoalRecordsCompanion data) {
    return GoalRecord(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      level: data.level.present ? data.level.value : this.level,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      summary: data.summary.present ? data.summary.value : this.summary,
      category: data.category.present ? data.category.value : this.category,
      tags: data.tags.present ? data.tags.value : this.tags,
      progress: data.progress.present ? data.progress.value : this.progress,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      isPostponed:
          data.isPostponed.present ? data.isPostponed.value : this.isPostponed,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      remindFrequency: data.remindFrequency.present
          ? data.remindFrequency.value
          : this.remindFrequency,
      targetYear:
          data.targetYear.present ? data.targetYear.value : this.targetYear,
      targetQuarter: data.targetQuarter.present
          ? data.targetQuarter.value
          : this.targetQuarter,
      targetMonth:
          data.targetMonth.present ? data.targetMonth.value : this.targetMonth,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      recordDate:
          data.recordDate.present ? data.recordDate.value : this.recordDate,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRecord(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('summary: $summary, ')
          ..write('category: $category, ')
          ..write('tags: $tags, ')
          ..write('progress: $progress, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isPostponed: $isPostponed, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('remindFrequency: $remindFrequency, ')
          ..write('targetYear: $targetYear, ')
          ..write('targetQuarter: $targetQuarter, ')
          ..write('targetMonth: $targetMonth, ')
          ..write('dueDate: $dueDate, ')
          ..write('recordDate: $recordDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        parentId,
        level,
        title,
        note,
        summary,
        category,
        tags,
        progress,
        isCompleted,
        isPostponed,
        isFavorite,
        remindFrequency,
        targetYear,
        targetQuarter,
        targetMonth,
        dueDate,
        recordDate,
        completedAt,
        createdAt,
        updatedAt,
        isDeleted
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRecord &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.level == this.level &&
          other.title == this.title &&
          other.note == this.note &&
          other.summary == this.summary &&
          other.category == this.category &&
          other.tags == this.tags &&
          other.progress == this.progress &&
          other.isCompleted == this.isCompleted &&
          other.isPostponed == this.isPostponed &&
          other.isFavorite == this.isFavorite &&
          other.remindFrequency == this.remindFrequency &&
          other.targetYear == this.targetYear &&
          other.targetQuarter == this.targetQuarter &&
          other.targetMonth == this.targetMonth &&
          other.dueDate == this.dueDate &&
          other.recordDate == this.recordDate &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class GoalRecordsCompanion extends UpdateCompanion<GoalRecord> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> level;
  final Value<String> title;
  final Value<String?> note;
  final Value<String?> summary;
  final Value<String?> category;
  final Value<String?> tags;
  final Value<double> progress;
  final Value<bool> isCompleted;
  final Value<bool> isPostponed;
  final Value<bool> isFavorite;
  final Value<String?> remindFrequency;
  final Value<int?> targetYear;
  final Value<int?> targetQuarter;
  final Value<int?> targetMonth;
  final Value<DateTime?> dueDate;
  final Value<DateTime> recordDate;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const GoalRecordsCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.level = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.summary = const Value.absent(),
    this.category = const Value.absent(),
    this.tags = const Value.absent(),
    this.progress = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isPostponed = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.remindFrequency = const Value.absent(),
    this.targetYear = const Value.absent(),
    this.targetQuarter = const Value.absent(),
    this.targetMonth = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalRecordsCompanion.insert({
    required String id,
    this.parentId = const Value.absent(),
    required String level,
    required String title,
    this.note = const Value.absent(),
    this.summary = const Value.absent(),
    this.category = const Value.absent(),
    this.tags = const Value.absent(),
    this.progress = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isPostponed = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.remindFrequency = const Value.absent(),
    this.targetYear = const Value.absent(),
    this.targetQuarter = const Value.absent(),
    this.targetMonth = const Value.absent(),
    this.dueDate = const Value.absent(),
    required DateTime recordDate,
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        level = Value(level),
        title = Value(title),
        recordDate = Value(recordDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<GoalRecord> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? level,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? summary,
    Expression<String>? category,
    Expression<String>? tags,
    Expression<double>? progress,
    Expression<bool>? isCompleted,
    Expression<bool>? isPostponed,
    Expression<bool>? isFavorite,
    Expression<String>? remindFrequency,
    Expression<int>? targetYear,
    Expression<int>? targetQuarter,
    Expression<int>? targetMonth,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (level != null) 'level': level,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (summary != null) 'summary': summary,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      if (progress != null) 'progress': progress,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isPostponed != null) 'is_postponed': isPostponed,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (remindFrequency != null) 'remind_frequency': remindFrequency,
      if (targetYear != null) 'target_year': targetYear,
      if (targetQuarter != null) 'target_quarter': targetQuarter,
      if (targetMonth != null) 'target_month': targetMonth,
      if (dueDate != null) 'due_date': dueDate,
      if (recordDate != null) 'record_date': recordDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? parentId,
      Value<String>? level,
      Value<String>? title,
      Value<String?>? note,
      Value<String?>? summary,
      Value<String?>? category,
      Value<String?>? tags,
      Value<double>? progress,
      Value<bool>? isCompleted,
      Value<bool>? isPostponed,
      Value<bool>? isFavorite,
      Value<String?>? remindFrequency,
      Value<int?>? targetYear,
      Value<int?>? targetQuarter,
      Value<int?>? targetMonth,
      Value<DateTime?>? dueDate,
      Value<DateTime>? recordDate,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return GoalRecordsCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      title: title ?? this.title,
      note: note ?? this.note,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isPostponed: isPostponed ?? this.isPostponed,
      isFavorite: isFavorite ?? this.isFavorite,
      remindFrequency: remindFrequency ?? this.remindFrequency,
      targetYear: targetYear ?? this.targetYear,
      targetQuarter: targetQuarter ?? this.targetQuarter,
      targetMonth: targetMonth ?? this.targetMonth,
      dueDate: dueDate ?? this.dueDate,
      recordDate: recordDate ?? this.recordDate,
      completedAt: completedAt ?? this.completedAt,
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
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isPostponed.present) {
      map['is_postponed'] = Variable<bool>(isPostponed.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (remindFrequency.present) {
      map['remind_frequency'] = Variable<String>(remindFrequency.value);
    }
    if (targetYear.present) {
      map['target_year'] = Variable<int>(targetYear.value);
    }
    if (targetQuarter.present) {
      map['target_quarter'] = Variable<int>(targetQuarter.value);
    }
    if (targetMonth.present) {
      map['target_month'] = Variable<int>(targetMonth.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
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
    return (StringBuffer('GoalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('summary: $summary, ')
          ..write('category: $category, ')
          ..write('tags: $tags, ')
          ..write('progress: $progress, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isPostponed: $isPostponed, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('remindFrequency: $remindFrequency, ')
          ..write('targetYear: $targetYear, ')
          ..write('targetQuarter: $targetQuarter, ')
          ..write('targetMonth: $targetMonth, ')
          ..write('dueDate: $dueDate, ')
          ..write('recordDate: $recordDate, ')
          ..write('completedAt: $completedAt, ')
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
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _poiNameMeta =
      const VerificationMeta('poiName');
  @override
  late final GeneratedColumn<String> poiName = GeneratedColumn<String>(
      'poi_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _poiAddressMeta =
      const VerificationMeta('poiAddress');
  @override
  late final GeneratedColumn<String> poiAddress = GeneratedColumn<String>(
      'poi_address', aliasedName, true,
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
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
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
        eventType,
        startAt,
        endAt,
        note,
        tags,
        poiName,
        poiAddress,
        latitude,
        longitude,
        isFavorite,
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
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('poi_name')) {
      context.handle(_poiNameMeta,
          poiName.isAcceptableOrUnknown(data['poi_name']!, _poiNameMeta));
    }
    if (data.containsKey('poi_address')) {
      context.handle(
          _poiAddressMeta,
          poiAddress.isAcceptableOrUnknown(
              data['poi_address']!, _poiAddressMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
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
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      poiName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_name']),
      poiAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_address']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
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
  final String? tags;
  final String? poiName;
  final String? poiAddress;
  final double? latitude;
  final double? longitude;
  final bool isFavorite;
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
      this.tags,
      this.poiName,
      this.poiAddress,
      this.latitude,
      this.longitude,
      required this.isFavorite,
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
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || poiName != null) {
      map['poi_name'] = Variable<String>(poiName);
    }
    if (!nullToAbsent || poiAddress != null) {
      map['poi_address'] = Variable<String>(poiAddress);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
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
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      poiName: poiName == null && nullToAbsent
          ? const Value.absent()
          : Value(poiName),
      poiAddress: poiAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(poiAddress),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      isFavorite: Value(isFavorite),
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
      tags: serializer.fromJson<String?>(json['tags']),
      poiName: serializer.fromJson<String?>(json['poiName']),
      poiAddress: serializer.fromJson<String?>(json['poiAddress']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
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
      'tags': serializer.toJson<String?>(tags),
      'poiName': serializer.toJson<String?>(poiName),
      'poiAddress': serializer.toJson<String?>(poiAddress),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'isFavorite': serializer.toJson<bool>(isFavorite),
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
          Value<String?> tags = const Value.absent(),
          Value<String?> poiName = const Value.absent(),
          Value<String?> poiAddress = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          bool? isFavorite,
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
        tags: tags.present ? tags.value : this.tags,
        poiName: poiName.present ? poiName.value : this.poiName,
        poiAddress: poiAddress.present ? poiAddress.value : this.poiAddress,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        isFavorite: isFavorite ?? this.isFavorite,
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
      tags: data.tags.present ? data.tags.value : this.tags,
      poiName: data.poiName.present ? data.poiName.value : this.poiName,
      poiAddress:
          data.poiAddress.present ? data.poiAddress.value : this.poiAddress,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
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
          ..write('tags: $tags, ')
          ..write('poiName: $poiName, ')
          ..write('poiAddress: $poiAddress, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isFavorite: $isFavorite, ')
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
      eventType,
      startAt,
      endAt,
      note,
      tags,
      poiName,
      poiAddress,
      latitude,
      longitude,
      isFavorite,
      recordDate,
      createdAt,
      updatedAt,
      isDeleted);
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
          other.tags == this.tags &&
          other.poiName == this.poiName &&
          other.poiAddress == this.poiAddress &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.isFavorite == this.isFavorite &&
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
  final Value<String?> tags;
  final Value<String?> poiName;
  final Value<String?> poiAddress;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<bool> isFavorite;
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
    this.tags = const Value.absent(),
    this.poiName = const Value.absent(),
    this.poiAddress = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isFavorite = const Value.absent(),
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
    this.tags = const Value.absent(),
    this.poiName = const Value.absent(),
    this.poiAddress = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isFavorite = const Value.absent(),
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
    Expression<String>? tags,
    Expression<String>? poiName,
    Expression<String>? poiAddress,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<bool>? isFavorite,
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
      if (tags != null) 'tags': tags,
      if (poiName != null) 'poi_name': poiName,
      if (poiAddress != null) 'poi_address': poiAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isFavorite != null) 'is_favorite': isFavorite,
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
      Value<String?>? tags,
      Value<String?>? poiName,
      Value<String?>? poiAddress,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<bool>? isFavorite,
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
      tags: tags ?? this.tags,
      poiName: poiName ?? this.poiName,
      poiAddress: poiAddress ?? this.poiAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
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
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (poiName.present) {
      map['poi_name'] = Variable<String>(poiName.value);
    }
    if (poiAddress.present) {
      map['poi_address'] = Variable<String>(poiAddress.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
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
          ..write('tags: $tags, ')
          ..write('poiName: $poiName, ')
          ..write('poiAddress: $poiAddress, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isFavorite: $isFavorite, ')
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

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthdayMeta =
      const VerificationMeta('birthday');
  @override
  late final GeneratedColumn<DateTime> birthday = GeneratedColumn<DateTime>(
      'birthday', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
      'height_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _relationshipStatusMeta =
      const VerificationMeta('relationshipStatus');
  @override
  late final GeneratedColumn<String> relationshipStatus =
      GeneratedColumn<String>('relationship_status', aliasedName, true,
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        displayName,
        birthday,
        heightCm,
        weightKg,
        relationshipStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('birthday')) {
      context.handle(_birthdayMeta,
          birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('relationship_status')) {
      context.handle(
          _relationshipStatusMeta,
          relationshipStatus.isAcceptableOrUnknown(
              data['relationship_status']!, _relationshipStatusMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      birthday: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birthday']),
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_cm']),
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      relationshipStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}relationship_status']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String displayName;
  final DateTime? birthday;
  final double? heightCm;
  final double? weightKg;
  final String? relationshipStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile(
      {required this.id,
      required this.displayName,
      this.birthday,
      this.heightCm,
      this.weightKg,
      this.relationshipStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<DateTime>(birthday);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || relationshipStatus != null) {
      map['relationship_status'] = Variable<String>(relationshipStatus);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      birthday: birthday == null && nullToAbsent
          ? const Value.absent()
          : Value(birthday),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      relationshipStatus: relationshipStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(relationshipStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      birthday: serializer.fromJson<DateTime?>(json['birthday']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      relationshipStatus:
          serializer.fromJson<String?>(json['relationshipStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'birthday': serializer.toJson<DateTime?>(birthday),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'relationshipStatus': serializer.toJson<String?>(relationshipStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith(
          {String? id,
          String? displayName,
          Value<DateTime?> birthday = const Value.absent(),
          Value<double?> heightCm = const Value.absent(),
          Value<double?> weightKg = const Value.absent(),
          Value<String?> relationshipStatus = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserProfile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        birthday: birthday.present ? birthday.value : this.birthday,
        heightCm: heightCm.present ? heightCm.value : this.heightCm,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        relationshipStatus: relationshipStatus.present
            ? relationshipStatus.value
            : this.relationshipStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      relationshipStatus: data.relationshipStatus.present
          ? data.relationshipStatus.value
          : this.relationshipStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('birthday: $birthday, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('relationshipStatus: $relationshipStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, birthday, heightCm, weightKg,
      relationshipStatus, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.birthday == this.birthday &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.relationshipStatus == this.relationshipStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<DateTime?> birthday;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<String?> relationshipStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.birthday = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.relationshipStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String displayName,
    this.birthday = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.relationshipStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        displayName = Value(displayName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<DateTime>? birthday,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? relationshipStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (birthday != null) 'birthday': birthday,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (relationshipStatus != null) 'relationship_status': relationshipStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? displayName,
      Value<DateTime?>? birthday,
      Value<double?>? heightCm,
      Value<double?>? weightKg,
      Value<String?>? relationshipStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      birthday: birthday ?? this.birthday,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (relationshipStatus.present) {
      map['relationship_status'] = Variable<String>(relationshipStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('birthday: $birthday, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('relationshipStatus: $relationshipStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiProvidersTable extends AiProviders
    with TableInfo<$AiProvidersTable, AiProvider> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiProvidersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _apiTypeMeta =
      const VerificationMeta('apiType');
  @override
  late final GeneratedColumn<String> apiType = GeneratedColumn<String>(
      'api_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceTypeMeta =
      const VerificationMeta('serviceType');
  @override
  late final GeneratedColumn<String> serviceType = GeneratedColumn<String>(
      'service_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseUrlMeta =
      const VerificationMeta('baseUrl');
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
      'base_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _apiKeyMeta = const VerificationMeta('apiKey');
  @override
  late final GeneratedColumn<String> apiKey = GeneratedColumn<String>(
      'api_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelNameMeta =
      const VerificationMeta('modelName');
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
      'model_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _extraConfigMeta =
      const VerificationMeta('extraConfig');
  @override
  late final GeneratedColumn<String> extraConfig = GeneratedColumn<String>(
      'extra_config', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(false));
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        apiType,
        serviceType,
        baseUrl,
        apiKey,
        modelName,
        extraConfig,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_providers';
  @override
  VerificationContext validateIntegrity(Insertable<AiProvider> instance,
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
    if (data.containsKey('api_type')) {
      context.handle(_apiTypeMeta,
          apiType.isAcceptableOrUnknown(data['api_type']!, _apiTypeMeta));
    } else if (isInserting) {
      context.missing(_apiTypeMeta);
    }
    if (data.containsKey('service_type')) {
      context.handle(
          _serviceTypeMeta,
          serviceType.isAcceptableOrUnknown(
              data['service_type']!, _serviceTypeMeta));
    } else if (isInserting) {
      context.missing(_serviceTypeMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(_baseUrlMeta,
          baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta));
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('api_key')) {
      context.handle(_apiKeyMeta,
          apiKey.isAcceptableOrUnknown(data['api_key']!, _apiKeyMeta));
    } else if (isInserting) {
      context.missing(_apiKeyMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(_modelNameMeta,
          modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta));
    }
    if (data.containsKey('extra_config')) {
      context.handle(
          _extraConfigMeta,
          extraConfig.isAcceptableOrUnknown(
              data['extra_config']!, _extraConfigMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiProvider map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiProvider(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      apiType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}api_type'])!,
      serviceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_type'])!,
      baseUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_url'])!,
      apiKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}api_key'])!,
      modelName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_name']),
      extraConfig: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extra_config']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AiProvidersTable createAlias(String alias) {
    return $AiProvidersTable(attachedDatabase, alias);
  }
}

class AiProvider extends DataClass implements Insertable<AiProvider> {
  final String id;
  final String name;
  final String apiType;
  final String serviceType;
  final String baseUrl;
  final String apiKey;
  final String? modelName;
  final String? extraConfig;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AiProvider(
      {required this.id,
      required this.name,
      required this.apiType,
      required this.serviceType,
      required this.baseUrl,
      required this.apiKey,
      this.modelName,
      this.extraConfig,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['api_type'] = Variable<String>(apiType);
    map['service_type'] = Variable<String>(serviceType);
    map['base_url'] = Variable<String>(baseUrl);
    map['api_key'] = Variable<String>(apiKey);
    if (!nullToAbsent || modelName != null) {
      map['model_name'] = Variable<String>(modelName);
    }
    if (!nullToAbsent || extraConfig != null) {
      map['extra_config'] = Variable<String>(extraConfig);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AiProvidersCompanion toCompanion(bool nullToAbsent) {
    return AiProvidersCompanion(
      id: Value(id),
      name: Value(name),
      apiType: Value(apiType),
      serviceType: Value(serviceType),
      baseUrl: Value(baseUrl),
      apiKey: Value(apiKey),
      modelName: modelName == null && nullToAbsent
          ? const Value.absent()
          : Value(modelName),
      extraConfig: extraConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(extraConfig),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiProvider.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiProvider(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      apiType: serializer.fromJson<String>(json['apiType']),
      serviceType: serializer.fromJson<String>(json['serviceType']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      apiKey: serializer.fromJson<String>(json['apiKey']),
      modelName: serializer.fromJson<String?>(json['modelName']),
      extraConfig: serializer.fromJson<String?>(json['extraConfig']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'apiType': serializer.toJson<String>(apiType),
      'serviceType': serializer.toJson<String>(serviceType),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'apiKey': serializer.toJson<String>(apiKey),
      'modelName': serializer.toJson<String?>(modelName),
      'extraConfig': serializer.toJson<String?>(extraConfig),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AiProvider copyWith(
          {String? id,
          String? name,
          String? apiType,
          String? serviceType,
          String? baseUrl,
          String? apiKey,
          Value<String?> modelName = const Value.absent(),
          Value<String?> extraConfig = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      AiProvider(
        id: id ?? this.id,
        name: name ?? this.name,
        apiType: apiType ?? this.apiType,
        serviceType: serviceType ?? this.serviceType,
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
        modelName: modelName.present ? modelName.value : this.modelName,
        extraConfig: extraConfig.present ? extraConfig.value : this.extraConfig,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AiProvider copyWithCompanion(AiProvidersCompanion data) {
    return AiProvider(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      apiType: data.apiType.present ? data.apiType.value : this.apiType,
      serviceType:
          data.serviceType.present ? data.serviceType.value : this.serviceType,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      apiKey: data.apiKey.present ? data.apiKey.value : this.apiKey,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      extraConfig:
          data.extraConfig.present ? data.extraConfig.value : this.extraConfig,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiProvider(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('apiType: $apiType, ')
          ..write('serviceType: $serviceType, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('apiKey: $apiKey, ')
          ..write('modelName: $modelName, ')
          ..write('extraConfig: $extraConfig, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, apiType, serviceType, baseUrl,
      apiKey, modelName, extraConfig, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiProvider &&
          other.id == this.id &&
          other.name == this.name &&
          other.apiType == this.apiType &&
          other.serviceType == this.serviceType &&
          other.baseUrl == this.baseUrl &&
          other.apiKey == this.apiKey &&
          other.modelName == this.modelName &&
          other.extraConfig == this.extraConfig &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AiProvidersCompanion extends UpdateCompanion<AiProvider> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> apiType;
  final Value<String> serviceType;
  final Value<String> baseUrl;
  final Value<String> apiKey;
  final Value<String?> modelName;
  final Value<String?> extraConfig;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AiProvidersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.apiType = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.apiKey = const Value.absent(),
    this.modelName = const Value.absent(),
    this.extraConfig = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiProvidersCompanion.insert({
    required String id,
    required String name,
    required String apiType,
    required String serviceType,
    required String baseUrl,
    required String apiKey,
    this.modelName = const Value.absent(),
    this.extraConfig = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        apiType = Value(apiType),
        serviceType = Value(serviceType),
        baseUrl = Value(baseUrl),
        apiKey = Value(apiKey),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AiProvider> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? apiType,
    Expression<String>? serviceType,
    Expression<String>? baseUrl,
    Expression<String>? apiKey,
    Expression<String>? modelName,
    Expression<String>? extraConfig,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (apiType != null) 'api_type': apiType,
      if (serviceType != null) 'service_type': serviceType,
      if (baseUrl != null) 'base_url': baseUrl,
      if (apiKey != null) 'api_key': apiKey,
      if (modelName != null) 'model_name': modelName,
      if (extraConfig != null) 'extra_config': extraConfig,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiProvidersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? apiType,
      Value<String>? serviceType,
      Value<String>? baseUrl,
      Value<String>? apiKey,
      Value<String?>? modelName,
      Value<String?>? extraConfig,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AiProvidersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      apiType: apiType ?? this.apiType,
      serviceType: serviceType ?? this.serviceType,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      modelName: modelName ?? this.modelName,
      extraConfig: extraConfig ?? this.extraConfig,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (apiType.present) {
      map['api_type'] = Variable<String>(apiType.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(serviceType.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (apiKey.present) {
      map['api_key'] = Variable<String>(apiKey.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (extraConfig.present) {
      map['extra_config'] = Variable<String>(extraConfig.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiProvidersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('apiType: $apiType, ')
          ..write('serviceType: $serviceType, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('apiKey: $apiKey, ')
          ..write('modelName: $modelName, ')
          ..write('extraConfig: $extraConfig, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChangeLogsTable extends ChangeLogs
    with TableInfo<$ChangeLogsTable, ChangeLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangeLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _changedFieldsMeta =
      const VerificationMeta('changedFields');
  @override
  late final GeneratedColumn<String> changedFields = GeneratedColumn<String>(
      'changed_fields', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityType, entityId, action, changedFields, timestamp, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'change_logs';
  @override
  VerificationContext validateIntegrity(Insertable<ChangeLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('changed_fields')) {
      context.handle(
          _changedFieldsMeta,
          changedFields.isAcceptableOrUnknown(
              data['changed_fields']!, _changedFieldsMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChangeLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      changedFields: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changed_fields']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $ChangeLogsTable createAlias(String alias) {
    return $ChangeLogsTable(attachedDatabase, alias);
  }
}

class ChangeLog extends DataClass implements Insertable<ChangeLog> {
  final int id;
  final String entityType;
  final String entityId;
  final String action;
  final String? changedFields;
  final DateTime timestamp;
  final bool synced;
  const ChangeLog(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.action,
      this.changedFields,
      required this.timestamp,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || changedFields != null) {
      map['changed_fields'] = Variable<String>(changedFields);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ChangeLogsCompanion toCompanion(bool nullToAbsent) {
    return ChangeLogsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      changedFields: changedFields == null && nullToAbsent
          ? const Value.absent()
          : Value(changedFields),
      timestamp: Value(timestamp),
      synced: Value(synced),
    );
  }

  factory ChangeLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeLog(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      changedFields: serializer.fromJson<String?>(json['changedFields']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'changedFields': serializer.toJson<String?>(changedFields),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ChangeLog copyWith(
          {int? id,
          String? entityType,
          String? entityId,
          String? action,
          Value<String?> changedFields = const Value.absent(),
          DateTime? timestamp,
          bool? synced}) =>
      ChangeLog(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        changedFields:
            changedFields.present ? changedFields.value : this.changedFields,
        timestamp: timestamp ?? this.timestamp,
        synced: synced ?? this.synced,
      );
  ChangeLog copyWithCompanion(ChangeLogsCompanion data) {
    return ChangeLog(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      changedFields: data.changedFields.present
          ? data.changedFields.value
          : this.changedFields,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLog(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('changedFields: $changedFields, ')
          ..write('timestamp: $timestamp, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entityType, entityId, action, changedFields, timestamp, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeLog &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.changedFields == this.changedFields &&
          other.timestamp == this.timestamp &&
          other.synced == this.synced);
}

class ChangeLogsCompanion extends UpdateCompanion<ChangeLog> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> changedFields;
  final Value<DateTime> timestamp;
  final Value<bool> synced;
  const ChangeLogsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.changedFields = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.synced = const Value.absent(),
  });
  ChangeLogsCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String action,
    this.changedFields = const Value.absent(),
    required DateTime timestamp,
    this.synced = const Value.absent(),
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        timestamp = Value(timestamp);
  static Insertable<ChangeLog> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? changedFields,
    Expression<DateTime>? timestamp,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (changedFields != null) 'changed_fields': changedFields,
      if (timestamp != null) 'timestamp': timestamp,
      if (synced != null) 'synced': synced,
    });
  }

  ChangeLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String?>? changedFields,
      Value<DateTime>? timestamp,
      Value<bool>? synced}) {
    return ChangeLogsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      changedFields: changedFields ?? this.changedFields,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (changedFields.present) {
      map['changed_fields'] = Variable<String>(changedFields.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('changedFields: $changedFields, ')
          ..write('timestamp: $timestamp, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncTimeMeta =
      const VerificationMeta('lastSyncTime');
  @override
  late final GeneratedColumn<DateTime> lastSyncTime = GeneratedColumn<DateTime>(
      'last_sync_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncChangeIdMeta =
      const VerificationMeta('lastSyncChangeId');
  @override
  late final GeneratedColumn<int> lastSyncChangeId = GeneratedColumn<int>(
      'last_sync_change_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, lastSyncTime, lastSyncChangeId, deviceId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('last_sync_time')) {
      context.handle(
          _lastSyncTimeMeta,
          lastSyncTime.isAcceptableOrUnknown(
              data['last_sync_time']!, _lastSyncTimeMeta));
    }
    if (data.containsKey('last_sync_change_id')) {
      context.handle(
          _lastSyncChangeIdMeta,
          lastSyncChangeId.isAcceptableOrUnknown(
              data['last_sync_change_id']!, _lastSyncChangeIdMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      lastSyncTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_sync_time']),
      lastSyncChangeId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_sync_change_id']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String id;
  final DateTime? lastSyncTime;
  final int? lastSyncChangeId;
  final String deviceId;
  const SyncStateData(
      {required this.id,
      this.lastSyncTime,
      this.lastSyncChangeId,
      required this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || lastSyncTime != null) {
      map['last_sync_time'] = Variable<DateTime>(lastSyncTime);
    }
    if (!nullToAbsent || lastSyncChangeId != null) {
      map['last_sync_change_id'] = Variable<int>(lastSyncChangeId);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      id: Value(id),
      lastSyncTime: lastSyncTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncTime),
      lastSyncChangeId: lastSyncChangeId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncChangeId),
      deviceId: Value(deviceId),
    );
  }

  factory SyncStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      id: serializer.fromJson<String>(json['id']),
      lastSyncTime: serializer.fromJson<DateTime?>(json['lastSyncTime']),
      lastSyncChangeId: serializer.fromJson<int?>(json['lastSyncChangeId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lastSyncTime': serializer.toJson<DateTime?>(lastSyncTime),
      'lastSyncChangeId': serializer.toJson<int?>(lastSyncChangeId),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  SyncStateData copyWith(
          {String? id,
          Value<DateTime?> lastSyncTime = const Value.absent(),
          Value<int?> lastSyncChangeId = const Value.absent(),
          String? deviceId}) =>
      SyncStateData(
        id: id ?? this.id,
        lastSyncTime:
            lastSyncTime.present ? lastSyncTime.value : this.lastSyncTime,
        lastSyncChangeId: lastSyncChangeId.present
            ? lastSyncChangeId.value
            : this.lastSyncChangeId,
        deviceId: deviceId ?? this.deviceId,
      );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      id: data.id.present ? data.id.value : this.id,
      lastSyncTime: data.lastSyncTime.present
          ? data.lastSyncTime.value
          : this.lastSyncTime,
      lastSyncChangeId: data.lastSyncChangeId.present
          ? data.lastSyncChangeId.value
          : this.lastSyncChangeId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('id: $id, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('lastSyncChangeId: $lastSyncChangeId, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastSyncTime, lastSyncChangeId, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.id == this.id &&
          other.lastSyncTime == this.lastSyncTime &&
          other.lastSyncChangeId == this.lastSyncChangeId &&
          other.deviceId == this.deviceId);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> id;
  final Value<DateTime?> lastSyncTime;
  final Value<int?> lastSyncChangeId;
  final Value<String> deviceId;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.id = const Value.absent(),
    this.lastSyncTime = const Value.absent(),
    this.lastSyncChangeId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String id,
    this.lastSyncTime = const Value.absent(),
    this.lastSyncChangeId = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId);
  static Insertable<SyncStateData> custom({
    Expression<String>? id,
    Expression<DateTime>? lastSyncTime,
    Expression<int>? lastSyncChangeId,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastSyncTime != null) 'last_sync_time': lastSyncTime,
      if (lastSyncChangeId != null) 'last_sync_change_id': lastSyncChangeId,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? lastSyncTime,
      Value<int?>? lastSyncChangeId,
      Value<String>? deviceId,
      Value<int>? rowid}) {
    return SyncStateCompanion(
      id: id ?? this.id,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncChangeId: lastSyncChangeId ?? this.lastSyncChangeId,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lastSyncTime.present) {
      map['last_sync_time'] = Variable<DateTime>(lastSyncTime.value);
    }
    if (lastSyncChangeId.present) {
      map['last_sync_change_id'] = Variable<int>(lastSyncChangeId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('id: $id, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('lastSyncChangeId: $lastSyncChangeId, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChecklistItemsTable extends ChecklistItems
    with TableInfo<$ChecklistItemsTable, ChecklistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChecklistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
      'trip_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _travelIdMeta =
      const VerificationMeta('travelId');
  @override
  late final GeneratedColumn<String> travelId = GeneratedColumn<String>(
      'travel_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
      'is_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tripId,
        travelId,
        title,
        note,
        isDone,
        orderIndex,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checklist_items';
  @override
  VerificationContext validateIntegrity(Insertable<ChecklistItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('travel_id')) {
      context.handle(_travelIdMeta,
          travelId.isAcceptableOrUnknown(data['travel_id']!, _travelIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChecklistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      travelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}travel_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      isDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_done'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ChecklistItemsTable createAlias(String alias) {
    return $ChecklistItemsTable(attachedDatabase, alias);
  }
}

class ChecklistItem extends DataClass implements Insertable<ChecklistItem> {
  final String id;
  final String tripId;
  final String? travelId;
  final String title;
  final String? note;
  final bool isDone;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ChecklistItem(
      {required this.id,
      required this.tripId,
      this.travelId,
      required this.title,
      this.note,
      required this.isDone,
      required this.orderIndex,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || travelId != null) {
      map['travel_id'] = Variable<String>(travelId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_done'] = Variable<bool>(isDone);
    map['order_index'] = Variable<int>(orderIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChecklistItemsCompanion toCompanion(bool nullToAbsent) {
    return ChecklistItemsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      travelId: travelId == null && nullToAbsent
          ? const Value.absent()
          : Value(travelId),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isDone: Value(isDone),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistItem(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      travelId: serializer.fromJson<String?>(json['travelId']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'travelId': serializer.toJson<String?>(travelId),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'isDone': serializer.toJson<bool>(isDone),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChecklistItem copyWith(
          {String? id,
          String? tripId,
          Value<String?> travelId = const Value.absent(),
          String? title,
          Value<String?> note = const Value.absent(),
          bool? isDone,
          int? orderIndex,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ChecklistItem(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        travelId: travelId.present ? travelId.value : this.travelId,
        title: title ?? this.title,
        note: note.present ? note.value : this.note,
        isDone: isDone ?? this.isDone,
        orderIndex: orderIndex ?? this.orderIndex,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ChecklistItem copyWithCompanion(ChecklistItemsCompanion data) {
    return ChecklistItem(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      travelId: data.travelId.present ? data.travelId.value : this.travelId,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItem(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('travelId: $travelId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('isDone: $isDone, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tripId, travelId, title, note, isDone,
      orderIndex, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistItem &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.travelId == this.travelId &&
          other.title == this.title &&
          other.note == this.note &&
          other.isDone == this.isDone &&
          other.orderIndex == this.orderIndex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChecklistItemsCompanion extends UpdateCompanion<ChecklistItem> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String?> travelId;
  final Value<String> title;
  final Value<String?> note;
  final Value<bool> isDone;
  final Value<int> orderIndex;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChecklistItemsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.travelId = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.isDone = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChecklistItemsCompanion.insert({
    required String id,
    required String tripId,
    this.travelId = const Value.absent(),
    required String title,
    this.note = const Value.absent(),
    this.isDone = const Value.absent(),
    this.orderIndex = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ChecklistItem> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? travelId,
    Expression<String>? title,
    Expression<String>? note,
    Expression<bool>? isDone,
    Expression<int>? orderIndex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (travelId != null) 'travel_id': travelId,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (isDone != null) 'is_done': isDone,
      if (orderIndex != null) 'order_index': orderIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChecklistItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String?>? travelId,
      Value<String>? title,
      Value<String?>? note,
      Value<bool>? isDone,
      Value<int>? orderIndex,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ChecklistItemsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      travelId: travelId ?? this.travelId,
      title: title ?? this.title,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (travelId.present) {
      map['travel_id'] = Variable<String>(travelId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItemsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('travelId: $travelId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('isDone: $isDone, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalPostponementsTable extends GoalPostponements
    with TableInfo<$GoalPostponementsTable, GoalPostponement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalPostponementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
      'goal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _oldDueDateMeta =
      const VerificationMeta('oldDueDate');
  @override
  late final GeneratedColumn<DateTime> oldDueDate = GeneratedColumn<DateTime>(
      'old_due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _newDueDateMeta =
      const VerificationMeta('newDueDate');
  @override
  late final GeneratedColumn<DateTime> newDueDate = GeneratedColumn<DateTime>(
      'new_due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _daysAddedMeta =
      const VerificationMeta('daysAdded');
  @override
  late final GeneratedColumn<int> daysAdded = GeneratedColumn<int>(
      'days_added', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, goalId, oldDueDate, newDueDate, reason, daysAdded, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_postponements';
  @override
  VerificationContext validateIntegrity(Insertable<GoalPostponement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('old_due_date')) {
      context.handle(
          _oldDueDateMeta,
          oldDueDate.isAcceptableOrUnknown(
              data['old_due_date']!, _oldDueDateMeta));
    }
    if (data.containsKey('new_due_date')) {
      context.handle(
          _newDueDateMeta,
          newDueDate.isAcceptableOrUnknown(
              data['new_due_date']!, _newDueDateMeta));
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('days_added')) {
      context.handle(_daysAddedMeta,
          daysAdded.isAcceptableOrUnknown(data['days_added']!, _daysAddedMeta));
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
  GoalPostponement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalPostponement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal_id'])!,
      oldDueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}old_due_date']),
      newDueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}new_due_date']),
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      daysAdded: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}days_added']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GoalPostponementsTable createAlias(String alias) {
    return $GoalPostponementsTable(attachedDatabase, alias);
  }
}

class GoalPostponement extends DataClass
    implements Insertable<GoalPostponement> {
  final String id;
  final String goalId;
  final DateTime? oldDueDate;
  final DateTime? newDueDate;
  final String? reason;
  final int? daysAdded;
  final DateTime createdAt;
  const GoalPostponement(
      {required this.id,
      required this.goalId,
      this.oldDueDate,
      this.newDueDate,
      this.reason,
      this.daysAdded,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['goal_id'] = Variable<String>(goalId);
    if (!nullToAbsent || oldDueDate != null) {
      map['old_due_date'] = Variable<DateTime>(oldDueDate);
    }
    if (!nullToAbsent || newDueDate != null) {
      map['new_due_date'] = Variable<DateTime>(newDueDate);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || daysAdded != null) {
      map['days_added'] = Variable<int>(daysAdded);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalPostponementsCompanion toCompanion(bool nullToAbsent) {
    return GoalPostponementsCompanion(
      id: Value(id),
      goalId: Value(goalId),
      oldDueDate: oldDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(oldDueDate),
      newDueDate: newDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(newDueDate),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      daysAdded: daysAdded == null && nullToAbsent
          ? const Value.absent()
          : Value(daysAdded),
      createdAt: Value(createdAt),
    );
  }

  factory GoalPostponement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalPostponement(
      id: serializer.fromJson<String>(json['id']),
      goalId: serializer.fromJson<String>(json['goalId']),
      oldDueDate: serializer.fromJson<DateTime?>(json['oldDueDate']),
      newDueDate: serializer.fromJson<DateTime?>(json['newDueDate']),
      reason: serializer.fromJson<String?>(json['reason']),
      daysAdded: serializer.fromJson<int?>(json['daysAdded']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'goalId': serializer.toJson<String>(goalId),
      'oldDueDate': serializer.toJson<DateTime?>(oldDueDate),
      'newDueDate': serializer.toJson<DateTime?>(newDueDate),
      'reason': serializer.toJson<String?>(reason),
      'daysAdded': serializer.toJson<int?>(daysAdded),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GoalPostponement copyWith(
          {String? id,
          String? goalId,
          Value<DateTime?> oldDueDate = const Value.absent(),
          Value<DateTime?> newDueDate = const Value.absent(),
          Value<String?> reason = const Value.absent(),
          Value<int?> daysAdded = const Value.absent(),
          DateTime? createdAt}) =>
      GoalPostponement(
        id: id ?? this.id,
        goalId: goalId ?? this.goalId,
        oldDueDate: oldDueDate.present ? oldDueDate.value : this.oldDueDate,
        newDueDate: newDueDate.present ? newDueDate.value : this.newDueDate,
        reason: reason.present ? reason.value : this.reason,
        daysAdded: daysAdded.present ? daysAdded.value : this.daysAdded,
        createdAt: createdAt ?? this.createdAt,
      );
  GoalPostponement copyWithCompanion(GoalPostponementsCompanion data) {
    return GoalPostponement(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      oldDueDate:
          data.oldDueDate.present ? data.oldDueDate.value : this.oldDueDate,
      newDueDate:
          data.newDueDate.present ? data.newDueDate.value : this.newDueDate,
      reason: data.reason.present ? data.reason.value : this.reason,
      daysAdded: data.daysAdded.present ? data.daysAdded.value : this.daysAdded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalPostponement(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('oldDueDate: $oldDueDate, ')
          ..write('newDueDate: $newDueDate, ')
          ..write('reason: $reason, ')
          ..write('daysAdded: $daysAdded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, goalId, oldDueDate, newDueDate, reason, daysAdded, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalPostponement &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.oldDueDate == this.oldDueDate &&
          other.newDueDate == this.newDueDate &&
          other.reason == this.reason &&
          other.daysAdded == this.daysAdded &&
          other.createdAt == this.createdAt);
}

class GoalPostponementsCompanion extends UpdateCompanion<GoalPostponement> {
  final Value<String> id;
  final Value<String> goalId;
  final Value<DateTime?> oldDueDate;
  final Value<DateTime?> newDueDate;
  final Value<String?> reason;
  final Value<int?> daysAdded;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GoalPostponementsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.oldDueDate = const Value.absent(),
    this.newDueDate = const Value.absent(),
    this.reason = const Value.absent(),
    this.daysAdded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalPostponementsCompanion.insert({
    required String id,
    required String goalId,
    this.oldDueDate = const Value.absent(),
    this.newDueDate = const Value.absent(),
    this.reason = const Value.absent(),
    this.daysAdded = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        goalId = Value(goalId),
        createdAt = Value(createdAt);
  static Insertable<GoalPostponement> custom({
    Expression<String>? id,
    Expression<String>? goalId,
    Expression<DateTime>? oldDueDate,
    Expression<DateTime>? newDueDate,
    Expression<String>? reason,
    Expression<int>? daysAdded,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (oldDueDate != null) 'old_due_date': oldDueDate,
      if (newDueDate != null) 'new_due_date': newDueDate,
      if (reason != null) 'reason': reason,
      if (daysAdded != null) 'days_added': daysAdded,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalPostponementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? goalId,
      Value<DateTime?>? oldDueDate,
      Value<DateTime?>? newDueDate,
      Value<String?>? reason,
      Value<int?>? daysAdded,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return GoalPostponementsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      oldDueDate: oldDueDate ?? this.oldDueDate,
      newDueDate: newDueDate ?? this.newDueDate,
      reason: reason ?? this.reason,
      daysAdded: daysAdded ?? this.daysAdded,
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
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (oldDueDate.present) {
      map['old_due_date'] = Variable<DateTime>(oldDueDate.value);
    }
    if (newDueDate.present) {
      map['new_due_date'] = Variable<DateTime>(newDueDate.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (daysAdded.present) {
      map['days_added'] = Variable<int>(daysAdded.value);
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
    return (StringBuffer('GoalPostponementsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('oldDueDate: $oldDueDate, ')
          ..write('newDueDate: $newDueDate, ')
          ..write('reason: $reason, ')
          ..write('daysAdded: $daysAdded, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalReviewsTable extends GoalReviews
    with TableInfo<$GoalReviewsTable, GoalReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
      'goal_id', aliasedName, false,
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
  static const VerificationMeta _reviewDateMeta =
      const VerificationMeta('reviewDate');
  @override
  late final GeneratedColumn<DateTime> reviewDate = GeneratedColumn<DateTime>(
      'review_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, goalId, title, content, reviewDate, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_reviews';
  @override
  VerificationContext validateIntegrity(Insertable<GoalReview> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
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
    if (data.containsKey('review_date')) {
      context.handle(
          _reviewDateMeta,
          reviewDate.isAcceptableOrUnknown(
              data['review_date']!, _reviewDateMeta));
    } else if (isInserting) {
      context.missing(_reviewDateMeta);
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
  GoalReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalReview(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      reviewDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}review_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GoalReviewsTable createAlias(String alias) {
    return $GoalReviewsTable(attachedDatabase, alias);
  }
}

class GoalReview extends DataClass implements Insertable<GoalReview> {
  final String id;
  final String goalId;
  final String title;
  final String? content;
  final DateTime reviewDate;
  final DateTime createdAt;
  const GoalReview(
      {required this.id,
      required this.goalId,
      required this.title,
      this.content,
      required this.reviewDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['goal_id'] = Variable<String>(goalId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['review_date'] = Variable<DateTime>(reviewDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalReviewsCompanion toCompanion(bool nullToAbsent) {
    return GoalReviewsCompanion(
      id: Value(id),
      goalId: Value(goalId),
      title: Value(title),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      reviewDate: Value(reviewDate),
      createdAt: Value(createdAt),
    );
  }

  factory GoalReview.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalReview(
      id: serializer.fromJson<String>(json['id']),
      goalId: serializer.fromJson<String>(json['goalId']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      reviewDate: serializer.fromJson<DateTime>(json['reviewDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'goalId': serializer.toJson<String>(goalId),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String?>(content),
      'reviewDate': serializer.toJson<DateTime>(reviewDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GoalReview copyWith(
          {String? id,
          String? goalId,
          String? title,
          Value<String?> content = const Value.absent(),
          DateTime? reviewDate,
          DateTime? createdAt}) =>
      GoalReview(
        id: id ?? this.id,
        goalId: goalId ?? this.goalId,
        title: title ?? this.title,
        content: content.present ? content.value : this.content,
        reviewDate: reviewDate ?? this.reviewDate,
        createdAt: createdAt ?? this.createdAt,
      );
  GoalReview copyWithCompanion(GoalReviewsCompanion data) {
    return GoalReview(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      reviewDate:
          data.reviewDate.present ? data.reviewDate.value : this.reviewDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalReview(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('reviewDate: $reviewDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, goalId, title, content, reviewDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalReview &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.title == this.title &&
          other.content == this.content &&
          other.reviewDate == this.reviewDate &&
          other.createdAt == this.createdAt);
}

class GoalReviewsCompanion extends UpdateCompanion<GoalReview> {
  final Value<String> id;
  final Value<String> goalId;
  final Value<String> title;
  final Value<String?> content;
  final Value<DateTime> reviewDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GoalReviewsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.reviewDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalReviewsCompanion.insert({
    required String id,
    required String goalId,
    required String title,
    this.content = const Value.absent(),
    required DateTime reviewDate,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        goalId = Value(goalId),
        title = Value(title),
        reviewDate = Value(reviewDate),
        createdAt = Value(createdAt);
  static Insertable<GoalReview> custom({
    Expression<String>? id,
    Expression<String>? goalId,
    Expression<String>? title,
    Expression<String>? content,
    Expression<DateTime>? reviewDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (reviewDate != null) 'review_date': reviewDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalReviewsCompanion copyWith(
      {Value<String>? id,
      Value<String>? goalId,
      Value<String>? title,
      Value<String?>? content,
      Value<DateTime>? reviewDate,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return GoalReviewsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      content: content ?? this.content,
      reviewDate: reviewDate ?? this.reviewDate,
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
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (reviewDate.present) {
      map['review_date'] = Variable<DateTime>(reviewDate.value);
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
    return (StringBuffer('GoalReviewsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('reviewDate: $reviewDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupLogsTable extends BackupLogs
    with TableInfo<$BackupLogsTable, BackupLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backupTypeMeta =
      const VerificationMeta('backupType');
  @override
  late final GeneratedColumn<String> backupType = GeneratedColumn<String>(
      'backup_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storageTypeMeta =
      const VerificationMeta('storageType');
  @override
  late final GeneratedColumn<String> storageType = GeneratedColumn<String>(
      'storage_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordCountMeta =
      const VerificationMeta('recordCount');
  @override
  late final GeneratedColumn<int> recordCount = GeneratedColumn<int>(
      'record_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _mediaCountMeta =
      const VerificationMeta('mediaCount');
  @override
  late final GeneratedColumn<int> mediaCount = GeneratedColumn<int>(
      'media_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        backupType,
        storageType,
        fileName,
        filePath,
        fileSize,
        status,
        errorMessage,
        recordCount,
        mediaCount,
        startedAt,
        completedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_logs';
  @override
  VerificationContext validateIntegrity(Insertable<BackupLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('backup_type')) {
      context.handle(
          _backupTypeMeta,
          backupType.isAcceptableOrUnknown(
              data['backup_type']!, _backupTypeMeta));
    } else if (isInserting) {
      context.missing(_backupTypeMeta);
    }
    if (data.containsKey('storage_type')) {
      context.handle(
          _storageTypeMeta,
          storageType.isAcceptableOrUnknown(
              data['storage_type']!, _storageTypeMeta));
    } else if (isInserting) {
      context.missing(_storageTypeMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('record_count')) {
      context.handle(
          _recordCountMeta,
          recordCount.isAcceptableOrUnknown(
              data['record_count']!, _recordCountMeta));
    }
    if (data.containsKey('media_count')) {
      context.handle(
          _mediaCountMeta,
          mediaCount.isAcceptableOrUnknown(
              data['media_count']!, _mediaCountMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
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
  BackupLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      backupType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backup_type'])!,
      storageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_type'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path']),
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      recordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}record_count']),
      mediaCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}media_count']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BackupLogsTable createAlias(String alias) {
    return $BackupLogsTable(attachedDatabase, alias);
  }
}

class BackupLog extends DataClass implements Insertable<BackupLog> {
  final String id;
  final String backupType;
  final String storageType;
  final String fileName;
  final String? filePath;
  final int? fileSize;
  final String status;
  final String? errorMessage;
  final int? recordCount;
  final int? mediaCount;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  const BackupLog(
      {required this.id,
      required this.backupType,
      required this.storageType,
      required this.fileName,
      this.filePath,
      this.fileSize,
      required this.status,
      this.errorMessage,
      this.recordCount,
      this.mediaCount,
      required this.startedAt,
      this.completedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['backup_type'] = Variable<String>(backupType);
    map['storage_type'] = Variable<String>(storageType);
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || recordCount != null) {
      map['record_count'] = Variable<int>(recordCount);
    }
    if (!nullToAbsent || mediaCount != null) {
      map['media_count'] = Variable<int>(mediaCount);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BackupLogsCompanion toCompanion(bool nullToAbsent) {
    return BackupLogsCompanion(
      id: Value(id),
      backupType: Value(backupType),
      storageType: Value(storageType),
      fileName: Value(fileName),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      recordCount: recordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(recordCount),
      mediaCount: mediaCount == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaCount),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
    );
  }

  factory BackupLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupLog(
      id: serializer.fromJson<String>(json['id']),
      backupType: serializer.fromJson<String>(json['backupType']),
      storageType: serializer.fromJson<String>(json['storageType']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      recordCount: serializer.fromJson<int?>(json['recordCount']),
      mediaCount: serializer.fromJson<int?>(json['mediaCount']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'backupType': serializer.toJson<String>(backupType),
      'storageType': serializer.toJson<String>(storageType),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String?>(filePath),
      'fileSize': serializer.toJson<int?>(fileSize),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'recordCount': serializer.toJson<int?>(recordCount),
      'mediaCount': serializer.toJson<int?>(mediaCount),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BackupLog copyWith(
          {String? id,
          String? backupType,
          String? storageType,
          String? fileName,
          Value<String?> filePath = const Value.absent(),
          Value<int?> fileSize = const Value.absent(),
          String? status,
          Value<String?> errorMessage = const Value.absent(),
          Value<int?> recordCount = const Value.absent(),
          Value<int?> mediaCount = const Value.absent(),
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt}) =>
      BackupLog(
        id: id ?? this.id,
        backupType: backupType ?? this.backupType,
        storageType: storageType ?? this.storageType,
        fileName: fileName ?? this.fileName,
        filePath: filePath.present ? filePath.value : this.filePath,
        fileSize: fileSize.present ? fileSize.value : this.fileSize,
        status: status ?? this.status,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        recordCount: recordCount.present ? recordCount.value : this.recordCount,
        mediaCount: mediaCount.present ? mediaCount.value : this.mediaCount,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  BackupLog copyWithCompanion(BackupLogsCompanion data) {
    return BackupLog(
      id: data.id.present ? data.id.value : this.id,
      backupType:
          data.backupType.present ? data.backupType.value : this.backupType,
      storageType:
          data.storageType.present ? data.storageType.value : this.storageType,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      recordCount:
          data.recordCount.present ? data.recordCount.value : this.recordCount,
      mediaCount:
          data.mediaCount.present ? data.mediaCount.value : this.mediaCount,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupLog(')
          ..write('id: $id, ')
          ..write('backupType: $backupType, ')
          ..write('storageType: $storageType, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('fileSize: $fileSize, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('recordCount: $recordCount, ')
          ..write('mediaCount: $mediaCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      backupType,
      storageType,
      fileName,
      filePath,
      fileSize,
      status,
      errorMessage,
      recordCount,
      mediaCount,
      startedAt,
      completedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupLog &&
          other.id == this.id &&
          other.backupType == this.backupType &&
          other.storageType == this.storageType &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.fileSize == this.fileSize &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.recordCount == this.recordCount &&
          other.mediaCount == this.mediaCount &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt);
}

class BackupLogsCompanion extends UpdateCompanion<BackupLog> {
  final Value<String> id;
  final Value<String> backupType;
  final Value<String> storageType;
  final Value<String> fileName;
  final Value<String?> filePath;
  final Value<int?> fileSize;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<int?> recordCount;
  final Value<int?> mediaCount;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BackupLogsCompanion({
    this.id = const Value.absent(),
    this.backupType = const Value.absent(),
    this.storageType = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.recordCount = const Value.absent(),
    this.mediaCount = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupLogsCompanion.insert({
    required String id,
    required String backupType,
    required String storageType,
    required String fileName,
    this.filePath = const Value.absent(),
    this.fileSize = const Value.absent(),
    required String status,
    this.errorMessage = const Value.absent(),
    this.recordCount = const Value.absent(),
    this.mediaCount = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        backupType = Value(backupType),
        storageType = Value(storageType),
        fileName = Value(fileName),
        status = Value(status),
        startedAt = Value(startedAt),
        createdAt = Value(createdAt);
  static Insertable<BackupLog> custom({
    Expression<String>? id,
    Expression<String>? backupType,
    Expression<String>? storageType,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<int>? fileSize,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<int>? recordCount,
    Expression<int>? mediaCount,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (backupType != null) 'backup_type': backupType,
      if (storageType != null) 'storage_type': storageType,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (fileSize != null) 'file_size': fileSize,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (recordCount != null) 'record_count': recordCount,
      if (mediaCount != null) 'media_count': mediaCount,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? backupType,
      Value<String>? storageType,
      Value<String>? fileName,
      Value<String?>? filePath,
      Value<int?>? fileSize,
      Value<String>? status,
      Value<String?>? errorMessage,
      Value<int?>? recordCount,
      Value<int?>? mediaCount,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BackupLogsCompanion(
      id: id ?? this.id,
      backupType: backupType ?? this.backupType,
      storageType: storageType ?? this.storageType,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      recordCount: recordCount ?? this.recordCount,
      mediaCount: mediaCount ?? this.mediaCount,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
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
    if (backupType.present) {
      map['backup_type'] = Variable<String>(backupType.value);
    }
    if (storageType.present) {
      map['storage_type'] = Variable<String>(storageType.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (recordCount.present) {
      map['record_count'] = Variable<int>(recordCount.value);
    }
    if (mediaCount.present) {
      map['media_count'] = Variable<int>(mediaCount.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
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
    return (StringBuffer('BackupLogsCompanion(')
          ..write('id: $id, ')
          ..write('backupType: $backupType, ')
          ..write('storageType: $storageType, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('fileSize: $fileSize, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('recordCount: $recordCount, ')
          ..write('mediaCount: $mediaCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnnualReviewsTable extends AnnualReviews
    with TableInfo<$AnnualReviewsTable, AnnualReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnualReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, year, content, images, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'annual_reviews';
  @override
  VerificationContext validateIntegrity(Insertable<AnnualReview> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('images')) {
      context.handle(_imagesMeta,
          images.isAcceptableOrUnknown(data['images']!, _imagesMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnnualReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnnualReview(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      images: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AnnualReviewsTable createAlias(String alias) {
    return $AnnualReviewsTable(attachedDatabase, alias);
  }
}

class AnnualReview extends DataClass implements Insertable<AnnualReview> {
  final String id;
  final int year;
  final String? content;
  final String? images;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AnnualReview(
      {required this.id,
      required this.year,
      this.content,
      this.images,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['year'] = Variable<int>(year);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || images != null) {
      map['images'] = Variable<String>(images);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AnnualReviewsCompanion toCompanion(bool nullToAbsent) {
    return AnnualReviewsCompanion(
      id: Value(id),
      year: Value(year),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      images:
          images == null && nullToAbsent ? const Value.absent() : Value(images),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AnnualReview.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnnualReview(
      id: serializer.fromJson<String>(json['id']),
      year: serializer.fromJson<int>(json['year']),
      content: serializer.fromJson<String?>(json['content']),
      images: serializer.fromJson<String?>(json['images']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'year': serializer.toJson<int>(year),
      'content': serializer.toJson<String?>(content),
      'images': serializer.toJson<String?>(images),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AnnualReview copyWith(
          {String? id,
          int? year,
          Value<String?> content = const Value.absent(),
          Value<String?> images = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      AnnualReview(
        id: id ?? this.id,
        year: year ?? this.year,
        content: content.present ? content.value : this.content,
        images: images.present ? images.value : this.images,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AnnualReview copyWithCompanion(AnnualReviewsCompanion data) {
    return AnnualReview(
      id: data.id.present ? data.id.value : this.id,
      year: data.year.present ? data.year.value : this.year,
      content: data.content.present ? data.content.value : this.content,
      images: data.images.present ? data.images.value : this.images,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnnualReview(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('content: $content, ')
          ..write('images: $images, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, year, content, images, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnnualReview &&
          other.id == this.id &&
          other.year == this.year &&
          other.content == this.content &&
          other.images == this.images &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AnnualReviewsCompanion extends UpdateCompanion<AnnualReview> {
  final Value<String> id;
  final Value<int> year;
  final Value<String?> content;
  final Value<String?> images;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AnnualReviewsCompanion({
    this.id = const Value.absent(),
    this.year = const Value.absent(),
    this.content = const Value.absent(),
    this.images = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnnualReviewsCompanion.insert({
    required String id,
    required int year,
    this.content = const Value.absent(),
    this.images = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        year = Value(year),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AnnualReview> custom({
    Expression<String>? id,
    Expression<int>? year,
    Expression<String>? content,
    Expression<String>? images,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (year != null) 'year': year,
      if (content != null) 'content': content,
      if (images != null) 'images': images,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnnualReviewsCompanion copyWith(
      {Value<String>? id,
      Value<int>? year,
      Value<String?>? content,
      Value<String?>? images,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AnnualReviewsCompanion(
      id: id ?? this.id,
      year: year ?? this.year,
      content: content ?? this.content,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnualReviewsCompanion(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('content: $content, ')
          ..write('images: $images, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecordEmbeddingsTable extends RecordEmbeddings
    with TableInfo<$RecordEmbeddingsTable, RecordEmbedding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _embeddingMeta =
      const VerificationMeta('embedding');
  @override
  late final GeneratedColumn<Uint8List> embedding = GeneratedColumn<Uint8List>(
      'embedding', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _dimensionMeta =
      const VerificationMeta('dimension');
  @override
  late final GeneratedColumn<int> dimension = GeneratedColumn<int>(
      'dimension', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _modelNameMeta =
      const VerificationMeta('modelName');
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
      'model_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTextMeta =
      const VerificationMeta('sourceText');
  @override
  late final GeneratedColumn<String> sourceText = GeneratedColumn<String>(
      'source_text', aliasedName, true,
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        embedding,
        dimension,
        modelName,
        sourceText,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'record_embeddings';
  @override
  VerificationContext validateIntegrity(Insertable<RecordEmbedding> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('embedding')) {
      context.handle(_embeddingMeta,
          embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta));
    } else if (isInserting) {
      context.missing(_embeddingMeta);
    }
    if (data.containsKey('dimension')) {
      context.handle(_dimensionMeta,
          dimension.isAcceptableOrUnknown(data['dimension']!, _dimensionMeta));
    } else if (isInserting) {
      context.missing(_dimensionMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(_modelNameMeta,
          modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta));
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('source_text')) {
      context.handle(
          _sourceTextMeta,
          sourceText.isAcceptableOrUnknown(
              data['source_text']!, _sourceTextMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {entityType, entityId},
      ];
  @override
  RecordEmbedding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecordEmbedding(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      embedding: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}embedding'])!,
      dimension: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dimension'])!,
      modelName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_name'])!,
      sourceText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_text']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RecordEmbeddingsTable createAlias(String alias) {
    return $RecordEmbeddingsTable(attachedDatabase, alias);
  }
}

class RecordEmbedding extends DataClass implements Insertable<RecordEmbedding> {
  final String id;
  final String entityType;
  final String entityId;
  final Uint8List embedding;
  final int dimension;
  final String modelName;
  final String? sourceText;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RecordEmbedding(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.embedding,
      required this.dimension,
      required this.modelName,
      this.sourceText,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['embedding'] = Variable<Uint8List>(embedding);
    map['dimension'] = Variable<int>(dimension);
    map['model_name'] = Variable<String>(modelName);
    if (!nullToAbsent || sourceText != null) {
      map['source_text'] = Variable<String>(sourceText);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecordEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return RecordEmbeddingsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      embedding: Value(embedding),
      dimension: Value(dimension),
      modelName: Value(modelName),
      sourceText: sourceText == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecordEmbedding.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecordEmbedding(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      embedding: serializer.fromJson<Uint8List>(json['embedding']),
      dimension: serializer.fromJson<int>(json['dimension']),
      modelName: serializer.fromJson<String>(json['modelName']),
      sourceText: serializer.fromJson<String?>(json['sourceText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'embedding': serializer.toJson<Uint8List>(embedding),
      'dimension': serializer.toJson<int>(dimension),
      'modelName': serializer.toJson<String>(modelName),
      'sourceText': serializer.toJson<String?>(sourceText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RecordEmbedding copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          Uint8List? embedding,
          int? dimension,
          String? modelName,
          Value<String?> sourceText = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RecordEmbedding(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        embedding: embedding ?? this.embedding,
        dimension: dimension ?? this.dimension,
        modelName: modelName ?? this.modelName,
        sourceText: sourceText.present ? sourceText.value : this.sourceText,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RecordEmbedding copyWithCompanion(RecordEmbeddingsCompanion data) {
    return RecordEmbedding(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      dimension: data.dimension.present ? data.dimension.value : this.dimension,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      sourceText:
          data.sourceText.present ? data.sourceText.value : this.sourceText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecordEmbedding(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('embedding: $embedding, ')
          ..write('dimension: $dimension, ')
          ..write('modelName: $modelName, ')
          ..write('sourceText: $sourceText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entityType,
      entityId,
      $driftBlobEquality.hash(embedding),
      dimension,
      modelName,
      sourceText,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecordEmbedding &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          $driftBlobEquality.equals(other.embedding, this.embedding) &&
          other.dimension == this.dimension &&
          other.modelName == this.modelName &&
          other.sourceText == this.sourceText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecordEmbeddingsCompanion extends UpdateCompanion<RecordEmbedding> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<Uint8List> embedding;
  final Value<int> dimension;
  final Value<String> modelName;
  final Value<String?> sourceText;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RecordEmbeddingsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.embedding = const Value.absent(),
    this.dimension = const Value.absent(),
    this.modelName = const Value.absent(),
    this.sourceText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecordEmbeddingsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required Uint8List embedding,
    required int dimension,
    required String modelName,
    this.sourceText = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        embedding = Value(embedding),
        dimension = Value(dimension),
        modelName = Value(modelName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RecordEmbedding> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<Uint8List>? embedding,
    Expression<int>? dimension,
    Expression<String>? modelName,
    Expression<String>? sourceText,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (embedding != null) 'embedding': embedding,
      if (dimension != null) 'dimension': dimension,
      if (modelName != null) 'model_name': modelName,
      if (sourceText != null) 'source_text': sourceText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecordEmbeddingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<Uint8List>? embedding,
      Value<int>? dimension,
      Value<String>? modelName,
      Value<String?>? sourceText,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RecordEmbeddingsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      embedding: embedding ?? this.embedding,
      dimension: dimension ?? this.dimension,
      modelName: modelName ?? this.modelName,
      sourceText: sourceText ?? this.sourceText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<Uint8List>(embedding.value);
    }
    if (dimension.present) {
      map['dimension'] = Variable<int>(dimension.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (sourceText.present) {
      map['source_text'] = Variable<String>(sourceText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordEmbeddingsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('embedding: $embedding, ')
          ..write('dimension: $dimension, ')
          ..write('modelName: $modelName, ')
          ..write('sourceText: $sourceText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatSessionsTable extends ChatSessions
    with TableInfo<$ChatSessionsTable, ChatSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('新对话'));
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, true,
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
  static const VerificationMeta _lastMessageAtMeta =
      const VerificationMeta('lastMessageAt');
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>('last_message_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
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
        summary,
        createdAt,
        updatedAt,
        lastMessageAt,
        isArchived,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<ChatSession> instance,
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
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
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
    if (data.containsKey('last_message_at')) {
      context.handle(
          _lastMessageAtMeta,
          lastMessageAt.isAcceptableOrUnknown(
              data['last_message_at']!, _lastMessageAtMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
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
  ChatSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      lastMessageAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_message_at']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $ChatSessionsTable createAlias(String alias) {
    return $ChatSessionsTable(attachedDatabase, alias);
  }
}

class ChatSession extends DataClass implements Insertable<ChatSession> {
  final String id;
  final String title;
  final String? summary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final bool isArchived;
  final bool isDeleted;
  const ChatSession(
      {required this.id,
      required this.title,
      this.summary,
      required this.createdAt,
      required this.updatedAt,
      this.lastMessageAt,
      required this.isArchived,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  ChatSessionsCompanion toCompanion(bool nullToAbsent) {
    return ChatSessionsCompanion(
      id: Value(id),
      title: Value(title),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      isArchived: Value(isArchived),
      isDeleted: Value(isDeleted),
    );
  }

  factory ChatSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSession(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String?>(json['summary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String?>(summary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
      'isArchived': serializer.toJson<bool>(isArchived),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  ChatSession copyWith(
          {String? id,
          String? title,
          Value<String?> summary = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> lastMessageAt = const Value.absent(),
          bool? isArchived,
          bool? isDeleted}) =>
      ChatSession(
        id: id ?? this.id,
        title: title ?? this.title,
        summary: summary.present ? summary.value : this.summary,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastMessageAt:
            lastMessageAt.present ? lastMessageAt.value : this.lastMessageAt,
        isArchived: isArchived ?? this.isArchived,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  ChatSession copyWithCompanion(ChatSessionsCompanion data) {
    return ChatSession(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSession(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, summary, createdAt, updatedAt,
      lastMessageAt, isArchived, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSession &&
          other.id == this.id &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastMessageAt == this.lastMessageAt &&
          other.isArchived == this.isArchived &&
          other.isDeleted == this.isDeleted);
}

class ChatSessionsCompanion extends UpdateCompanion<ChatSession> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> summary;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastMessageAt;
  final Value<bool> isArchived;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const ChatSessionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatSessionsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastMessageAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ChatSession> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastMessageAt,
    Expression<bool>? isArchived,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? summary,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? lastMessageAt,
      Value<bool>? isArchived,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return ChatSessionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isArchived: isArchived ?? this.isArchived,
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
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
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
    return (StringBuffer('ChatSessionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recommendationsMeta =
      const VerificationMeta('recommendations');
  @override
  late final GeneratedColumn<String> recommendations = GeneratedColumn<String>(
      'recommendations', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, role, content, recommendations, timestamp, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('recommendations')) {
      context.handle(
          _recommendationsMeta,
          recommendations.isAcceptableOrUnknown(
              data['recommendations']!, _recommendationsMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
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
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      recommendations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recommendations']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final String? recommendations;
  final DateTime timestamp;
  final DateTime createdAt;
  const ChatMessage(
      {required this.id,
      required this.sessionId,
      required this.role,
      required this.content,
      this.recommendations,
      required this.timestamp,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || recommendations != null) {
      map['recommendations'] = Variable<String>(recommendations);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      role: Value(role),
      content: Value(content),
      recommendations: recommendations == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendations),
      timestamp: Value(timestamp),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      recommendations: serializer.fromJson<String?>(json['recommendations']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'recommendations': serializer.toJson<String?>(recommendations),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessage copyWith(
          {String? id,
          String? sessionId,
          String? role,
          String? content,
          Value<String?> recommendations = const Value.absent(),
          DateTime? timestamp,
          DateTime? createdAt}) =>
      ChatMessage(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        role: role ?? this.role,
        content: content ?? this.content,
        recommendations: recommendations.present
            ? recommendations.value
            : this.recommendations,
        timestamp: timestamp ?? this.timestamp,
        createdAt: createdAt ?? this.createdAt,
      );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      recommendations: data.recommendations.present
          ? data.recommendations.value
          : this.recommendations,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('recommendations: $recommendations, ')
          ..write('timestamp: $timestamp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, sessionId, role, content, recommendations, timestamp, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.role == this.role &&
          other.content == this.content &&
          other.recommendations == this.recommendations &&
          other.timestamp == this.timestamp &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> recommendations;
  final Value<DateTime> timestamp;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.recommendations = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String sessionId,
    required String role,
    required String content,
    this.recommendations = const Value.absent(),
    required DateTime timestamp,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        role = Value(role),
        content = Value(content),
        timestamp = Value(timestamp),
        createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? recommendations,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (recommendations != null) 'recommendations': recommendations,
      if (timestamp != null) 'timestamp': timestamp,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? role,
      Value<String>? content,
      Value<String?>? recommendations,
      Value<DateTime>? timestamp,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      recommendations: recommendations ?? this.recommendations,
      timestamp: timestamp ?? this.timestamp,
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
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (recommendations.present) {
      map['recommendations'] = Variable<String>(recommendations.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
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
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('recommendations: $recommendations, ')
          ..write('timestamp: $timestamp, ')
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
  late final $TravelRecordsTable travelRecords = $TravelRecordsTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $GoalRecordsTable goalRecords = $GoalRecordsTable(this);
  late final $TimelineEventsTable timelineEvents = $TimelineEventsTable(this);
  late final $EntityLinksTable entityLinks = $EntityLinksTable(this);
  late final $LinkLogsTable linkLogs = $LinkLogsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $AiProvidersTable aiProviders = $AiProvidersTable(this);
  late final $ChangeLogsTable changeLogs = $ChangeLogsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $ChecklistItemsTable checklistItems = $ChecklistItemsTable(this);
  late final $GoalPostponementsTable goalPostponements =
      $GoalPostponementsTable(this);
  late final $GoalReviewsTable goalReviews = $GoalReviewsTable(this);
  late final $BackupLogsTable backupLogs = $BackupLogsTable(this);
  late final $AnnualReviewsTable annualReviews = $AnnualReviewsTable(this);
  late final $RecordEmbeddingsTable recordEmbeddings =
      $RecordEmbeddingsTable(this);
  late final $ChatSessionsTable chatSessions = $ChatSessionsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final FoodDao foodDao = FoodDao(this as AppDatabase);
  late final MomentDao momentDao = MomentDao(this as AppDatabase);
  late final FriendDao friendDao = FriendDao(this as AppDatabase);
  late final LinkDao linkDao = LinkDao(this as AppDatabase);
  late final AiProviderDao aiProviderDao = AiProviderDao(this as AppDatabase);
  late final ChangeLogDao changeLogDao = ChangeLogDao(this as AppDatabase);
  late final SyncStateDao syncStateDao = SyncStateDao(this as AppDatabase);
  late final ChecklistDao checklistDao = ChecklistDao(this as AppDatabase);
  late final GoalPostponementDao goalPostponementDao =
      GoalPostponementDao(this as AppDatabase);
  late final GoalReviewDao goalReviewDao = GoalReviewDao(this as AppDatabase);
  late final BackupLogDao backupLogDao = BackupLogDao(this as AppDatabase);
  late final AnnualReviewDao annualReviewDao =
      AnnualReviewDao(this as AppDatabase);
  late final EmbeddingDao embeddingDao = EmbeddingDao(this as AppDatabase);
  late final TravelDao travelDao = TravelDao(this as AppDatabase);
  late final GoalDao goalDao = GoalDao(this as AppDatabase);
  late final ChatDao chatDao = ChatDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        foodRecords,
        momentRecords,
        friendRecords,
        travelRecords,
        trips,
        goalRecords,
        timelineEvents,
        entityLinks,
        linkLogs,
        userProfiles,
        aiProviders,
        changeLogs,
        syncState,
        checklistItems,
        goalPostponements,
        goalReviews,
        backupLogs,
        annualReviews,
        recordEmbeddings,
        chatSessions,
        chatMessages
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
  Value<String?> poiAddress,
  Value<String?> city,
  Value<String?> country,
  Value<String?> mood,
  Value<bool> isWishlist,
  Value<bool> isFavorite,
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
  Value<String?> poiAddress,
  Value<String?> city,
  Value<String?> country,
  Value<String?> mood,
  Value<bool> isWishlist,
  Value<bool> isFavorite,
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

  ColumnFilters<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

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
            Value<String?> poiAddress = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> country = const Value.absent(),
            Value<String?> mood = const Value.absent(),
            Value<bool> isWishlist = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
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
            poiAddress: poiAddress,
            city: city,
            country: country,
            mood: mood,
            isWishlist: isWishlist,
            isFavorite: isFavorite,
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
            Value<String?> poiAddress = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> country = const Value.absent(),
            Value<String?> mood = const Value.absent(),
            Value<bool> isWishlist = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
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
            poiAddress: poiAddress,
            city: city,
            country: country,
            mood: mood,
            isWishlist: isWishlist,
            isFavorite: isFavorite,
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
  Value<String?> tags,
  Value<String?> poiName,
  Value<String?> poiAddress,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> city,
  Value<bool> isFavorite,
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
  Value<String?> tags,
  Value<String?> poiName,
  Value<String?> poiAddress,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> city,
  Value<bool> isFavorite,
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

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poiName => $composableBuilder(
      column: $table.poiName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poiName => $composableBuilder(
      column: $table.poiName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get poiName =>
      $composableBuilder(column: $table.poiName, builder: (column) => column);

  GeneratedColumn<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

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
            Value<String?> tags = const Value.absent(),
            Value<String?> poiName = const Value.absent(),
            Value<String?> poiAddress = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
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
            tags: tags,
            poiName: poiName,
            poiAddress: poiAddress,
            latitude: latitude,
            longitude: longitude,
            city: city,
            isFavorite: isFavorite,
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
            Value<String?> tags = const Value.absent(),
            Value<String?> poiName = const Value.absent(),
            Value<String?> poiAddress = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
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
            tags: tags,
            poiName: poiName,
            poiAddress: poiAddress,
            latitude: latitude,
            longitude: longitude,
            city: city,
            isFavorite: isFavorite,
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
  Value<bool> isFavorite,
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
  Value<bool> isFavorite,
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

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

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
            Value<bool> isFavorite = const Value.absent(),
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
            isFavorite: isFavorite,
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
            Value<bool> isFavorite = const Value.absent(),
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
            isFavorite: isFavorite,
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
typedef $$TravelRecordsTableCreateCompanionBuilder = TravelRecordsCompanion
    Function({
  required String id,
  required String tripId,
  Value<String?> title,
  Value<String?> content,
  Value<String?> images,
  Value<String?> destination,
  Value<String?> poiName,
  Value<String?> poiAddress,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> city,
  Value<String?> country,
  Value<String?> mood,
  Value<String?> tags,
  Value<double?> expenseTransport,
  Value<double?> expenseHotel,
  Value<double?> expenseFood,
  Value<double?> expenseTicket,
  Value<String?> flightLink,
  Value<String?> hotelLink,
  Value<bool> isWishlist,
  Value<bool> isFavorite,
  Value<bool> wishlistDone,
  Value<bool> isJournal,
  Value<DateTime?> planDate,
  required DateTime recordDate,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$TravelRecordsTableUpdateCompanionBuilder = TravelRecordsCompanion
    Function({
  Value<String> id,
  Value<String> tripId,
  Value<String?> title,
  Value<String?> content,
  Value<String?> images,
  Value<String?> destination,
  Value<String?> poiName,
  Value<String?> poiAddress,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> city,
  Value<String?> country,
  Value<String?> mood,
  Value<String?> tags,
  Value<double?> expenseTransport,
  Value<double?> expenseHotel,
  Value<double?> expenseFood,
  Value<double?> expenseTicket,
  Value<String?> flightLink,
  Value<String?> hotelLink,
  Value<bool> isWishlist,
  Value<bool> isFavorite,
  Value<bool> wishlistDone,
  Value<bool> isJournal,
  Value<DateTime?> planDate,
  Value<DateTime> recordDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$TravelRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TravelRecordsTable> {
  $$TravelRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get images => $composableBuilder(
      column: $table.images, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poiName => $composableBuilder(
      column: $table.poiName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get expenseTransport => $composableBuilder(
      column: $table.expenseTransport,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get expenseHotel => $composableBuilder(
      column: $table.expenseHotel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get expenseFood => $composableBuilder(
      column: $table.expenseFood, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get expenseTicket => $composableBuilder(
      column: $table.expenseTicket, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flightLink => $composableBuilder(
      column: $table.flightLink, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hotelLink => $composableBuilder(
      column: $table.hotelLink, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wishlistDone => $composableBuilder(
      column: $table.wishlistDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isJournal => $composableBuilder(
      column: $table.isJournal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get planDate => $composableBuilder(
      column: $table.planDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
}

class $$TravelRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TravelRecordsTable> {
  $$TravelRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get images => $composableBuilder(
      column: $table.images, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poiName => $composableBuilder(
      column: $table.poiName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get expenseTransport => $composableBuilder(
      column: $table.expenseTransport,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get expenseHotel => $composableBuilder(
      column: $table.expenseHotel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get expenseFood => $composableBuilder(
      column: $table.expenseFood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get expenseTicket => $composableBuilder(
      column: $table.expenseTicket,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flightLink => $composableBuilder(
      column: $table.flightLink, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hotelLink => $composableBuilder(
      column: $table.hotelLink, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wishlistDone => $composableBuilder(
      column: $table.wishlistDone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isJournal => $composableBuilder(
      column: $table.isJournal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get planDate => $composableBuilder(
      column: $table.planDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$TravelRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TravelRecordsTable> {
  $$TravelRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => column);

  GeneratedColumn<String> get poiName =>
      $composableBuilder(column: $table.poiName, builder: (column) => column);

  GeneratedColumn<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<double> get expenseTransport => $composableBuilder(
      column: $table.expenseTransport, builder: (column) => column);

  GeneratedColumn<double> get expenseHotel => $composableBuilder(
      column: $table.expenseHotel, builder: (column) => column);

  GeneratedColumn<double> get expenseFood => $composableBuilder(
      column: $table.expenseFood, builder: (column) => column);

  GeneratedColumn<double> get expenseTicket => $composableBuilder(
      column: $table.expenseTicket, builder: (column) => column);

  GeneratedColumn<String> get flightLink => $composableBuilder(
      column: $table.flightLink, builder: (column) => column);

  GeneratedColumn<String> get hotelLink =>
      $composableBuilder(column: $table.hotelLink, builder: (column) => column);

  GeneratedColumn<bool> get isWishlist => $composableBuilder(
      column: $table.isWishlist, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get wishlistDone => $composableBuilder(
      column: $table.wishlistDone, builder: (column) => column);

  GeneratedColumn<bool> get isJournal =>
      $composableBuilder(column: $table.isJournal, builder: (column) => column);

  GeneratedColumn<DateTime> get planDate =>
      $composableBuilder(column: $table.planDate, builder: (column) => column);

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$TravelRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TravelRecordsTable,
    TravelRecord,
    $$TravelRecordsTableFilterComposer,
    $$TravelRecordsTableOrderingComposer,
    $$TravelRecordsTableAnnotationComposer,
    $$TravelRecordsTableCreateCompanionBuilder,
    $$TravelRecordsTableUpdateCompanionBuilder,
    (
      TravelRecord,
      BaseReferences<_$AppDatabase, $TravelRecordsTable, TravelRecord>
    ),
    TravelRecord,
    PrefetchHooks Function()> {
  $$TravelRecordsTableTableManager(_$AppDatabase db, $TravelRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TravelRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TravelRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TravelRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> images = const Value.absent(),
            Value<String?> destination = const Value.absent(),
            Value<String?> poiName = const Value.absent(),
            Value<String?> poiAddress = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> country = const Value.absent(),
            Value<String?> mood = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<double?> expenseTransport = const Value.absent(),
            Value<double?> expenseHotel = const Value.absent(),
            Value<double?> expenseFood = const Value.absent(),
            Value<double?> expenseTicket = const Value.absent(),
            Value<String?> flightLink = const Value.absent(),
            Value<String?> hotelLink = const Value.absent(),
            Value<bool> isWishlist = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> wishlistDone = const Value.absent(),
            Value<bool> isJournal = const Value.absent(),
            Value<DateTime?> planDate = const Value.absent(),
            Value<DateTime> recordDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TravelRecordsCompanion(
            id: id,
            tripId: tripId,
            title: title,
            content: content,
            images: images,
            destination: destination,
            poiName: poiName,
            poiAddress: poiAddress,
            latitude: latitude,
            longitude: longitude,
            city: city,
            country: country,
            mood: mood,
            tags: tags,
            expenseTransport: expenseTransport,
            expenseHotel: expenseHotel,
            expenseFood: expenseFood,
            expenseTicket: expenseTicket,
            flightLink: flightLink,
            hotelLink: hotelLink,
            isWishlist: isWishlist,
            isFavorite: isFavorite,
            wishlistDone: wishlistDone,
            isJournal: isJournal,
            planDate: planDate,
            recordDate: recordDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            Value<String?> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> images = const Value.absent(),
            Value<String?> destination = const Value.absent(),
            Value<String?> poiName = const Value.absent(),
            Value<String?> poiAddress = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> country = const Value.absent(),
            Value<String?> mood = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<double?> expenseTransport = const Value.absent(),
            Value<double?> expenseHotel = const Value.absent(),
            Value<double?> expenseFood = const Value.absent(),
            Value<double?> expenseTicket = const Value.absent(),
            Value<String?> flightLink = const Value.absent(),
            Value<String?> hotelLink = const Value.absent(),
            Value<bool> isWishlist = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> wishlistDone = const Value.absent(),
            Value<bool> isJournal = const Value.absent(),
            Value<DateTime?> planDate = const Value.absent(),
            required DateTime recordDate,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TravelRecordsCompanion.insert(
            id: id,
            tripId: tripId,
            title: title,
            content: content,
            images: images,
            destination: destination,
            poiName: poiName,
            poiAddress: poiAddress,
            latitude: latitude,
            longitude: longitude,
            city: city,
            country: country,
            mood: mood,
            tags: tags,
            expenseTransport: expenseTransport,
            expenseHotel: expenseHotel,
            expenseFood: expenseFood,
            expenseTicket: expenseTicket,
            flightLink: flightLink,
            hotelLink: hotelLink,
            isWishlist: isWishlist,
            isFavorite: isFavorite,
            wishlistDone: wishlistDone,
            isJournal: isJournal,
            planDate: planDate,
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

typedef $$TravelRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TravelRecordsTable,
    TravelRecord,
    $$TravelRecordsTableFilterComposer,
    $$TravelRecordsTableOrderingComposer,
    $$TravelRecordsTableAnnotationComposer,
    $$TravelRecordsTableCreateCompanionBuilder,
    $$TravelRecordsTableUpdateCompanionBuilder,
    (
      TravelRecord,
      BaseReferences<_$AppDatabase, $TravelRecordsTable, TravelRecord>
    ),
    TravelRecord,
    PrefetchHooks Function()>;
typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  required String id,
  required String name,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String?> destinations,
  Value<double?> totalExpense,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String?> destinations,
  Value<double?> totalExpense,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
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

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinations => $composableBuilder(
      column: $table.destinations, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalExpense => $composableBuilder(
      column: $table.totalExpense, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinations => $composableBuilder(
      column: $table.destinations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalExpense => $composableBuilder(
      column: $table.totalExpense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get destinations => $composableBuilder(
      column: $table.destinations, builder: (column) => column);

  GeneratedColumn<double> get totalExpense => $composableBuilder(
      column: $table.totalExpense, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TripsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TripsTable,
    Trip,
    $$TripsTableFilterComposer,
    $$TripsTableOrderingComposer,
    $$TripsTableAnnotationComposer,
    $$TripsTableCreateCompanionBuilder,
    $$TripsTableUpdateCompanionBuilder,
    (Trip, BaseReferences<_$AppDatabase, $TripsTable, Trip>),
    Trip,
    PrefetchHooks Function()> {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String?> destinations = const Value.absent(),
            Value<double?> totalExpense = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TripsCompanion(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            destinations: destinations,
            totalExpense: totalExpense,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String?> destinations = const Value.absent(),
            Value<double?> totalExpense = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TripsCompanion.insert(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            destinations: destinations,
            totalExpense: totalExpense,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TripsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TripsTable,
    Trip,
    $$TripsTableFilterComposer,
    $$TripsTableOrderingComposer,
    $$TripsTableAnnotationComposer,
    $$TripsTableCreateCompanionBuilder,
    $$TripsTableUpdateCompanionBuilder,
    (Trip, BaseReferences<_$AppDatabase, $TripsTable, Trip>),
    Trip,
    PrefetchHooks Function()>;
typedef $$GoalRecordsTableCreateCompanionBuilder = GoalRecordsCompanion
    Function({
  required String id,
  Value<String?> parentId,
  required String level,
  required String title,
  Value<String?> note,
  Value<String?> summary,
  Value<String?> category,
  Value<String?> tags,
  Value<double> progress,
  Value<bool> isCompleted,
  Value<bool> isPostponed,
  Value<bool> isFavorite,
  Value<String?> remindFrequency,
  Value<int?> targetYear,
  Value<int?> targetQuarter,
  Value<int?> targetMonth,
  Value<DateTime?> dueDate,
  required DateTime recordDate,
  Value<DateTime?> completedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$GoalRecordsTableUpdateCompanionBuilder = GoalRecordsCompanion
    Function({
  Value<String> id,
  Value<String?> parentId,
  Value<String> level,
  Value<String> title,
  Value<String?> note,
  Value<String?> summary,
  Value<String?> category,
  Value<String?> tags,
  Value<double> progress,
  Value<bool> isCompleted,
  Value<bool> isPostponed,
  Value<bool> isFavorite,
  Value<String?> remindFrequency,
  Value<int?> targetYear,
  Value<int?> targetQuarter,
  Value<int?> targetMonth,
  Value<DateTime?> dueDate,
  Value<DateTime> recordDate,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$GoalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalRecordsTable> {
  $$GoalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPostponed => $composableBuilder(
      column: $table.isPostponed, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remindFrequency => $composableBuilder(
      column: $table.remindFrequency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetYear => $composableBuilder(
      column: $table.targetYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetQuarter => $composableBuilder(
      column: $table.targetQuarter, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetMonth => $composableBuilder(
      column: $table.targetMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
}

class $$GoalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalRecordsTable> {
  $$GoalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPostponed => $composableBuilder(
      column: $table.isPostponed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remindFrequency => $composableBuilder(
      column: $table.remindFrequency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetYear => $composableBuilder(
      column: $table.targetYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetQuarter => $composableBuilder(
      column: $table.targetQuarter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetMonth => $composableBuilder(
      column: $table.targetMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$GoalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalRecordsTable> {
  $$GoalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get isPostponed => $composableBuilder(
      column: $table.isPostponed, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<String> get remindFrequency => $composableBuilder(
      column: $table.remindFrequency, builder: (column) => column);

  GeneratedColumn<int> get targetYear => $composableBuilder(
      column: $table.targetYear, builder: (column) => column);

  GeneratedColumn<int> get targetQuarter => $composableBuilder(
      column: $table.targetQuarter, builder: (column) => column);

  GeneratedColumn<int> get targetMonth => $composableBuilder(
      column: $table.targetMonth, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$GoalRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalRecordsTable,
    GoalRecord,
    $$GoalRecordsTableFilterComposer,
    $$GoalRecordsTableOrderingComposer,
    $$GoalRecordsTableAnnotationComposer,
    $$GoalRecordsTableCreateCompanionBuilder,
    $$GoalRecordsTableUpdateCompanionBuilder,
    (GoalRecord, BaseReferences<_$AppDatabase, $GoalRecordsTable, GoalRecord>),
    GoalRecord,
    PrefetchHooks Function()> {
  $$GoalRecordsTableTableManager(_$AppDatabase db, $GoalRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String> level = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isPostponed = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String?> remindFrequency = const Value.absent(),
            Value<int?> targetYear = const Value.absent(),
            Value<int?> targetQuarter = const Value.absent(),
            Value<int?> targetMonth = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime> recordDate = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalRecordsCompanion(
            id: id,
            parentId: parentId,
            level: level,
            title: title,
            note: note,
            summary: summary,
            category: category,
            tags: tags,
            progress: progress,
            isCompleted: isCompleted,
            isPostponed: isPostponed,
            isFavorite: isFavorite,
            remindFrequency: remindFrequency,
            targetYear: targetYear,
            targetQuarter: targetQuarter,
            targetMonth: targetMonth,
            dueDate: dueDate,
            recordDate: recordDate,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> parentId = const Value.absent(),
            required String level,
            required String title,
            Value<String?> note = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isPostponed = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String?> remindFrequency = const Value.absent(),
            Value<int?> targetYear = const Value.absent(),
            Value<int?> targetQuarter = const Value.absent(),
            Value<int?> targetMonth = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            required DateTime recordDate,
            Value<DateTime?> completedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalRecordsCompanion.insert(
            id: id,
            parentId: parentId,
            level: level,
            title: title,
            note: note,
            summary: summary,
            category: category,
            tags: tags,
            progress: progress,
            isCompleted: isCompleted,
            isPostponed: isPostponed,
            isFavorite: isFavorite,
            remindFrequency: remindFrequency,
            targetYear: targetYear,
            targetQuarter: targetQuarter,
            targetMonth: targetMonth,
            dueDate: dueDate,
            recordDate: recordDate,
            completedAt: completedAt,
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

typedef $$GoalRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalRecordsTable,
    GoalRecord,
    $$GoalRecordsTableFilterComposer,
    $$GoalRecordsTableOrderingComposer,
    $$GoalRecordsTableAnnotationComposer,
    $$GoalRecordsTableCreateCompanionBuilder,
    $$GoalRecordsTableUpdateCompanionBuilder,
    (GoalRecord, BaseReferences<_$AppDatabase, $GoalRecordsTable, GoalRecord>),
    GoalRecord,
    PrefetchHooks Function()>;
typedef $$TimelineEventsTableCreateCompanionBuilder = TimelineEventsCompanion
    Function({
  required String id,
  required String title,
  required String eventType,
  Value<DateTime?> startAt,
  Value<DateTime?> endAt,
  Value<String?> note,
  Value<String?> tags,
  Value<String?> poiName,
  Value<String?> poiAddress,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<bool> isFavorite,
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
  Value<String?> tags,
  Value<String?> poiName,
  Value<String?> poiAddress,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<bool> isFavorite,
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

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poiName => $composableBuilder(
      column: $table.poiName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poiName => $composableBuilder(
      column: $table.poiName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get poiName =>
      $composableBuilder(column: $table.poiName, builder: (column) => column);

  GeneratedColumn<String> get poiAddress => $composableBuilder(
      column: $table.poiAddress, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

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
            Value<String?> tags = const Value.absent(),
            Value<String?> poiName = const Value.absent(),
            Value<String?> poiAddress = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
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
            tags: tags,
            poiName: poiName,
            poiAddress: poiAddress,
            latitude: latitude,
            longitude: longitude,
            isFavorite: isFavorite,
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
            Value<String?> tags = const Value.absent(),
            Value<String?> poiName = const Value.absent(),
            Value<String?> poiAddress = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
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
            tags: tags,
            poiName: poiName,
            poiAddress: poiAddress,
            latitude: latitude,
            longitude: longitude,
            isFavorite: isFavorite,
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
typedef $$UserProfilesTableCreateCompanionBuilder = UserProfilesCompanion
    Function({
  required String id,
  required String displayName,
  Value<DateTime?> birthday,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<String?> relationshipStatus,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$UserProfilesTableUpdateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<String> id,
  Value<String> displayName,
  Value<DateTime?> birthday,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<String?> relationshipStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthday => $composableBuilder(
      column: $table.birthday, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relationshipStatus => $composableBuilder(
      column: $table.relationshipStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthday => $composableBuilder(
      column: $table.birthday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relationshipStatus => $composableBuilder(
      column: $table.relationshipStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<DateTime> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get relationshipStatus => $composableBuilder(
      column: $table.relationshipStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()> {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<DateTime?> birthday = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<String?> relationshipStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion(
            id: id,
            displayName: displayName,
            birthday: birthday,
            heightCm: heightCm,
            weightKg: weightKg,
            relationshipStatus: relationshipStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String displayName,
            Value<DateTime?> birthday = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<String?> relationshipStatus = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion.insert(
            id: id,
            displayName: displayName,
            birthday: birthday,
            heightCm: heightCm,
            weightKg: weightKg,
            relationshipStatus: relationshipStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()>;
typedef $$AiProvidersTableCreateCompanionBuilder = AiProvidersCompanion
    Function({
  required String id,
  required String name,
  required String apiType,
  required String serviceType,
  required String baseUrl,
  required String apiKey,
  Value<String?> modelName,
  Value<String?> extraConfig,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AiProvidersTableUpdateCompanionBuilder = AiProvidersCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> apiType,
  Value<String> serviceType,
  Value<String> baseUrl,
  Value<String> apiKey,
  Value<String?> modelName,
  Value<String?> extraConfig,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AiProvidersTableFilterComposer
    extends Composer<_$AppDatabase, $AiProvidersTable> {
  $$AiProvidersTableFilterComposer({
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

  ColumnFilters<String> get apiType => $composableBuilder(
      column: $table.apiType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseUrl => $composableBuilder(
      column: $table.baseUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get apiKey => $composableBuilder(
      column: $table.apiKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extraConfig => $composableBuilder(
      column: $table.extraConfig, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AiProvidersTableOrderingComposer
    extends Composer<_$AppDatabase, $AiProvidersTable> {
  $$AiProvidersTableOrderingComposer({
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

  ColumnOrderings<String> get apiType => $composableBuilder(
      column: $table.apiType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseUrl => $composableBuilder(
      column: $table.baseUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get apiKey => $composableBuilder(
      column: $table.apiKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extraConfig => $composableBuilder(
      column: $table.extraConfig, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AiProvidersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiProvidersTable> {
  $$AiProvidersTableAnnotationComposer({
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

  GeneratedColumn<String> get apiType =>
      $composableBuilder(column: $table.apiType, builder: (column) => column);

  GeneratedColumn<String> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get apiKey =>
      $composableBuilder(column: $table.apiKey, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get extraConfig => $composableBuilder(
      column: $table.extraConfig, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AiProvidersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiProvidersTable,
    AiProvider,
    $$AiProvidersTableFilterComposer,
    $$AiProvidersTableOrderingComposer,
    $$AiProvidersTableAnnotationComposer,
    $$AiProvidersTableCreateCompanionBuilder,
    $$AiProvidersTableUpdateCompanionBuilder,
    (AiProvider, BaseReferences<_$AppDatabase, $AiProvidersTable, AiProvider>),
    AiProvider,
    PrefetchHooks Function()> {
  $$AiProvidersTableTableManager(_$AppDatabase db, $AiProvidersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiProvidersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiProvidersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiProvidersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> apiType = const Value.absent(),
            Value<String> serviceType = const Value.absent(),
            Value<String> baseUrl = const Value.absent(),
            Value<String> apiKey = const Value.absent(),
            Value<String?> modelName = const Value.absent(),
            Value<String?> extraConfig = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AiProvidersCompanion(
            id: id,
            name: name,
            apiType: apiType,
            serviceType: serviceType,
            baseUrl: baseUrl,
            apiKey: apiKey,
            modelName: modelName,
            extraConfig: extraConfig,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String apiType,
            required String serviceType,
            required String baseUrl,
            required String apiKey,
            Value<String?> modelName = const Value.absent(),
            Value<String?> extraConfig = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AiProvidersCompanion.insert(
            id: id,
            name: name,
            apiType: apiType,
            serviceType: serviceType,
            baseUrl: baseUrl,
            apiKey: apiKey,
            modelName: modelName,
            extraConfig: extraConfig,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AiProvidersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiProvidersTable,
    AiProvider,
    $$AiProvidersTableFilterComposer,
    $$AiProvidersTableOrderingComposer,
    $$AiProvidersTableAnnotationComposer,
    $$AiProvidersTableCreateCompanionBuilder,
    $$AiProvidersTableUpdateCompanionBuilder,
    (AiProvider, BaseReferences<_$AppDatabase, $AiProvidersTable, AiProvider>),
    AiProvider,
    PrefetchHooks Function()>;
typedef $$ChangeLogsTableCreateCompanionBuilder = ChangeLogsCompanion Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  required String action,
  Value<String?> changedFields,
  required DateTime timestamp,
  Value<bool> synced,
});
typedef $$ChangeLogsTableUpdateCompanionBuilder = ChangeLogsCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String?> changedFields,
  Value<DateTime> timestamp,
  Value<bool> synced,
});

class $$ChangeLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ChangeLogsTable> {
  $$ChangeLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changedFields => $composableBuilder(
      column: $table.changedFields, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$ChangeLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChangeLogsTable> {
  $$ChangeLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changedFields => $composableBuilder(
      column: $table.changedFields,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$ChangeLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChangeLogsTable> {
  $$ChangeLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get changedFields => $composableBuilder(
      column: $table.changedFields, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ChangeLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChangeLogsTable,
    ChangeLog,
    $$ChangeLogsTableFilterComposer,
    $$ChangeLogsTableOrderingComposer,
    $$ChangeLogsTableAnnotationComposer,
    $$ChangeLogsTableCreateCompanionBuilder,
    $$ChangeLogsTableUpdateCompanionBuilder,
    (ChangeLog, BaseReferences<_$AppDatabase, $ChangeLogsTable, ChangeLog>),
    ChangeLog,
    PrefetchHooks Function()> {
  $$ChangeLogsTableTableManager(_$AppDatabase db, $ChangeLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChangeLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChangeLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChangeLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String?> changedFields = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              ChangeLogsCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            changedFields: changedFields,
            timestamp: timestamp,
            synced: synced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String entityId,
            required String action,
            Value<String?> changedFields = const Value.absent(),
            required DateTime timestamp,
            Value<bool> synced = const Value.absent(),
          }) =>
              ChangeLogsCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            changedFields: changedFields,
            timestamp: timestamp,
            synced: synced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChangeLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChangeLogsTable,
    ChangeLog,
    $$ChangeLogsTableFilterComposer,
    $$ChangeLogsTableOrderingComposer,
    $$ChangeLogsTableAnnotationComposer,
    $$ChangeLogsTableCreateCompanionBuilder,
    $$ChangeLogsTableUpdateCompanionBuilder,
    (ChangeLog, BaseReferences<_$AppDatabase, $ChangeLogsTable, ChangeLog>),
    ChangeLog,
    PrefetchHooks Function()>;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String id,
  Value<DateTime?> lastSyncTime,
  Value<int?> lastSyncChangeId,
  required String deviceId,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> id,
  Value<DateTime?> lastSyncTime,
  Value<int?> lastSyncChangeId,
  Value<String> deviceId,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncTime => $composableBuilder(
      column: $table.lastSyncTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastSyncChangeId => $composableBuilder(
      column: $table.lastSyncChangeId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncTime => $composableBuilder(
      column: $table.lastSyncTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastSyncChangeId => $composableBuilder(
      column: $table.lastSyncChangeId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncTime => $composableBuilder(
      column: $table.lastSyncTime, builder: (column) => column);

  GeneratedColumn<int> get lastSyncChangeId => $composableBuilder(
      column: $table.lastSyncChangeId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$SyncStateTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()> {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> lastSyncTime = const Value.absent(),
            Value<int?> lastSyncChangeId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateCompanion(
            id: id,
            lastSyncTime: lastSyncTime,
            lastSyncChangeId: lastSyncChangeId,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> lastSyncTime = const Value.absent(),
            Value<int?> lastSyncChangeId = const Value.absent(),
            required String deviceId,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateCompanion.insert(
            id: id,
            lastSyncTime: lastSyncTime,
            lastSyncChangeId: lastSyncChangeId,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStateTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()>;
typedef $$ChecklistItemsTableCreateCompanionBuilder = ChecklistItemsCompanion
    Function({
  required String id,
  required String tripId,
  Value<String?> travelId,
  required String title,
  Value<String?> note,
  Value<bool> isDone,
  Value<int> orderIndex,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ChecklistItemsTableUpdateCompanionBuilder = ChecklistItemsCompanion
    Function({
  Value<String> id,
  Value<String> tripId,
  Value<String?> travelId,
  Value<String> title,
  Value<String?> note,
  Value<bool> isDone,
  Value<int> orderIndex,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ChecklistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get travelId => $composableBuilder(
      column: $table.travelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ChecklistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get travelId => $composableBuilder(
      column: $table.travelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ChecklistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get travelId =>
      $composableBuilder(column: $table.travelId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChecklistItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChecklistItemsTable,
    ChecklistItem,
    $$ChecklistItemsTableFilterComposer,
    $$ChecklistItemsTableOrderingComposer,
    $$ChecklistItemsTableAnnotationComposer,
    $$ChecklistItemsTableCreateCompanionBuilder,
    $$ChecklistItemsTableUpdateCompanionBuilder,
    (
      ChecklistItem,
      BaseReferences<_$AppDatabase, $ChecklistItemsTable, ChecklistItem>
    ),
    ChecklistItem,
    PrefetchHooks Function()> {
  $$ChecklistItemsTableTableManager(
      _$AppDatabase db, $ChecklistItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChecklistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChecklistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChecklistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String?> travelId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChecklistItemsCompanion(
            id: id,
            tripId: tripId,
            travelId: travelId,
            title: title,
            note: note,
            isDone: isDone,
            orderIndex: orderIndex,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            Value<String?> travelId = const Value.absent(),
            required String title,
            Value<String?> note = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChecklistItemsCompanion.insert(
            id: id,
            tripId: tripId,
            travelId: travelId,
            title: title,
            note: note,
            isDone: isDone,
            orderIndex: orderIndex,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChecklistItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChecklistItemsTable,
    ChecklistItem,
    $$ChecklistItemsTableFilterComposer,
    $$ChecklistItemsTableOrderingComposer,
    $$ChecklistItemsTableAnnotationComposer,
    $$ChecklistItemsTableCreateCompanionBuilder,
    $$ChecklistItemsTableUpdateCompanionBuilder,
    (
      ChecklistItem,
      BaseReferences<_$AppDatabase, $ChecklistItemsTable, ChecklistItem>
    ),
    ChecklistItem,
    PrefetchHooks Function()>;
typedef $$GoalPostponementsTableCreateCompanionBuilder
    = GoalPostponementsCompanion Function({
  required String id,
  required String goalId,
  Value<DateTime?> oldDueDate,
  Value<DateTime?> newDueDate,
  Value<String?> reason,
  Value<int?> daysAdded,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$GoalPostponementsTableUpdateCompanionBuilder
    = GoalPostponementsCompanion Function({
  Value<String> id,
  Value<String> goalId,
  Value<DateTime?> oldDueDate,
  Value<DateTime?> newDueDate,
  Value<String?> reason,
  Value<int?> daysAdded,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$GoalPostponementsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalPostponementsTable> {
  $$GoalPostponementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goalId => $composableBuilder(
      column: $table.goalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get oldDueDate => $composableBuilder(
      column: $table.oldDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get newDueDate => $composableBuilder(
      column: $table.newDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get daysAdded => $composableBuilder(
      column: $table.daysAdded, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$GoalPostponementsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalPostponementsTable> {
  $$GoalPostponementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goalId => $composableBuilder(
      column: $table.goalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get oldDueDate => $composableBuilder(
      column: $table.oldDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get newDueDate => $composableBuilder(
      column: $table.newDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get daysAdded => $composableBuilder(
      column: $table.daysAdded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GoalPostponementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalPostponementsTable> {
  $$GoalPostponementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<DateTime> get oldDueDate => $composableBuilder(
      column: $table.oldDueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get newDueDate => $composableBuilder(
      column: $table.newDueDate, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get daysAdded =>
      $composableBuilder(column: $table.daysAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GoalPostponementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalPostponementsTable,
    GoalPostponement,
    $$GoalPostponementsTableFilterComposer,
    $$GoalPostponementsTableOrderingComposer,
    $$GoalPostponementsTableAnnotationComposer,
    $$GoalPostponementsTableCreateCompanionBuilder,
    $$GoalPostponementsTableUpdateCompanionBuilder,
    (
      GoalPostponement,
      BaseReferences<_$AppDatabase, $GoalPostponementsTable, GoalPostponement>
    ),
    GoalPostponement,
    PrefetchHooks Function()> {
  $$GoalPostponementsTableTableManager(
      _$AppDatabase db, $GoalPostponementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalPostponementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalPostponementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalPostponementsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> goalId = const Value.absent(),
            Value<DateTime?> oldDueDate = const Value.absent(),
            Value<DateTime?> newDueDate = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<int?> daysAdded = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalPostponementsCompanion(
            id: id,
            goalId: goalId,
            oldDueDate: oldDueDate,
            newDueDate: newDueDate,
            reason: reason,
            daysAdded: daysAdded,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String goalId,
            Value<DateTime?> oldDueDate = const Value.absent(),
            Value<DateTime?> newDueDate = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<int?> daysAdded = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalPostponementsCompanion.insert(
            id: id,
            goalId: goalId,
            oldDueDate: oldDueDate,
            newDueDate: newDueDate,
            reason: reason,
            daysAdded: daysAdded,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalPostponementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalPostponementsTable,
    GoalPostponement,
    $$GoalPostponementsTableFilterComposer,
    $$GoalPostponementsTableOrderingComposer,
    $$GoalPostponementsTableAnnotationComposer,
    $$GoalPostponementsTableCreateCompanionBuilder,
    $$GoalPostponementsTableUpdateCompanionBuilder,
    (
      GoalPostponement,
      BaseReferences<_$AppDatabase, $GoalPostponementsTable, GoalPostponement>
    ),
    GoalPostponement,
    PrefetchHooks Function()>;
typedef $$GoalReviewsTableCreateCompanionBuilder = GoalReviewsCompanion
    Function({
  required String id,
  required String goalId,
  required String title,
  Value<String?> content,
  required DateTime reviewDate,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$GoalReviewsTableUpdateCompanionBuilder = GoalReviewsCompanion
    Function({
  Value<String> id,
  Value<String> goalId,
  Value<String> title,
  Value<String?> content,
  Value<DateTime> reviewDate,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$GoalReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalReviewsTable> {
  $$GoalReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goalId => $composableBuilder(
      column: $table.goalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reviewDate => $composableBuilder(
      column: $table.reviewDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$GoalReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalReviewsTable> {
  $$GoalReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goalId => $composableBuilder(
      column: $table.goalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reviewDate => $composableBuilder(
      column: $table.reviewDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GoalReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalReviewsTable> {
  $$GoalReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewDate => $composableBuilder(
      column: $table.reviewDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GoalReviewsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalReviewsTable,
    GoalReview,
    $$GoalReviewsTableFilterComposer,
    $$GoalReviewsTableOrderingComposer,
    $$GoalReviewsTableAnnotationComposer,
    $$GoalReviewsTableCreateCompanionBuilder,
    $$GoalReviewsTableUpdateCompanionBuilder,
    (GoalReview, BaseReferences<_$AppDatabase, $GoalReviewsTable, GoalReview>),
    GoalReview,
    PrefetchHooks Function()> {
  $$GoalReviewsTableTableManager(_$AppDatabase db, $GoalReviewsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> goalId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<DateTime> reviewDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalReviewsCompanion(
            id: id,
            goalId: goalId,
            title: title,
            content: content,
            reviewDate: reviewDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String goalId,
            required String title,
            Value<String?> content = const Value.absent(),
            required DateTime reviewDate,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalReviewsCompanion.insert(
            id: id,
            goalId: goalId,
            title: title,
            content: content,
            reviewDate: reviewDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalReviewsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalReviewsTable,
    GoalReview,
    $$GoalReviewsTableFilterComposer,
    $$GoalReviewsTableOrderingComposer,
    $$GoalReviewsTableAnnotationComposer,
    $$GoalReviewsTableCreateCompanionBuilder,
    $$GoalReviewsTableUpdateCompanionBuilder,
    (GoalReview, BaseReferences<_$AppDatabase, $GoalReviewsTable, GoalReview>),
    GoalReview,
    PrefetchHooks Function()>;
typedef $$BackupLogsTableCreateCompanionBuilder = BackupLogsCompanion Function({
  required String id,
  required String backupType,
  required String storageType,
  required String fileName,
  Value<String?> filePath,
  Value<int?> fileSize,
  required String status,
  Value<String?> errorMessage,
  Value<int?> recordCount,
  Value<int?> mediaCount,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$BackupLogsTableUpdateCompanionBuilder = BackupLogsCompanion Function({
  Value<String> id,
  Value<String> backupType,
  Value<String> storageType,
  Value<String> fileName,
  Value<String?> filePath,
  Value<int?> fileSize,
  Value<String> status,
  Value<String?> errorMessage,
  Value<int?> recordCount,
  Value<int?> mediaCount,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$BackupLogsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backupType => $composableBuilder(
      column: $table.backupType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageType => $composableBuilder(
      column: $table.storageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mediaCount => $composableBuilder(
      column: $table.mediaCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BackupLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backupType => $composableBuilder(
      column: $table.backupType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageType => $composableBuilder(
      column: $table.storageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mediaCount => $composableBuilder(
      column: $table.mediaCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BackupLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get backupType => $composableBuilder(
      column: $table.backupType, builder: (column) => column);

  GeneratedColumn<String> get storageType => $composableBuilder(
      column: $table.storageType, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => column);

  GeneratedColumn<int> get mediaCount => $composableBuilder(
      column: $table.mediaCount, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BackupLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BackupLogsTable,
    BackupLog,
    $$BackupLogsTableFilterComposer,
    $$BackupLogsTableOrderingComposer,
    $$BackupLogsTableAnnotationComposer,
    $$BackupLogsTableCreateCompanionBuilder,
    $$BackupLogsTableUpdateCompanionBuilder,
    (BackupLog, BaseReferences<_$AppDatabase, $BackupLogsTable, BackupLog>),
    BackupLog,
    PrefetchHooks Function()> {
  $$BackupLogsTableTableManager(_$AppDatabase db, $BackupLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> backupType = const Value.absent(),
            Value<String> storageType = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<int?> recordCount = const Value.absent(),
            Value<int?> mediaCount = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BackupLogsCompanion(
            id: id,
            backupType: backupType,
            storageType: storageType,
            fileName: fileName,
            filePath: filePath,
            fileSize: fileSize,
            status: status,
            errorMessage: errorMessage,
            recordCount: recordCount,
            mediaCount: mediaCount,
            startedAt: startedAt,
            completedAt: completedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String backupType,
            required String storageType,
            required String fileName,
            Value<String?> filePath = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            required String status,
            Value<String?> errorMessage = const Value.absent(),
            Value<int?> recordCount = const Value.absent(),
            Value<int?> mediaCount = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BackupLogsCompanion.insert(
            id: id,
            backupType: backupType,
            storageType: storageType,
            fileName: fileName,
            filePath: filePath,
            fileSize: fileSize,
            status: status,
            errorMessage: errorMessage,
            recordCount: recordCount,
            mediaCount: mediaCount,
            startedAt: startedAt,
            completedAt: completedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BackupLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BackupLogsTable,
    BackupLog,
    $$BackupLogsTableFilterComposer,
    $$BackupLogsTableOrderingComposer,
    $$BackupLogsTableAnnotationComposer,
    $$BackupLogsTableCreateCompanionBuilder,
    $$BackupLogsTableUpdateCompanionBuilder,
    (BackupLog, BaseReferences<_$AppDatabase, $BackupLogsTable, BackupLog>),
    BackupLog,
    PrefetchHooks Function()>;
typedef $$AnnualReviewsTableCreateCompanionBuilder = AnnualReviewsCompanion
    Function({
  required String id,
  required int year,
  Value<String?> content,
  Value<String?> images,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AnnualReviewsTableUpdateCompanionBuilder = AnnualReviewsCompanion
    Function({
  Value<String> id,
  Value<int> year,
  Value<String?> content,
  Value<String?> images,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AnnualReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $AnnualReviewsTable> {
  $$AnnualReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get images => $composableBuilder(
      column: $table.images, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AnnualReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnnualReviewsTable> {
  $$AnnualReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get images => $composableBuilder(
      column: $table.images, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AnnualReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnnualReviewsTable> {
  $$AnnualReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AnnualReviewsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnnualReviewsTable,
    AnnualReview,
    $$AnnualReviewsTableFilterComposer,
    $$AnnualReviewsTableOrderingComposer,
    $$AnnualReviewsTableAnnotationComposer,
    $$AnnualReviewsTableCreateCompanionBuilder,
    $$AnnualReviewsTableUpdateCompanionBuilder,
    (
      AnnualReview,
      BaseReferences<_$AppDatabase, $AnnualReviewsTable, AnnualReview>
    ),
    AnnualReview,
    PrefetchHooks Function()> {
  $$AnnualReviewsTableTableManager(_$AppDatabase db, $AnnualReviewsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnnualReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnnualReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnnualReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> year = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> images = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnnualReviewsCompanion(
            id: id,
            year: year,
            content: content,
            images: images,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int year,
            Value<String?> content = const Value.absent(),
            Value<String?> images = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AnnualReviewsCompanion.insert(
            id: id,
            year: year,
            content: content,
            images: images,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnnualReviewsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnnualReviewsTable,
    AnnualReview,
    $$AnnualReviewsTableFilterComposer,
    $$AnnualReviewsTableOrderingComposer,
    $$AnnualReviewsTableAnnotationComposer,
    $$AnnualReviewsTableCreateCompanionBuilder,
    $$AnnualReviewsTableUpdateCompanionBuilder,
    (
      AnnualReview,
      BaseReferences<_$AppDatabase, $AnnualReviewsTable, AnnualReview>
    ),
    AnnualReview,
    PrefetchHooks Function()>;
typedef $$RecordEmbeddingsTableCreateCompanionBuilder
    = RecordEmbeddingsCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required Uint8List embedding,
  required int dimension,
  required String modelName,
  Value<String?> sourceText,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RecordEmbeddingsTableUpdateCompanionBuilder
    = RecordEmbeddingsCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<Uint8List> embedding,
  Value<int> dimension,
  Value<String> modelName,
  Value<String?> sourceText,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RecordEmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $RecordEmbeddingsTable> {
  $$RecordEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get embedding => $composableBuilder(
      column: $table.embedding, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dimension => $composableBuilder(
      column: $table.dimension, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$RecordEmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecordEmbeddingsTable> {
  $$RecordEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get embedding => $composableBuilder(
      column: $table.embedding, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dimension => $composableBuilder(
      column: $table.dimension, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RecordEmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecordEmbeddingsTable> {
  $$RecordEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<Uint8List> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<int> get dimension =>
      $composableBuilder(column: $table.dimension, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RecordEmbeddingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecordEmbeddingsTable,
    RecordEmbedding,
    $$RecordEmbeddingsTableFilterComposer,
    $$RecordEmbeddingsTableOrderingComposer,
    $$RecordEmbeddingsTableAnnotationComposer,
    $$RecordEmbeddingsTableCreateCompanionBuilder,
    $$RecordEmbeddingsTableUpdateCompanionBuilder,
    (
      RecordEmbedding,
      BaseReferences<_$AppDatabase, $RecordEmbeddingsTable, RecordEmbedding>
    ),
    RecordEmbedding,
    PrefetchHooks Function()> {
  $$RecordEmbeddingsTableTableManager(
      _$AppDatabase db, $RecordEmbeddingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecordEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecordEmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecordEmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<Uint8List> embedding = const Value.absent(),
            Value<int> dimension = const Value.absent(),
            Value<String> modelName = const Value.absent(),
            Value<String?> sourceText = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecordEmbeddingsCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            embedding: embedding,
            dimension: dimension,
            modelName: modelName,
            sourceText: sourceText,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required Uint8List embedding,
            required int dimension,
            required String modelName,
            Value<String?> sourceText = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RecordEmbeddingsCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            embedding: embedding,
            dimension: dimension,
            modelName: modelName,
            sourceText: sourceText,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecordEmbeddingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecordEmbeddingsTable,
    RecordEmbedding,
    $$RecordEmbeddingsTableFilterComposer,
    $$RecordEmbeddingsTableOrderingComposer,
    $$RecordEmbeddingsTableAnnotationComposer,
    $$RecordEmbeddingsTableCreateCompanionBuilder,
    $$RecordEmbeddingsTableUpdateCompanionBuilder,
    (
      RecordEmbedding,
      BaseReferences<_$AppDatabase, $RecordEmbeddingsTable, RecordEmbedding>
    ),
    RecordEmbedding,
    PrefetchHooks Function()>;
typedef $$ChatSessionsTableCreateCompanionBuilder = ChatSessionsCompanion
    Function({
  required String id,
  Value<String> title,
  Value<String?> summary,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> lastMessageAt,
  Value<bool> isArchived,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$ChatSessionsTableUpdateCompanionBuilder = ChatSessionsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String?> summary,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastMessageAt,
  Value<bool> isArchived,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$ChatSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableFilterComposer({
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

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
}

class $$ChatSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$ChatSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableAnnotationComposer({
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

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$ChatSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatSessionsTable,
    ChatSession,
    $$ChatSessionsTableFilterComposer,
    $$ChatSessionsTableOrderingComposer,
    $$ChatSessionsTableAnnotationComposer,
    $$ChatSessionsTableCreateCompanionBuilder,
    $$ChatSessionsTableUpdateCompanionBuilder,
    (
      ChatSession,
      BaseReferences<_$AppDatabase, $ChatSessionsTable, ChatSession>
    ),
    ChatSession,
    PrefetchHooks Function()> {
  $$ChatSessionsTableTableManager(_$AppDatabase db, $ChatSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastMessageAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatSessionsCompanion(
            id: id,
            title: title,
            summary: summary,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastMessageAt: lastMessageAt,
            isArchived: isArchived,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> title = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> lastMessageAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatSessionsCompanion.insert(
            id: id,
            title: title,
            summary: summary,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastMessageAt: lastMessageAt,
            isArchived: isArchived,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatSessionsTable,
    ChatSession,
    $$ChatSessionsTableFilterComposer,
    $$ChatSessionsTableOrderingComposer,
    $$ChatSessionsTableAnnotationComposer,
    $$ChatSessionsTableCreateCompanionBuilder,
    $$ChatSessionsTableUpdateCompanionBuilder,
    (
      ChatSession,
      BaseReferences<_$AppDatabase, $ChatSessionsTable, ChatSession>
    ),
    ChatSession,
    PrefetchHooks Function()>;
typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  required String id,
  required String sessionId,
  required String role,
  required String content,
  Value<String?> recommendations,
  required DateTime timestamp,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> role,
  Value<String> content,
  Value<String?> recommendations,
  Value<DateTime> timestamp,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recommendations => $composableBuilder(
      column: $table.recommendations,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recommendations => $composableBuilder(
      column: $table.recommendations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get recommendations => $composableBuilder(
      column: $table.recommendations, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessage,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessage,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>
    ),
    ChatMessage,
    PrefetchHooks Function()> {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> recommendations = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            sessionId: sessionId,
            role: role,
            content: content,
            recommendations: recommendations,
            timestamp: timestamp,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String role,
            required String content,
            Value<String?> recommendations = const Value.absent(),
            required DateTime timestamp,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            sessionId: sessionId,
            role: role,
            content: content,
            recommendations: recommendations,
            timestamp: timestamp,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessage,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessage,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>
    ),
    ChatMessage,
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
  $$TravelRecordsTableTableManager get travelRecords =>
      $$TravelRecordsTableTableManager(_db, _db.travelRecords);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$GoalRecordsTableTableManager get goalRecords =>
      $$GoalRecordsTableTableManager(_db, _db.goalRecords);
  $$TimelineEventsTableTableManager get timelineEvents =>
      $$TimelineEventsTableTableManager(_db, _db.timelineEvents);
  $$EntityLinksTableTableManager get entityLinks =>
      $$EntityLinksTableTableManager(_db, _db.entityLinks);
  $$LinkLogsTableTableManager get linkLogs =>
      $$LinkLogsTableTableManager(_db, _db.linkLogs);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$AiProvidersTableTableManager get aiProviders =>
      $$AiProvidersTableTableManager(_db, _db.aiProviders);
  $$ChangeLogsTableTableManager get changeLogs =>
      $$ChangeLogsTableTableManager(_db, _db.changeLogs);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$ChecklistItemsTableTableManager get checklistItems =>
      $$ChecklistItemsTableTableManager(_db, _db.checklistItems);
  $$GoalPostponementsTableTableManager get goalPostponements =>
      $$GoalPostponementsTableTableManager(_db, _db.goalPostponements);
  $$GoalReviewsTableTableManager get goalReviews =>
      $$GoalReviewsTableTableManager(_db, _db.goalReviews);
  $$BackupLogsTableTableManager get backupLogs =>
      $$BackupLogsTableTableManager(_db, _db.backupLogs);
  $$AnnualReviewsTableTableManager get annualReviews =>
      $$AnnualReviewsTableTableManager(_db, _db.annualReviews);
  $$RecordEmbeddingsTableTableManager get recordEmbeddings =>
      $$RecordEmbeddingsTableTableManager(_db, _db.recordEmbeddings);
  $$ChatSessionsTableTableManager get chatSessions =>
      $$ChatSessionsTableTableManager(_db, _db.chatSessions);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
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

mixin _$AiProviderDaoMixin on DatabaseAccessor<AppDatabase> {
  $AiProvidersTable get aiProviders => attachedDatabase.aiProviders;
  AiProviderDaoManager get managers => AiProviderDaoManager(this);
}

class AiProviderDaoManager {
  final _$AiProviderDaoMixin _db;
  AiProviderDaoManager(this._db);
  $$AiProvidersTableTableManager get aiProviders =>
      $$AiProvidersTableTableManager(_db.attachedDatabase, _db.aiProviders);
}

mixin _$ChangeLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChangeLogsTable get changeLogs => attachedDatabase.changeLogs;
  ChangeLogDaoManager get managers => ChangeLogDaoManager(this);
}

class ChangeLogDaoManager {
  final _$ChangeLogDaoMixin _db;
  ChangeLogDaoManager(this._db);
  $$ChangeLogsTableTableManager get changeLogs =>
      $$ChangeLogsTableTableManager(_db.attachedDatabase, _db.changeLogs);
}

mixin _$SyncStateDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncStateTable get syncState => attachedDatabase.syncState;
  SyncStateDaoManager get managers => SyncStateDaoManager(this);
}

class SyncStateDaoManager {
  final _$SyncStateDaoMixin _db;
  SyncStateDaoManager(this._db);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db.attachedDatabase, _db.syncState);
}

mixin _$ChecklistDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChecklistItemsTable get checklistItems => attachedDatabase.checklistItems;
  ChecklistDaoManager get managers => ChecklistDaoManager(this);
}

class ChecklistDaoManager {
  final _$ChecklistDaoMixin _db;
  ChecklistDaoManager(this._db);
  $$ChecklistItemsTableTableManager get checklistItems =>
      $$ChecklistItemsTableTableManager(
          _db.attachedDatabase, _db.checklistItems);
}

mixin _$GoalPostponementDaoMixin on DatabaseAccessor<AppDatabase> {
  $GoalPostponementsTable get goalPostponements =>
      attachedDatabase.goalPostponements;
  GoalPostponementDaoManager get managers => GoalPostponementDaoManager(this);
}

class GoalPostponementDaoManager {
  final _$GoalPostponementDaoMixin _db;
  GoalPostponementDaoManager(this._db);
  $$GoalPostponementsTableTableManager get goalPostponements =>
      $$GoalPostponementsTableTableManager(
          _db.attachedDatabase, _db.goalPostponements);
}

mixin _$GoalReviewDaoMixin on DatabaseAccessor<AppDatabase> {
  $GoalReviewsTable get goalReviews => attachedDatabase.goalReviews;
  GoalReviewDaoManager get managers => GoalReviewDaoManager(this);
}

class GoalReviewDaoManager {
  final _$GoalReviewDaoMixin _db;
  GoalReviewDaoManager(this._db);
  $$GoalReviewsTableTableManager get goalReviews =>
      $$GoalReviewsTableTableManager(_db.attachedDatabase, _db.goalReviews);
}

mixin _$BackupLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $BackupLogsTable get backupLogs => attachedDatabase.backupLogs;
  BackupLogDaoManager get managers => BackupLogDaoManager(this);
}

class BackupLogDaoManager {
  final _$BackupLogDaoMixin _db;
  BackupLogDaoManager(this._db);
  $$BackupLogsTableTableManager get backupLogs =>
      $$BackupLogsTableTableManager(_db.attachedDatabase, _db.backupLogs);
}

mixin _$AnnualReviewDaoMixin on DatabaseAccessor<AppDatabase> {
  $AnnualReviewsTable get annualReviews => attachedDatabase.annualReviews;
  AnnualReviewDaoManager get managers => AnnualReviewDaoManager(this);
}

class AnnualReviewDaoManager {
  final _$AnnualReviewDaoMixin _db;
  AnnualReviewDaoManager(this._db);
  $$AnnualReviewsTableTableManager get annualReviews =>
      $$AnnualReviewsTableTableManager(_db.attachedDatabase, _db.annualReviews);
}

mixin _$EmbeddingDaoMixin on DatabaseAccessor<AppDatabase> {
  $RecordEmbeddingsTable get recordEmbeddings =>
      attachedDatabase.recordEmbeddings;
  EmbeddingDaoManager get managers => EmbeddingDaoManager(this);
}

class EmbeddingDaoManager {
  final _$EmbeddingDaoMixin _db;
  EmbeddingDaoManager(this._db);
  $$RecordEmbeddingsTableTableManager get recordEmbeddings =>
      $$RecordEmbeddingsTableTableManager(
          _db.attachedDatabase, _db.recordEmbeddings);
}

mixin _$TravelDaoMixin on DatabaseAccessor<AppDatabase> {
  $TravelRecordsTable get travelRecords => attachedDatabase.travelRecords;
  $TripsTable get trips => attachedDatabase.trips;
  TravelDaoManager get managers => TravelDaoManager(this);
}

class TravelDaoManager {
  final _$TravelDaoMixin _db;
  TravelDaoManager(this._db);
  $$TravelRecordsTableTableManager get travelRecords =>
      $$TravelRecordsTableTableManager(_db.attachedDatabase, _db.travelRecords);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
}

mixin _$GoalDaoMixin on DatabaseAccessor<AppDatabase> {
  $GoalRecordsTable get goalRecords => attachedDatabase.goalRecords;
  GoalDaoManager get managers => GoalDaoManager(this);
}

class GoalDaoManager {
  final _$GoalDaoMixin _db;
  GoalDaoManager(this._db);
  $$GoalRecordsTableTableManager get goalRecords =>
      $$GoalRecordsTableTableManager(_db.attachedDatabase, _db.goalRecords);
}

mixin _$ChatDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChatSessionsTable get chatSessions => attachedDatabase.chatSessions;
  $ChatMessagesTable get chatMessages => attachedDatabase.chatMessages;
  ChatDaoManager get managers => ChatDaoManager(this);
}

class ChatDaoManager {
  final _$ChatDaoMixin _db;
  ChatDaoManager(this._db);
  $$ChatSessionsTableTableManager get chatSessions =>
      $$ChatSessionsTableTableManager(_db.attachedDatabase, _db.chatSessions);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db.attachedDatabase, _db.chatMessages);
}
