# 目标界面修复任务清单

## 阶段1：年度复盘图片持久化

### Task 1.1：修复保存逻辑
- 文件：goal_page.dart ~1528行
- AnnualReviewsCompanion 增加 images 字段
- 验证：保存后数据库 images 字段有值

### Task 1.2：修复加载逻辑
- 文件：goal_page.dart _loadAnnualReview ~1085行
- 解析 existing.images 恢复 _reviewImages
- 验证：重新打开页面图片正确显示

---

## 阶段2：关联记忆卡片跳转改为 push

### Task 2.1：添加 pushToGoalAllLinks 方法
- 文件：route_navigation.dart
- 新增 pushToGoalAllLinks（context.push 版本）

### Task 2.2：修改卡片跳转（8处）
- _FoodMemoryCard(4439)、_MomentMemoryCard(4579)、_FriendMemoryCard(4646)
- _FoodListItem(4887)、_MomentListItem(4969)、_FriendListItem(5007)
- 全部关联按钮(2190) → pushToGoalAllLinks
- _TravelMemoryCard(4510)、_TravelListItem(4929) 保持不变
- 验证：跳转后可返回详情页

---

## 阶段3：GoalDetailPage null 保护

### Task 3.1：新增 _GoalDetailWrapper
- 文件：app_router.dart
- 参考 _GoalBreakdownWrapper 实现
- 修改 goalDetail 路由 builder
- 验证：深链接访问不崩溃

---

## 阶段4：顺延历史弹窗

### Task 4.1：实现 _showPostponeHistory
- 文件：goal_page.dart _GoalPostponePageState
- 用 showModalBottomSheet + watchByGoalId
- 修改右上角按钮 onTap
- 验证：点击弹出历史记录列表

---

## 阶段5：验证与文档

### Task 5.1：flutter analyze
### Task 5.2：更新更新日志和开发设计文档
