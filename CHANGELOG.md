# 更新日志

## [Unreleased]

### Added
- **Encounter 模块**: 完成遭遇（Encounter）创建页面 `_EncounterCreatePage`，支持图片选择、持久化存储及好友/美食/地点关联。
- **图片持久化**: 新增 `persistImageFiles` 全局工具方法（`lib/core/utils/media_storage.dart`），统一管理跨模块图片存储，防止系统缓存清理导致数据丢失。
- **好友画像**: 在 `AppDatabase` 中新增 `watchEncountersForFriend` 方法，支持查询特定好友的共同回忆（Encounter 记录）。
- **测试**: 完善 `widget_test.dart`，添加 `FakeAppDatabase` 缺失的方法实现和 `path_provider` 的 mock，修复测试运行错误。
- **模块管理**: 上线个人中心模块管理页，支持标签增删改、图标选择与首页日历展示开关。
- **标签库初始化**: 内置美食/旅行/小确幸/羁绊/目标默认标签，首次进入自动写入配置。

### Changed
- **Bond 模块**: `_FriendMemoryTimeline` 组件现在从数据库实时获取共同回忆数据，替代了之前的硬编码数据。
- **UI**: 优化了时间轴展示，支持根据图片数量自动判断卡片大小。
- **首页日历**: 按模块与小确幸标签配置展示日历小图标，支持实时刷新配置状态。

### Fixed
- 修复了 `widget_test.dart` 中因缺少 `watchEventsForMonth` 实现导致的 `NoSuchMethodError`。
- 修复了测试环境中 `getApplicationDocumentsDirectory` 未 mock 导致的问题。
- 修复了高德地图依赖 `com.amap.api:3dmap:10.1.200` 在 release 构建中无法解析的问题（补充高德 Maven 仓库）。
