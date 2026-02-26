import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/database_providers.dart';

class ModuleTag {
  const ModuleTag({
    required this.id,
    required this.name,
    this.iconName,
    this.color,
    this.showOnCalendar = true,
    this.isCustom = false,
    this.usageCount = 0,
  });

  final String id;
  final String name;
  final String? iconName;
  final String? color;
  final bool showOnCalendar;
  final bool isCustom;
  final int usageCount;

  ModuleTag copyWith({
    String? id,
    String? name,
    String? iconName,
    String? color,
    bool? showOnCalendar,
    bool? isCustom,
    int? usageCount,
  }) {
    return ModuleTag(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
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
      'color': color,
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
      color: (json['color'] ?? '').toString().isEmpty ? null : json['color'].toString(),
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
          tags: const [
            ModuleTag(id: 'food-1', name: '必吃榜', showOnCalendar: true),
            ModuleTag(id: 'food-2', name: '周末探店', showOnCalendar: true),
            ModuleTag(id: 'food-3', name: '辣', showOnCalendar: true),
            ModuleTag(id: 'food-4', name: '火锅', showOnCalendar: true),
            ModuleTag(id: 'food-5', name: '烤肉', showOnCalendar: true),
            ModuleTag(id: 'food-6', name: '日料', showOnCalendar: true),
            ModuleTag(id: 'food-7', name: '甜品', showOnCalendar: true),
            ModuleTag(id: 'food-8', name: '咖啡', showOnCalendar: true),
          ],
        ),
        'travel': ModuleConfig(
          key: 'travel',
          title: '旅行',
          iconName: 'airplanemode_active',
          tagTitle: '目的地标签管理',
          showOnCalendar: true,
          tags: const [
            ModuleTag(id: 'travel-1', name: '国内游', showOnCalendar: true),
            ModuleTag(id: 'travel-2', name: '露营', showOnCalendar: true),
            ModuleTag(id: 'travel-3', name: '海岛', showOnCalendar: true),
            ModuleTag(id: 'travel-4', name: '城市漫游', showOnCalendar: true),
          ],
        ),
        'moment': ModuleConfig(
          key: 'moment',
          title: '小确幸',
          iconName: 'self_improvement',
          tagTitle: '场景标签管理',
          showOnCalendar: true,
          tags: const [
            ModuleTag(id: 'moment-1', name: '读书', showOnCalendar: true),
            ModuleTag(id: 'moment-2', name: '搬家', showOnCalendar: true),
            ModuleTag(id: 'moment-3', name: '桌面布置', showOnCalendar: true),
            ModuleTag(id: 'moment-4', name: '电影', showOnCalendar: true),
          ],
        ),
        'bond': ModuleConfig(
          key: 'bond',
          title: '人际关系',
          iconName: 'favorite',
          tagTitle: '印象标签管理',
          showOnCalendar: true,
          tags: const [
            ModuleTag(id: 'bond-1', name: '家人', showOnCalendar: true),
            ModuleTag(id: 'bond-2', name: '同学', showOnCalendar: true),
            ModuleTag(id: 'bond-3', name: '同事', showOnCalendar: true),
            ModuleTag(id: 'bond-4', name: '闺蜜', showOnCalendar: true),
            ModuleTag(id: 'bond-5', name: '饭搭子', showOnCalendar: true),
            ModuleTag(id: 'bond-6', name: '旅行搭子', showOnCalendar: true),
            ModuleTag(id: 'bond-7', name: '球友', showOnCalendar: true),
            ModuleTag(id: 'bond-8', name: '靠谱', showOnCalendar: true),
            ModuleTag(id: 'bond-9', name: '有趣', showOnCalendar: true),
            ModuleTag(id: 'bond-10', name: '温柔', showOnCalendar: true),
            ModuleTag(id: 'bond-11', name: '爱运动', showOnCalendar: true),
            ModuleTag(id: 'bond-12', name: '爱拍照', showOnCalendar: true),
          ],
        ),
        'goal': ModuleConfig(
          key: 'goal',
          title: '目标',
          iconName: 'flag',
          tagTitle: '分类标签管理',
          showOnCalendar: true,
          tags: const [
            ModuleTag(id: 'goal-1', name: '职业发展', showOnCalendar: true),
            ModuleTag(id: 'goal-2', name: '身心健康', showOnCalendar: true),
            ModuleTag(id: 'goal-3', name: '环球旅行', showOnCalendar: true),
          ],
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

Future<bool> syncTagToModuleConfig(String moduleKey, String tagName) async {
  if (tagName.trim().isEmpty) return false;

  final config = await loadModuleManagementConfig();
  final module = config.moduleOf(moduleKey);
  final existingTagNames = module.tags.map((t) => t.name).toSet();

  if (existingTagNames.contains(tagName)) return false;

  final updatedTags = [...module.tags];
  updatedTags.add(ModuleTag(
    id: '$moduleKey-${DateTime.now().millisecondsSinceEpoch}',
    name: tagName,
    isCustom: true,
  ));

  final updatedModule = module.copyWith(tags: updatedTags);
  final modules = Map<String, ModuleConfig>.from(config.modules);
  modules[moduleKey] = updatedModule;

  await saveModuleManagementConfig(ModuleManagementConfig(modules: modules));
  return true;
}

Future<void> syncTagsToModuleConfig(
  String moduleKey,
  Iterable<String> tags,
  WidgetRef ref,
) async {
  bool needsRefresh = false;
  for (final tag in tags) {
    if (await syncTagToModuleConfig(moduleKey, tag)) {
      needsRefresh = true;
    }
  }
  if (needsRefresh) {
    ref.read(moduleManagementRevisionProvider.notifier).state += 1;
  }
}
