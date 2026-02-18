# 更新日志

## [Unreleased]

### Added
- **Encounter 模块**: 完成遭遇（Encounter）创建页面 `_EncounterCreatePage`，支持图片选择、持久化存储及好友/美食/地点关联。
- **图片持久化**: 新增 `persistImageFiles` 全局工具方法（`lib/core/utils/media_storage.dart`），统一管理跨模块图片存储，防止系统缓存清理导致数据丢失。
- **好友画像**: 在 `AppDatabase` 中新增 `watchEncountersForFriend` 方法，支持查询特定好友的共同回忆（Encounter 记录）。
- **测试**: 完善 `widget_test.dart`，添加 `FakeAppDatabase` 缺失的方法实现和 `path_provider` 的 mock，修复测试运行错误。

### Changed
- **Bond 模块**: `_FriendMemoryTimeline` 组件现在从数据库实时获取共同回忆数据，替代了之前的硬编码数据。
- **UI**: 优化了时间轴展示，支持根据图片数量自动判断卡片大小。

### Fixed
- 修复了 `widget_test.dart` 中因缺少 `watchEventsForMonth` 实现导致的 `NoSuchMethodError`。
- 修复了测试环境中 `getApplicationDocumentsDirectory` 未 mock 导致的问题。
