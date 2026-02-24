# 目标模块 UI 重构与功能完善 - 任务分解清单

## [ ] 任务 1: 分析现有数据库结构并设计数据扩展方案
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 分析现有 goal_records 表结构
  - 确认是否需要新增表来存储顺延记录和复盘内容
  - 与用户确认数据库变更方案
- **Acceptance Criteria Addressed**: AC-2, AC-3, AC-6
- **Test Requirements**:
  - `programmatic` TR-1.1: 确认现有数据库表结构的兼容性
  - `human-judgement` TR-1.2: 获得用户对数据库变更方案的批准
- **Notes**: 此任务必须在任何数据库变更前完成

---

## [ ] 任务 2: 目标看板布局重构
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 按照原型图 `5-1目标-人生目标看板/code.html` 重新设计目标看板
  - 调整卡片间距、排版，改善视觉效果
  - 保持现有功能逻辑不变
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `human-judgement` TR-2.1: 视觉效果与原型图一致
  - `programmatic` TR-2.2: 所有现有功能正常工作
- **Notes**: 参考 `前端/stitch_home_schedule_dashboard/5-1目标-人生目标看板/screen.png`

---

## [ ] 任务 3: 目标详情页新增阶段复盘展示
- **Priority**: P0
- **Depends On**: 任务 1
- **Description**: 
  - 在目标详情页截止时间下方添加阶段复盘内容展示区域
  - 使用现有 summary 字段或新增存储方案
  - 确保历史复盘数据完整展示
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `programmatic` TR-3.1: 有复盘内容的目标能正常展示
  - `programmatic` TR-3.2: 无复盘内容的目标不显示该区域或显示空状态
- **Notes**: 确保不丢失任何历史数据

---

## [ ] 任务 4: 目标详情页新增顺延记录展示
- **Priority**: P0
- **Depends On**: 任务 1
- **Description**: 
  - 在目标详情页截止时间下方添加顺延记录列表
  - 展示所有顺延历史记录
  - 设计符合 UI 规范的列表样式
- **Acceptance Criteria Addressed**: AC-3
- **Test Requirements**:
  - `programmatic` TR-4.1: 有顺延记录的目标能完整展示所有历史
  - `programmatic` TR-4.2: 无顺延记录的目标不显示该区域或显示空状态
- **Notes**: 参考顺延计划界面的记录展示样式

---

## [ ] 任务 5: 目标详情页右上角操作菜单
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 修改右上角按钮为可点击的菜单触发器
  - 实现弹出式菜单，包含 3 个按钮：拆解维护、编辑、删除
  - 菜单样式符合 UI 设计规范
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `programmatic` TR-5.1: 点击按钮正确弹出菜单
  - `programmatic` TR-5.2: 菜单位置在按钮下方
  - `programmatic` TR-5.3: 三个按钮功能正常跳转
- **Notes**: 使用底部弹窗或自定义菜单组件

---

## [ ] 任务 6: 新建顺延计划界面
- **Priority**: P0
- **Depends On**: 任务 1
- **Description**: 
  - 按照原型图 `5-6 目标--顺延目标计划/code.html` 新建顺延计划界面
  - 实现截止日期调整功能
  - 实现顺延原因与复盘填写功能
  - 实现过往顺延记录展示
- **Acceptance Criteria Addressed**: AC-5
- **Test Requirements**:
  - `human-judgement` TR-6.1: UI 与原型图一致
  - `programmatic` TR-6.2: 日期选择器功能正常
  - `programmatic` TR-6.3: 文本输入功能正常
  - `programmatic` TR-6.4: 过往记录列表正常展示
- **Notes**: 参考 `前端/stitch_home_schedule_dashboard/5-6 目标--顺延目标计划/`

---

## [ ] 任务 7: 顺延数据落库功能
- **Priority**: P0
- **Depends On**: 任务 1, 任务 6
- **Description**: 
  - 实现顺延记录的数据库存储方案
  - 更新目标的截止日期
  - 在详情页显示新添加的顺延记录
- **Acceptance Criteria Addressed**: AC-6
- **Test Requirements**:
  - `programmatic` TR-7.1: 点击确认顺延后数据正确保存
  - `programmatic` TR-7.2: 目标截止日期正确更新
  - `programmatic` TR-7.3: 返回详情页能看到新的顺延记录
  - `programmatic` TR-7.4: 重启应用后数据不丢失
- **Notes**: 需要更新变更日志记录

---

## [ ] 任务 8: 目标拆解维护界面重新设计
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 按照原型图 `5-5 目标 目标拆解维护/code.html` 重新设计界面
  - 确保 UI 风格与整体设计统一
  - 保持现有功能逻辑
- **Acceptance Criteria Addressed**: AC-7
- **Test Requirements**:
  - `human-judgement` TR-8.1: UI 与原型图一致
  - `programmatic` TR-8.2: 所有现有功能正常工作
- **Notes**: 参考 `前端/stitch_home_schedule_dashboard/5-5 目标 目标拆解维护/`

---

## [ ] 任务 9: 目标拆解数据存储完善
- **Priority**: P1
- **Depends On**: 任务 8
- **Description**: 
  - 确保阶段拆解数据正确存储
  - 确保任务管理数据正确存储
  - 实现保存功能
- **Acceptance Criteria Addressed**: AC-8
- **Test Requirements**:
  - `programmatic` TR-9.1: 添加阶段后数据正确保存
  - `programmatic` TR-9.2: 添加任务后数据正确保存
  - `programmatic` TR-9.3: 编辑/删除操作数据正确更新
  - `programmatic` TR-9.4: 重启应用后数据不丢失
- **Notes**: 需要更新变更日志记录

---

## [ ] 任务 10: 删除功能实现
- **Priority**: P0
- **Depends On**: 任务 5
- **Description**: 
  - 实现目标软删除功能
  - 删除后目标不再出现在列表中
  - 数据保留在数据库中
- **Acceptance Criteria Addressed**: AC-9
- **Test Requirements**:
  - `programmatic` TR-10.1: 点击删除弹出确认对话框
  - `programmatic` TR-10.2: 确认后目标从列表中消失
  - `programmatic` TR-10.3: 数据库中 is_deleted 标记为 1
- **Notes**: 考虑是否级联删除子目标（需要询问用户）

---

## [ ] 任务 11: 编辑功能复用新建界面
- **Priority**: P0
- **Depends On**: 任务 5
- **Description**: 
  - 修改新建目标界面支持编辑模式
  - 编辑时预填充当前目标的数据
  - 保存时更新现有目标而不是新建
- **Acceptance Criteria Addressed**: AC-10
- **Test Requirements**:
  - `programmatic` TR-11.1: 点击编辑跳转到新建界面
  - `programmatic` TR-11.2: 所有字段预填充当前目标数据
  - `programmatic` TR-11.3: 保存后正确更新现有目标
- **Notes**: 保持新建和编辑的 UI 一致

---

## [ ] 任务 12: 运行完整测试和验证
- **Priority**: P0
- **Depends On**: 任务 2-11
- **Description**: 
  - 运行 flutter analyze 确保无分析告警
  - 运行 flutter test 确保所有测试通过
  - 手动测试所有功能
- **Acceptance Criteria Addressed**: 所有 AC
- **Test Requirements**:
  - `programmatic` TR-12.1: flutter analyze 无错误
  - `programmatic` TR-12.2: flutter test 全部通过
  - `human-judgement` TR-12.3: 手动测试所有功能正常
- **Notes**: 需在多个设备/模拟器上测试

---

## [ ] 任务 13: 更新开发设计文档
- **Priority**: P1
- **Depends On**: 任务 1-12
- **Description**: 
  - 在版本变更记录表中新增一行
  - 在数据库变更章节登记所有表结构变动
  - 在接口变更章节登记接口变动
  - 如有架构调整新增 ADR
- **Acceptance Criteria Addressed**: N/A
- **Test Requirements**:
  - `human-judgement` TR-13.1: 文档更新完整
- **Notes**: 参考项目规则中的要求

---

## [ ] 任务 14: 更新更新日志
- **Priority**: P1
- **Depends On**: 任务 1-13
- **Description**: 
  - 在根目录更新日志中追加清晰条目
  - 按模块分类索引
  - 按类型分类索引
  - 在对应的更新记录日期下新增
- **Acceptance Criteria Addressed**: N/A
- **Test Requirements**:
  - `human-judgement` TR-14.1: 更新日志条目完整清晰
- **Notes**: 禁止覆盖或删除旧记录
