
# 旅行界面修复与完善提案

## Context
通过对比原型图和当前 Flutter 实现，发现了多处需要完善和调整的地方，主要包括：
1. 新建旅行行程页面的心愿清单功能不完善（硬编码示例）
2. 旅行详情页时间线缺少关键功能（按天分组、时间戳、同行者等）
3. 搜索和筛选功能未实际应用
4. 部分 UI 与原型图有差异

## Scope
### 涉及文件
- `lib/core/database/tables.dart` - 新增 ChecklistItems 表
- `lib/core/database/app_database.dart` - 数据库迁移和 DAO
- `lib/core/database/migration_steps.dart` - 数据库迁移步骤
- `lib/features/travel/presentation/travel_page.dart` - 旅行相关界面
- `lib/core/database/daos/checklist_dao.dart`（新增）

### 新增文件
- `lib/core/database/daos/checklist_dao.dart` - 心愿清单 DAO

## Behavior

### 1. 数据库变更
**新增 ChecklistItems 表**：
| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | Text | 主键 |
| tripId | Text | 关联的 Trip ID |
| travelId | Text | 关联的 TravelRecord ID（可选） |
| title | Text | 心愿项标题 |
| note | Text | 备注（可选） |
| isDone | Boolean | 是否已完成 |
| orderIndex | Integer | 排序索引 |
| createdAt | DateTime | 创建时间 |
| updatedAt | DateTime | 更新时间 |

### 2. 新建旅行行程页面完善
- 心愿清单支持：添加新项、编辑、删除、勾选完成
- 心愿清单数据持久化到 ChecklistItems 表
- 编辑时正确恢复心愿清单状态
- 同行者显示头像（与原型图一致）

### 3. 旅行详情页完善
- 时间线按天分组显示（第一天、第二天...）
- 时间线显示同行者信息卡片
- 时间线卡片显示时间戳
- 显示关联的美食记录卡片

### 4. 搜索和筛选功能
- 搜索栏支持搜索目的地、标签
- 筛选面板实际应用筛选逻辑

## Risks
1. 数据库迁移需要处理旧数据（没有风险，新增表）
2. 需要确保数据的一致性

## 验证方法
- 新建旅行行程时添加心愿清单，保存后再编辑能正确恢复
- 详情页时间线按天分组，显示时间戳和同行者
- 搜索和筛选功能正常工作
