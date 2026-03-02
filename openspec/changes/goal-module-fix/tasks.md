# 目标模块代码问题修复任务清单

## 任务概览

| 阶段 | 任务数 | 预估工作量 |
|------|--------|-----------|
| 阶段1：数据库层修改 | 4 | 中 |
| 阶段2：核心逻辑修复 | 5 | 高 |
| 阶段3：界面优化 | 2 | 低 |
| 阶段4：验证与文档 | 3 | 低 |

---

## 阶段1：数据库层修改

### Task 1.1：新增 AnnualReviews 表

**文件**：`lib/core/database/tables.dart`

**修改内容**：
```dart
class AnnualReviews extends Table {
  TextColumn get id => text()();
  IntColumn get year => integer()();
  TextColumn get content => text().nullable()();
  TextColumn get images => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

**验证方法**：
- 编译通过
- 表结构符合规范

---

### Task 1.2：运行 Drift 代码生成

**命令**：
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**验证方法**：
- `database.g.dart` 更新
- 无编译错误

---

### Task 1.3：新增 AnnualReviewDao

**文件**：`lib/core/database/daos/annual_review_dao.dart`

**内容**：
```dart
part of '../app_database.dart';

@DriftAccessor(tables: [AnnualReviews])
class AnnualReviewDao extends DatabaseAccessor<AppDatabase> with _$AnnualReviewDaoMixin {
  AnnualReviewDao(super.db);

  Future<void> upsert(AnnualReviewsCompanion entry) async {
    await into(db.annualReviews).insertOnConflictUpdate(entry);
  }

  Future<AnnualReview?> findByYear(int year) {
    return (select(db.annualReviews)..where((t) => t.year.equals(year)))
        .getSingleOrNull();
  }

  Stream<AnnualReview?> watchByYear(int year) {
    return (select(db.annualReviews)..where((t) => t.year.equals(year)))
        .watchSingleOrNull();
  }
}
```

**验证方法**：
- 编译通过
- DAO 方法完整

---

### Task 1.4：升级数据库版本和迁移

**文件**：`lib/core/database/app_database.dart`

**修改内容**：
1. schemaVersion: 10 → 11
2. 添加 AnnualReviewDao 到数据库类
3. 添加迁移逻辑：
```dart
if (from < 11) {
  await m.createTable(annualReviews);
}
```

**验证方法**：
- 数据库版本正确
- 迁移逻辑完整

---

## 阶段2：核心逻辑修复

### Task 2.1：修复 note 字段语义 - 移除死代码

**文件**：`lib/features/goal/presentation/goal_page.dart`

**修改位置**：第5127-5131行

**修改内容**：
删除以下代码：
```dart
final noteParts = <String>[];
if (_selectedGoalType.isNotEmpty) noteParts.add('分类：${_goalLabelFor(_selectedGoalType)}');
if (_dueDate != null) noteParts.add('截止：${_formatDotDate(_dueDate!)}');
if (description.isNotEmpty) noteParts.add(description);
final note = noteParts.isEmpty ? null : noteParts.join('\n');
```

**验证方法**：
- 编译通过
- 新建/编辑目标功能正常

---

### Task 2.2：重构阶段复盘功能 - 分离编辑总结和新增复盘

**文件**：`lib/features/goal/presentation/goal_page.dart`

**修改内容**：

#### 2.2.1 重命名并简化 `_showStageReview` 为 `_editSummary`

```dart
Future<void> _editSummary(GoalRecord record) async {
  final summaryController = TextEditingController(text: record.summary ?? '');
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('编辑总结'),
        content: TextField(
          controller: summaryController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: '目标总结',
            hintText: '写下这个目标的最终总结...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('保存')),
        ],
      );
    },
  );
  if (confirmed != true) return;

  final summary = summaryController.text.trim();
  final db = ref.read(appDatabaseProvider);
  final now = DateTime.now();
  await (db.update(db.goalRecords)..where((t) => t.id.equals(record.id))).write(
    GoalRecordsCompanion(
      summary: Value(summary.isEmpty ? null : summary),
      updatedAt: Value(now),
    ),
  );
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('总结已保存')));
}
```

#### 2.2.2 新增 `_addStageReview` 方法

```dart
Future<void> _addStageReview(GoalRecord record) async {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('新增阶段复盘'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '复盘标题',
                hintText: '例如：第一季度进展',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '复盘内容',
                hintText: '写下这个阶段的进展和反思...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('保存')),
        ],
      );
    },
  );
  if (confirmed != true) return;

  final title = titleController.text.trim();
  if (title.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入复盘标题')));
    return;
  }

  final db = ref.read(appDatabaseProvider);
  final now = DateTime.now();
  await db.goalReviewDao.insert(
    GoalReviewsCompanion.insert(
      id: const Uuid().v4(),
      goalId: record.id,
      title: title,
      content: Value(contentController.text.trim().isEmpty ? null : contentController.text.trim()),
      reviewDate: now,
      createdAt: now,
    ),
  );
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('阶段复盘已保存')));
}
```

**验证方法**：
- 编辑总结只修改 `summary` 字段
- 新增复盘向 `GoalReviews` 表插入记录
- 详情页正确显示阶段复盘列表

---

### Task 2.3：修改详情页底部操作栏

**文件**：`lib/features/goal/presentation/goal_page.dart`

**修改位置**：第2200-2238行

**修改内容**：

将原有的两个按钮改为三个按钮：

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
  child: SafeArea(
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => GoalPostponePage(goal: record),
            )),
            icon: const Icon(Icons.update, size: 18),
            label: const Text('顺延计划'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _editSummary(record),
            icon: const Icon(Icons.edit_note, size: 18),
            label: const Text('编辑总结'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _addStageReview(record),
            icon: const Icon(Icons.rate_review, size: 18),
            label: const Text('新增复盘'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ],
    ),
  ),
),
```

**验证方法**：
- 三个按钮正确显示
- 点击各按钮触发正确功能

---

### Task 2.4：实现年度复盘持久化

**文件**：`lib/features/goal/presentation/goal_page.dart`

**修改位置**：`_AnnualGoalSummaryPageState` 类

**修改内容**：

#### 2.4.1 添加状态变量

```dart
class _AnnualGoalSummaryPageState extends ConsumerState<AnnualGoalSummaryPage> {
  final GlobalKey _shareKey = GlobalKey();
  final TextEditingController _reviewController = TextEditingController();
  final List<String> _reviewImages = [];
  late int _selectedYear;
  bool _isLoadingReview = true;  // 新增
  String? _existingReviewId;     // 新增：已存在复盘的ID
```

#### 2.4.2 添加加载逻辑

```dart
@override
void initState() {
  super.initState();
  _selectedYear = widget.initialYear;
  _loadAnnualReview();
}

Future<void> _loadAnnualReview() async {
  final db = ref.read(appDatabaseProvider);
  final existing = await db.annualReviewDao.findByYear(_selectedYear);
  if (existing != null && mounted) {
    setState(() {
      _reviewController.text = existing.content ?? '';
      if (existing.images != null && existing.images!.isNotEmpty) {
        try {
          final List<dynamic> imageList = jsonDecode(existing.images!);
          _reviewImages.addAll(imageList.cast<String>());
        } catch (_) {}
      }
      _existingReviewId = existing.id;
    });
  }
  if (mounted) {
    setState(() => _isLoadingReview = false);
  }
}
```

#### 2.4.3 修改保存逻辑

```dart
ElevatedButton(
  onPressed: () async {
    FocusManager.instance.primaryFocus?.unfocus();
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    const uuid = Uuid();
    
    final imagesJson = _reviewImages.isEmpty ? null : jsonEncode(_reviewImages);
    
    await db.annualReviewDao.upsert(
      AnnualReviewsCompanion(
        id: Value(_existingReviewId ?? uuid.v4()),
        year: Value(_selectedYear),
        content: Value(_reviewController.text.trim().isEmpty ? null : _reviewController.text.trim()),
        images: Value(imagesJson),
        createdAt: Value(_existingReviewId != null ? now : now),
        updatedAt: Value(now),
      ),
    );
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存年度复盘')));
  },
  // ... style
)
```

#### 2.4.4 添加年份切换时重新加载

```dart
void _shiftYear(List<int> years, int activeYear, int delta) {
  if (years.isEmpty) return;
  final index = years.indexOf(activeYear);
  if (index == -1) return;
  final nextIndex = index + delta;
  if (nextIndex < 0 || nextIndex >= years.length) return;
  setState(() {
    _selectedYear = years[nextIndex];
    _isLoadingReview = true;
  });
  _loadAnnualReview();
}
```

**验证方法**：
- 保存年度复盘后数据持久化
- 切换年份后加载对应年份的复盘
- 重新打开页面显示已保存内容

---

### Task 2.5：添加必要的 import

**文件**：`lib/features/goal/presentation/goal_page.dart`

**修改位置**：文件顶部

**添加内容**：
```dart
import 'dart:convert';
```

**验证方法**：
- 编译通过

---

## 阶段3：界面优化

### Task 3.1：优化详情页布局紧凑度

**文件**：`lib/features/goal/presentation/goal_page.dart`

**修改位置**：`_GoalBreakdownDetailPageState` 的 build 方法

**修改内容**：

| 位置 | 原值 | 新值 |
|------|------|------|
| 第1809行 | `SizedBox(height: 2)` | 保持不变 |
| 第1811行 | `SizedBox(height: 16)` | `SizedBox(height: 12)` |
| 第1846行 | `SizedBox(height: 22)` | `SizedBox(height: 14)` |
| 第1874行 | `SizedBox(height: 18)` | `SizedBox(height: 12)` |
| 第1903行 | `SizedBox(height: 18)` | `SizedBox(height: 12)` |
| 第1964行 | `SizedBox(height: 18)` | `SizedBox(height: 12)` |
| 卡片内边距 | `EdgeInsets.all(16)` | `EdgeInsets.all(12)` |
| 标题与内容间距 | `SizedBox(height: 10)` | `SizedBox(height: 8)` |

**验证方法**：
- 界面显示紧凑
- 无布局溢出

---

### Task 3.2：优化年度复盘页面布局

**文件**：`lib/features/goal/presentation/goal_page.dart`

**修改位置**：`AnnualGoalSummaryPage` 相关布局

**修改内容**：
- 减少各区块间距
- 统一卡片样式

**验证方法**：
- 界面显示紧凑
- 与详情页风格一致

---

## 阶段4：验证与文档

### Task 4.1：运行代码分析

**命令**：
```bash
flutter analyze
```

**验证方法**：
- 无错误
- 无警告（或仅有可接受的警告）

---

### Task 4.2：功能测试

**测试用例**：

| 序号 | 测试项 | 预期结果 |
|------|--------|---------|
| 1 | 新建目标并填写描述 | 描述正确保存到 note 字段 |
| 2 | 点击"编辑总结"填写内容 | 总结正确保存到 summary 字段，note 不变 |
| 3 | 点击"新增复盘"填写内容 | 复盘记录插入 GoalReviews 表 |
| 4 | 详情页显示阶段复盘列表 | 正确显示所有复盘记录 |
| 5 | 年度复盘页面填写并保存 | 数据持久化到 annual_reviews 表 |
| 6 | 切换年份后重新加载 | 显示对应年份的复盘内容 |
| 7 | 界面紧凑度检查 | 间距符合优化配置 |

---

### Task 4.3：更新文档

**文件**：
- `更新日志.md`：追加本次修改记录
- `开发设计文档.md`：更新数据库变更和接口变更

**内容**：
1. 在更新日志中新增条目
2. 在开发设计文档中记录：
   - 数据库变更：新增 annual_reviews 表
   - 接口变更：新增 AnnualReviewDao
   - 架构决策：note/summary/GoalReviews 语义分离

---

## 任务依赖关系

```
Task 1.1 → Task 1.2 → Task 1.3 → Task 1.4
                              ↓
Task 2.1 → Task 2.2 → Task 2.3 → Task 2.4 → Task 2.5
                                        ↓
                              Task 3.1 → Task 3.2
                                        ↓
                              Task 4.1 → Task 4.2 → Task 4.3
```

---

## 执行顺序建议

1. **先执行数据库层修改**（Task 1.1 - 1.4）
2. **再执行核心逻辑修复**（Task 2.1 - 2.5）
3. **然后执行界面优化**（Task 3.1 - 3.2）
4. **最后验证和更新文档**（Task 4.1 - 4.3）
