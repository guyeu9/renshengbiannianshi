# 目标界面全面排查与修复方案

## Context（背景）

### 问题概述

对目标模块（`lib/features/goal/presentation/goal_page.dart`，6000+行）进行了系统性排查，覆盖按钮点击跳转/返回、按钮显示、字段来源、数据写入写出等维度。排查发现以下问题：

#### P0 严重问题（影响核心功能）

1. **年度复盘图片不持久化**：保存时 `AnnualReviewsCompanion` 缺少 `images` 字段；加载时 `_loadAnnualReview` 没有恢复 images。用户添加的图片保存后丢失。

2. **关联记忆卡片跳转后无法返回**：`_FoodMemoryCard`、`_MomentMemoryCard`、`_FriendMemoryCard` 使用 `context.go` 替换路由栈，导致从目标详情页点击后无法返回。`_TravelMemoryCard` 用 `context.push`（正确）。`_RelatedMemoryListItem` 列表项存在同样问题。

3. **GoalDetailPage 的 record 可能为 null**：路由配置 `GoalDetailPage(record: extra?['record'])` 在深链接或直接访问时 record 为 null，导致运行时错误。对比 `_GoalBreakdownWrapper` 和 `_GoalPostponeWrapper` 已正确处理 null。

#### P1 中等问题（影响体验）

1. **顺延计划页"历史"按钮无功能**：右上角图标按钮 `onTap: () {}` 为空回调。

### 影响范围

* **数据丢失**：年度复盘图片丢失

* **导航断裂**：关联记忆跳转后无法返回详情页

* **崩溃风险**：深链接访问目标详情页可能崩溃

* **体验缺失**：顺延历史按钮点击无反应

***

## Scope（涉及范围）

### 文件清单

| 文件路径                                            | 修改类型 | 说明                                    |
| ----------------------------------------------- | ---- | ------------------------------------- |
| `lib/features/goal/presentation/goal_page.dart` | 修改   | 修复4类问题                                |
| `lib/core/router/app_router.dart`               | 修改   | 新增 \_GoalDetailWrapper 处理 null record |

### 不涉及变更

* 数据库表结构不变（`AnnualReviews` 表已有 `images` 字段，只是代码未使用）

* 路由结构不变（仅添加 Wrapper）

* 不涉及其他模块

***

## Behavior（行为规范）

### 1. 年度复盘图片持久化修复

#### 当前行为（错误）

```
用户添加图片 → _reviewImages 列表更新
点击保存 → AnnualReviewsCompanion 未包含 images 字段 → 图片未持久化
重新打开 → _loadAnnualReview 未恢复 images → 图片丢失
```

#### 期望行为（正确）

```
用户添加图片 → _reviewImages 列表更新
点击保存 → images: Value(jsonEncode(_reviewImages)) → 图片持久化
重新打开 → _loadAnnualReview 解析 images JSON → 恢复图片
```

#### 修改点

**保存逻辑**（约1528-1536行）：

* 添加 `import 'dart:convert';`（如未存在）

* `AnnualReviewsCompanion` 增加 `images: Value(_reviewImages.isEmpty ? null : jsonEncode(_reviewImages))`

**加载逻辑**（`_loadAnnualReview`，约1085-1101行）：

* existing.images 非空时，`jsonDecode` 解析为 List<String>，addAll 到 `_reviewImages`

***

### 2. 关联记忆卡片跳转改为 push

#### 当前行为（错误）

```
目标详情页 → 点击美食卡片 → context.go('/food/123') → 路由栈替换为 [/food, /food/123]
点击返回 → maybePop → 回到 /food（美食列表），而非目标详情页
```

#### 期望行为（正确）

```
目标详情页 → 点击美食卡片 → context.push('/food/123') → 路由栈压入 /food/123
点击返回 → maybePop → 回到目标详情页
```

#### 修改点

| 组件                  | 行号     | 当前调用                                | 修改为                                   |
| ------------------- | ------ | ----------------------------------- | ------------------------------------- |
| `_FoodMemoryCard`   | \~4439 | `RouteNavigation.goToFoodDetail`    | `RouteNavigation.pushToFoodDetail`    |
| `_TravelMemoryCard` | \~4510 | `RouteNavigation.goToTravelDetail`  | 已用 push，保持不变                          |
| `_MomentMemoryCard` | \~4579 | `RouteNavigation.goToMomentDetail`  | `RouteNavigation.pushToMomentDetail`  |
| `_FriendMemoryCard` | \~4646 | `RouteNavigation.goToFriendProfile` | `RouteNavigation.pushToFriendProfile` |
| `_FoodListItem`     | 待查     | `goToFoodDetail`                    | `pushToFoodDetail`                    |
| `_TravelListItem`   | 待查     | `goToTravelDetail`                  | 改为 push 版本                            |
| `_MomentListItem`   | 待查     | `goToMomentDetail`                  | `pushToMomentDetail`                  |
| `_FriendListItem`   | 待查     | `goToFriendProfile`                 | `pushToFriendProfile`                 |

**补充**：需确认 `RouteNavigation` 是否已有 `pushToFriendProfile`（已存在，见 route\_navigation.dart:95）。

***

### 3. GoalDetailPage null 保护

#### 当前行为（错误）

```
路由配置：GoalDetailPage(record: extra?['record'])
深链接访问 /goal/123（无 extra）→ record 为 null → GoalDetailPage 构造函数报错
```

#### 期望行为（正确）

```
路由配置：_GoalDetailWrapper(goalId: id)
_Wrapper 用 StreamBuilder 加载 GoalRecord
加载中 → 显示 loading
加载成功 → 显示 GoalDetailPage(record: goal)
目标不存在 → 显示"目标不存在"
```

#### 修改点

**`lib/core/router/app_router.dart`**（约271-279行）：

* 将 `goalDetail` 路由的 builder 改为返回 `_GoalDetailWrapper(goalId: id)`

* 新增 `_GoalDetailWrapper` 类（参考 `_GoalBreakdownWrapper` 实现）

**`lib/features/goal/presentation/goal_page.dart`**：

* `GoalDetailPage` 保持不变（仍接收 record 参数）

* 由 Wrapper 负责加载数据后传入

***

### 4. 顺延计划页历史弹窗

#### 当前行为（错误）

```
右上角"历史"按钮 → onTap: () {} → 无反应
```

#### 期望行为（正确）

```
右上角"历史"按钮 → onTap → 弹出 BottomSheet 展示顺延历史记录列表
每条记录显示：旧截止日期 → 新截止日期（+N天）、原因、创建时间
无记录时显示空状态
```

#### 修改点

**`_GoalPostponePageState`**（约3421-3424行）：

* 实现 `_showPostponeHistory` 方法

* 用 `showModalBottomSheet` 展示 `GoalPostponement` 列表

* 数据源：`db.goalPostponementDao.watchByGoal(goalId)` 或一次性查询

* `onTap: _showPostponeHistory`

***

## Risks（风险评估）

### 风险矩阵

| 风险               | 概率 | 影响 | 缓解措施                              |
| ---------------- | -- | -- | --------------------------------- |
| push 跳转导致路由栈过深   | 低  | 低  | Flutter 路由栈默认无上限，用户操作自然 pop       |
| Wrapper 加载延迟体验差  | 低  | 低  | 显示 loading 指示器，StreamBuilder 自动刷新 |
| images JSON 解析失败 | 低  | 中  | try-catch 包裹 jsonDecode，失败时清空图片   |
| 顺延历史 DAO 方法缺失    | 中  | 低  | 先确认 DAO 方法，缺失则用直接查询               |

### 兼容性策略

1. **数据兼容**：`AnnualReviews` 表已有 images 字段，旧数据 images 为 null，不影响
2. **路由兼容**：`_GoalDetailWrapper` 仍接收 extra 中的 record（如有），优先使用，无则用 StreamBuilder 加载
3. **导航兼容**：push 跳转不影响原有 go 跳转的其他调用方

***

## Implementation Notes（实现说明）

### 修改顺序

1. 修复年度复盘图片持久化（独立，无依赖）
2. 修复关联记忆卡片跳转（独立，无依赖）
3. 新增 \_GoalDetailWrapper（涉及 app\_router.dart）
4. 实现顺延历史弹窗（需确认 DAO 方法）
5. 验证：flutter analyze
6. 更新文档

### 关键代码片段

#### 年度复盘保存（修复后）

```dart
final imagesJson = _reviewImages.isEmpty ? null : jsonEncode(_reviewImages);
await db.annualReviewDao.upsert(
  AnnualReviewsCompanion(
    id: Value(_existingReviewId ?? ref.read(uuidProvider).v4()),
    year: Value(_selectedYear),
    content: Value(_reviewController.text.trim().isEmpty ? null : _reviewController.text.trim()),
    images: Value(imagesJson),  // 新增
    createdAt: Value(_existingReviewId != null ? now : now),
    updatedAt: Value(now),
  ),
);
```

#### 年度复盘加载（修复后）

```dart
if (existing != null && mounted) {
  setState(() {
    _reviewController.text = existing.content ?? '';
    _reviewImages.clear();
    if (existing.images != null && existing.images!.isNotEmpty) {
      try {
        final List<dynamic> imageList = jsonDecode(existing.images!);
        _reviewImages.addAll(imageList.cast<String>());
      } catch (_) {}
    }
    _existingReviewId = existing.id;
  });
}
```

***

## Acceptance Criteria（验收标准）

### 功能验收

* [ ] 年度复盘添加图片→保存→重新打开，图片正确显示

* [ ] 年度复盘切换年份后，对应年份的图片正确加载

* [ ] 从目标详情页点击美食/小确幸/朋友卡片→可返回目标详情页

* [ ] 从全部关联页点击列表项→可返回全部关联页

* [ ] 深链接访问 /goal/{id}（无 record 参数）→ 正常显示详情页或"目标不存在"

* [ ] 顺延计划页点击右上角历史按钮→弹出历史记录列表

### 代码质量验收

* [ ] `flutter analyze` 无新增错误

* [ ] 无空回调按钮

* [ ] 关联记忆跳转方式统一为 push

***

## References（参考文档）

* [更新日志.md](file:///d:/trae/chronicle-of-life/更新日志.md)

* [开发设计文档.md](file:///d:/trae/chronicle-of-life/开发设计文档.md)

* [tables.dart - AnnualReviews 表](file:///d:/trae/chronicle-of-life/life_chronicle/lib/core/database/tables.dart)

* [goal\_page.dart](file:///d:/trae/chronicle-of-life/life_chronicle/lib/features/goal/presentation/goal_page.dart)

* [app\_router.dart](file:///d:/trae/chronicle-of-life/life_chronicle/lib/core/router/app_router.dart)

* [route\_navigation.dart](file:///d:/trae/chronicle-of-life/life_chronicle/lib/core/router/route_navigation.dart)

