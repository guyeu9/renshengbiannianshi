extension SafeCast on Object? {
  T? safeCast<T>() {
    final value = this;
    if (value is T) return value;
    return null;
  }
}

extension SafeMapCast on Map<String, dynamic>? {
  T? safeGet<T>(String key) {
    final value = this?[key];
    if (value is T) return value;
    return null;
  }

  String? safeGetString(String key) => safeGet<String>(key);
  int? safeGetInt(String key) => safeGet<int>(key);
  double? safeGetDouble(String key) {
    final value = this?[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return null;
  }

  bool? safeGetBool(String key) => safeGet<bool>(key);
  List<T>? safeGetList<T>(String key) => this?[key] as List<T>?;
  Map<String, dynamic>? safeGetMap(String key) => this?[key] as Map<String, dynamic>?;
}

extension SafeListCast on List? {
  T? safeFirst<T>() {
    final list = this;
    if (list == null || list.isEmpty) return null;
    final first = list.first;
    if (first is T) return first;
    return null;
  }

  List<T>? safeCast<T>() {
    final list = this;
    if (list == null) return null;
    return list.cast<T>();
  }
}
