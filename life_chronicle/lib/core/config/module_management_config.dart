import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'module_tags.dart';
import '../database/database_providers.dart';

class ModuleTag {
  const ModuleTag({
    required this.id,
    required this.name,
    this.iconName,
    this.showOnCalendar = true,
    this.isCustom = false,
    this.usageCount = 0,
  });

  final String id;
  final String name;
  final String? iconName;
  final bool showOnCalendar;
  final bool isCustom;
  final int usageCount;

  ModuleTag copyWith({
    String? id,
    String? name,
    String? iconName,
    bool? showOnCalendar,
    bool? isCustom,
    int? usageCount,
  }) {
    return ModuleTag(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      showOnCalendar: showOnCalendar ?? this.showOnCalendar,
      isCustom: isCustom ?? this.isCustom,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'showOnCalendar': showOnCalendar,
      'isCustom': isCustom,
      'usageCount': usageCount,
    };
  }

  factory ModuleTag.fromJson(Map<String, dynamic> json) {
    return ModuleTag(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      iconName: (json['iconName'] ?? '').toString().isEmpty ? null : json['iconName'].toString(),
      showOnCalendar: json['showOnCalendar'] == null ? true : json['showOnCalendar'] == true,
      isCustom: json['isCustom'] == true,
      usageCount: json['usageCount'] is int ? json['usageCount'] : 0,
    );
  }
}

class ModuleConfig {
  const ModuleConfig({
    required this.key,
    required this.title,
    required this.iconName,
    required this.tagTitle,
    required this.showOnCalendar,
    required this.tags,
  });

  final String key;
  final String title;
  final String iconName;
  final String tagTitle;
  final bool showOnCalendar;
  final List<ModuleTag> tags;

  ModuleConfig copyWith({
    String? title,
    String? iconName,
    String? tagTitle,
    bool? showOnCalendar,
    List<ModuleTag>? tags,
  }) {
    return ModuleConfig(
      key: key,
      title: title ?? this.title,
      iconName: iconName ?? this.iconName,
      tagTitle: tagTitle ?? this.tagTitle,
      showOnCalendar: showOnCalendar ?? this.showOnCalendar,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'iconName': iconName,
      'tagTitle': tagTitle,
      'showOnCalendar': showOnCalendar,
      'tags': tags.map((t) => t.toJson()).toList(growable: false),
    };
  }

  factory ModuleConfig.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    final tags = <ModuleTag>[];
    if (tagsRaw is List) {
      for (final item in tagsRaw) {
        if (item is Map<String, dynamic>) {
          tags.add(ModuleTag.fromJson(item));
        } else if (item is Map) {
          tags.add(ModuleTag.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ModuleConfig(
      key: (json['key'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      iconName: (json['iconName'] ?? '').toString(),
      tagTitle: (json['tagTitle'] ?? '').toString(),
      showOnCalendar: json['showOnCalendar'] == null ? true : json['showOnCalendar'] == true,
      tags: tags,
    );
  }
}

class ModuleManagementConfig {
  const ModuleManagementConfig({required this.modules});

  final Map<String, ModuleConfig> modules;

  ModuleConfig moduleOf(String key) {
    return modules[key] ?? ModuleManagementConfig.defaults().modules[key]!;
  }

  Map<String, dynamic> toJson() {
    return {
      'modules': {
        for (final entry in modules.entries) entry.key: entry.value.toJson(),
      },
    };
  }

  factory ModuleManagementConfig.fromJson(Map<String, dynamic> json) {
    final modulesRaw = json['modules'];
    final modules = <String, ModuleConfig>{};
    if (modulesRaw is Map) {
      for (final entry in modulesRaw.entries) {
        if (entry.value is Map<String, dynamic>) {
          modules[entry.key.toString()] = ModuleConfig.fromJson(entry.value as Map<String, dynamic>);
        } else if (entry.value is Map) {
          modules[entry.key.toString()] = ModuleConfig.fromJson(Map<String, dynamic>.from(entry.value as Map));
        }
      }
    }
    final defaults = ModuleManagementConfig.defaults();
    for (final entry in defaults.modules.entries) {
      modules.putIfAbsent(entry.key, () => entry.value);
    }
    return ModuleManagementConfig(modules: modules);
  }

  static ModuleManagementConfig defaults() {
    return ModuleManagementConfig(
      modules: {
        'food': ModuleConfig(
          key: 'food',
          title: '美食',
          iconName: 'restaurant',
          tagTitle: '菜系标签管理',
          showOnCalendar: true,
          tags: ModuleTags.food.asMap().entries.map((e) => ModuleTag(id: 'food-${e.key + 1}', name: e.value, showOnCalendar: true)).toList(),
        ),
        'travel': ModuleConfig(
          key: 'travel',
          title: '旅行',
          iconName: 'airplanemode_active',
          tagTitle: '目的地标签管理',
          showOnCalendar: true,
          tags: ModuleTags.travel.asMap().entries.map((e) => ModuleTag(id: 'travel-${e.key + 1}', name: e.value, showOnCalendar: true)).toList(),
        ),
        'moment': ModuleConfig(
          key: 'moment',
          title: '小确幸',
          iconName: 'self_improvement',
          tagTitle: '场景标签管理',
          showOnCalendar: true,
          tags: ModuleTags.moment.asMap().entries.map((e) => ModuleTag(id: 'moment-${e.key + 1}', name: e.value, showOnCalendar: true)).toList(),
        ),
        'bond': ModuleConfig(
          key: 'bond',
          title: '人际关系',
          iconName: 'favorite',
          tagTitle: '印象标签管理',
          showOnCalendar: true,
          tags: ModuleTags.bond.asMap().entries.map((e) => ModuleTag(id: 'bond-${e.key + 1}', name: e.value, showOnCalendar: true)).toList(),
        ),
        'goal': ModuleConfig(
          key: 'goal',
          title: '目标',
          iconName: 'flag',
          tagTitle: '分类标签管理',
          showOnCalendar: true,
          tags: ModuleTags.goal.asMap().entries.map((e) => ModuleTag(id: 'goal-${e.key + 1}', name: e.value, showOnCalendar: true)).toList(),
        ),
      },
    );
  }
}

Future<File?> moduleManagementConfigFile() async {
  if (kIsWeb) return null;
  final dir = await getApplicationDocumentsDirectory();
  final profileDir = Directory(p.join(dir.path, 'profile'));
  await profileDir.create(recursive: true);
  return File(p.join(profileDir.path, 'module_management.json'));
}

Future<ModuleManagementConfig> loadModuleManagementConfig() async {
  if (kIsWeb) return ModuleManagementConfig.defaults();
  final file = await moduleManagementConfigFile();
  if (file == null) return ModuleManagementConfig.defaults();
  if (!await file.exists()) {
    final defaults = ModuleManagementConfig.defaults();
    await file.writeAsString(jsonEncode(defaults.toJson()));
    return defaults;
  }
  try {
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      final config = ModuleManagementConfig.fromJson(Map<String, dynamic>.from(decoded));
      final migrated = _migrateModuleConfig(config);
      if (migrated != null) {
        await file.writeAsString(jsonEncode(migrated.toJson()));
        return migrated;
      }
      return config;
    }
  } catch (_) {}
  final fallback = ModuleManagementConfig.defaults();
  await file.writeAsString(jsonEncode(fallback.toJson()));
  return fallback;
}

ModuleManagementConfig? _migrateModuleConfig(ModuleManagementConfig config) {
  bool needsMigration = false;
  final migratedModules = <String, ModuleConfig>{};

  for (final entry in config.modules.entries) {
    final module = entry.value;
    String? newIconName;

    if (module.key == 'travel' && module.iconName != 'airplanemode_active') {
      newIconName = 'airplanemode_active';
      needsMigration = true;
    }

    migratedModules[entry.key] = newIconName != null
        ? module.copyWith(iconName: newIconName)
        : module;
  }

  if (needsMigration) {
    return ModuleManagementConfig(modules: migratedModules);
  }
  return null;
}

Future<void> saveModuleManagementConfig(ModuleManagementConfig config) async {
  if (kIsWeb) return;
  final file = await moduleManagementConfigFile();
  if (file == null) return;
  await file.writeAsString(jsonEncode(config.toJson()));
}

final moduleManagementConfigProvider = FutureProvider<ModuleManagementConfig>((ref) async {
  ref.watch(moduleManagementRevisionProvider);
  return loadModuleManagementConfig();
});

List<String> getTagsForModule(ModuleManagementConfig config, String moduleKey) {
  return config.moduleOf(moduleKey).tags.map((t) => t.name).toList();
}
