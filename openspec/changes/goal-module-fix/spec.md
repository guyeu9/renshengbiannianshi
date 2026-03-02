# 目标模块代码问题修复规范

## Context（背景）

### 问题概述

目标模块存在多处代码内部问题，导致数据存储不一致、用户数据丢失、界面显示混乱等问题。经排查发现以下核心问题：

1. **note字段语义混乱**：`GoalRecords.note` 字段同时用于存储"目标描述"和"复盘内容"，两者互相覆盖
2. **两套复盘存储机制不一致**：`GoalRecords.summary` 和 `GoalReviews` 表两套机制并存，但代码只写入前者
3. **年度复盘未持久化**：用户填写的年度复盘内容无法保存到数据库
4. **死代码存在**：`noteParts` 构建逻辑从未被使用
5. **界面紧凑度不足**：各区块间距过大，视觉体验不佳

### 影响范围

- **用户体验**：数据丢失、功能不可用
- **数据完整性**：字段语义混乱导致数据不一致
- **代码质量**：死代码、冗余逻辑

---

## Scope（涉及范围）

### 文件清单

| 文件路径 | 修改类型 | 说明 |
|---------|---------|------|
| `lib/core/database/tables.dart` | 新增表 | 新增 `AnnualReviews` 表 |
| `lib/core/database/app_database.dart` | 修改 | 数据库版本升级、新增 DAO |
| `lib/core/database/daos/goal_review_dao.dart` | 已存在 | 确认方法完整性 |
| `lib/core/database/daos/annual_review_dao.dart` | 新增 | 年度复盘 DAO |
| `lib/features/goal/presentation/goal_page.dart` | 大量修改 | 修复所有核心逻辑 |
| `lib/core/database/database.g.dart` | 自动生成 | Drift 代码生成 |

### 数据库变更

| 表名 | 变更类型 | 说明 |
|------|---------|------|
| `annual_reviews` | 新增 | 存储年度复盘数据 |

---

## Behavior（行为规范）

### 1. note 字段语义修复

#### 当前行为（错误）
```
用户填写目标描述 → 存入 note 字段
用户点击阶段复盘 → 复盘内容覆盖 note 字段
结果：目标描述丢失
```

#### 期望行为（正确）
```
用户填写目标描述 → 存入 note 字段
用户点击阶段复盘 → 复盘内容存入 GoalReviews 表
用户点击编辑总结 → 总结内容存入 summary 字段
结果：三者独立存储，互不覆盖
```

#### 字段语义定义

| 字段 | 所属表 | 语义 | 使用场景 |
|------|--------|------|---------|
| `note` | GoalRecords | 目标描述 | 新建/编辑目标时填写 |
| `summary` | GoalRecords | 目标总结 | 目标完成后填写最终总结 |
| `GoalReviews` 表 | - | 阶段复盘记录 | 目标进行中阶段性复盘 |

---

### 2. 阶段复盘存储机制修复

#### 当前行为（错误）
```
_showStageReview 方法：
  - 修改 GoalRecords.summary
  - 修改 GoalRecords.note
  - 不操作 GoalReviews 表
  
详情页展示：
  - 查询 GoalReviews 表
  - 结果永远为空
```

#### 期望行为（正确）
```
编辑总结功能：
  - 仅修改 GoalRecords.summary
  - 不修改 note 字段
  
新增复盘功能：
  - 向 GoalReviews 表插入新记录
  - 包含 title、content、reviewDate
  
详情页展示：
  - 查询 GoalReviews 表
  - 显示所有阶段复盘记录
```

#### 交互设计

详情页底部操作栏改为三个按钮：
1. **顺延计划**（已有）：跳转到顺延页面
2. **编辑总结**（新增）：弹窗编辑 `summary` 字段
3. **新增复盘**（修改）：弹窗向 `GoalReviews` 表添加记录

---

### 3. 年度复盘持久化实现

#### 当前行为（错误）
```
用户填写年度复盘内容
点击"保存记录"按钮
显示 SnackBar "已保存年度复盘"
实际：数据未保存，页面关闭后丢失
```

#### 期望行为（正确）
```
用户填写年度复盘内容
点击"保存记录"按钮
数据写入 annual_reviews 表
显示 SnackBar "已保存年度复盘"
页面重新打开时自动加载已保存内容
```

#### 数据库表设计

```dart
class AnnualReviews extends Table {
  TextColumn get id => text()();
  IntColumn get year => integer()();           // 年份
  TextColumn get content => text().nullable()(); // 复盘内容
  TextColumn get images => text().nullable()();  // 图片路径JSON数组
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

### 4. 死代码清理

#### 当前代码（第5127-5131行）
```dart
final noteParts = <String>[];
if (_selectedGoalType.isNotEmpty) noteParts.add('分类：${_goalLabelFor(_selectedGoalType)}');
if (_dueDate != null) noteParts.add('截止：${_formatDotDate(_dueDate!)}');
if (description.isNotEmpty) noteParts.add(description);
final note = noteParts.isEmpty ? null : noteParts.join('\n');
// note 变量从未被使用
```

#### 处理方案
直接删除第5127-5131行代码。

---

### 5. 界面紧凑度优化

#### 当前间距配置
| 位置 | 当前值 | 说明 |
|------|--------|------|
| 标题与截止日期 | 22px | SizedBox(height: 22) |
| 各卡片之间 | 18px | SizedBox(height: 18) |
| 标题与内容 | 10px | SizedBox(height: 10) |
| 卡片内边距 | 16px | padding: EdgeInsets.all(16) |

#### 优化后间距配置
| 位置 | 优化值 | 说明 |
|------|--------|------|
| 标题与截止日期 | 14px | 减少8px |
| 各卡片之间 | 12px | 减少6px |
| 标题与内容 | 8px | 减少2px |
| 卡片内边距 | 12px | 减少4px |

---

## Risks（风险评估）

### 风险矩阵

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| 数据库迁移失败 | 低 | 高 | 使用 Drift 幂等迁移机制，添加回滚逻辑 |
| 现有 note 数据语义变化 | 中 | 中 | 保留现有数据，新功能使用新字段/表 |
| 用户交互习惯变化 | 中 | 低 | 提供清晰的按钮标签和提示 |
| 界面样式变化用户不适应 | 低 | 低 | 渐进式调整，保留核心布局 |

### 兼容性策略

1. **数据迁移**：
   - 现有 `note` 字段数据保持不变
   - 新增 `annual_reviews` 表不影响现有数据

2. **API 兼容**：
   - `GoalReviewDao` 已有方法保持不变
   - 新增方法扩展功能

---

## Implementation Notes（实现说明）

### 数据库版本升级

当前版本：schemaVersion = 10
升级后版本：schemaVersion = 11

迁移逻辑：
```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from < 11) {
    await m.createTable(annualReviews);
  }
}
```

### 代码修改顺序

1. 修改 `tables.dart` 新增表
2. 运行 `flutter pub run build_runner build` 生成代码
3. 修改 `app_database.dart` 升级版本和迁移
4. 新增 `annual_review_dao.dart`
5. 修改 `goal_page.dart` 实现所有功能修复

---

## Acceptance Criteria（验收标准）

### 功能验收

- [ ] 目标描述和复盘内容不再互相覆盖
- [ ] 阶段复盘数据正确存储到 `GoalReviews` 表
- [ ] 年度复盘可以持久化保存并重新加载
- [ ] 详情页底部三个按钮功能正确
- [ ] 死代码已清理

### 界面验收

- [ ] 详情页布局更加紧凑
- [ ] 各区块间距符合优化后的配置
- [ ] 卡片内边距符合优化后的配置

### 代码质量验收

- [ ] `flutter analyze` 无错误
- [ ] 无死代码和冗余逻辑
- [ ] 代码注释清晰

---

## References（参考文档）

- [开发设计文档.md](file:///d:/trae/人生编年国际/开发设计文档.md)
- [更新日志.md](file:///d:/trae/人生编年国际/更新日志.md)
- [tables.dart](file:///d:/trae/人生编年国际/life_chronicle/lib/core/database/tables.dart)
- [goal_page.dart](file:///d:/trae/人生编年国际/life_chronicle/lib/features/goal/presentation/goal_page.dart)
