# 首页图标统一治理提案

## Context

当前首页日历图标与当日日程已经完成了一轮问题修复，但经过第二轮反向 review，可以确认首页展示链路仍然存在结构性风险：

- 首页月历图标、首页当日日程、时间线 dots、详情跳转并不共用同一套事实源。
- 目前是“业务表直读 + `timeline_events` 混合模式”，不同模块的生成、删除、显示时机不完全统一。
- 本轮已修掉目标完成态与美食心愿清单两个用户可感知问题，但剩余风险本质上属于架构口径不统一，而不是单点 if 判断问题。

因此需要为首页图标体系补一份统一治理提案，明确后续应该如何收敛，而不是继续在页面层零散补丁式修复。

## Scope

本提案聚焦“首页图标统一治理”，涉及以下范围：

- 首页月历图标生成逻辑：`life_chronicle/lib/features/home_schedule/presentation/home_schedule_page.dart`
- 首页当日日程聚合逻辑：`life_chronicle/lib/features/home_schedule/presentation/home_schedule_page.dart`
- 时间线查询能力：`life_chronicle/lib/core/database/app_database.dart`
- 模块图标配置：`life_chronicle/lib/core/config/module_management_config.dart`
- 相关写入链路：
  - `life_chronicle/lib/features/moment/presentation/moment_page.dart`
  - `life_chronicle/lib/features/travel/presentation/travel_page.dart`
  - `life_chronicle/lib/features/bond/presentation/encounter_pages.dart`
  - `life_chronicle/lib/features/goal/presentation/goal_page.dart`
- 治理文档与结论沉淀：
  - `更新日志.md`
  - `开发设计文档.md`

本提案**不包含**以下内容：

- 不修改数据库表结构
- 不直接把所有模块强制切换为 `timeline_events` 唯一事实源
- 不在本阶段重写首页 UI
- 不修改业务模块的现有领域模型定义

## Behavior

### 目标行为

后续首页图标体系应满足以下行为约束：

1. 首页月历图标、首页当日日程、点击跳转应基于**统一口径**。
2. 每个模块都必须明确：
   - 首页事实源是什么
   - 什么时候生成
   - 什么时候删除
   - 什么时候显示
   - 是否受 `showOnCalendar` 影响
3. 页面层不再直接堆叠多个模块的原始流，而是消费统一聚合结果。
4. 不同模块可以保留不同底层来源，但首页对外只暴露统一 DTO。

### 推荐治理行为

推荐采用“**统一聚合层**”方案，而不是直接推进“全部走业务表”或“全部走 `timeline_events`”：

- 首页月历与首页当日日程统一改为消费 `HomeCalendarAggregator` / `HomeDayFeedAggregator` 一类聚合层输出。
- 聚合层内部按模块定义事实源：
  - 美食：`food_records`，过滤 `isWishlist=true`
  - 目标：`goal_records`，仅 `daily + isCompleted + !isDeleted`
  - 小确幸：`moment_records` + 模块标签配置
  - 旅行：短期可保留业务表 + 时间线混合来源，但对首页输出统一 DTO
  - 相遇：`timeline_events(encounter)`
- 首页 dots 与 icons 也应逐步改为同一聚合输出，避免“有图标没点 / 有点没图标”。

### 输出结果要求

统一治理完成后，首页层应具备两种标准输出：

- 月历图标输出：某月每天有哪些模块图标
- 当日日程输出：某天有哪些首页记录项，以及对应点击目标

两者都不应该再由页面直接拼装原始表流。

## Risks

### 若不治理的风险

- 后续每次修某个模块时，都可能再次引入首页月历和当日日程不一致的问题。
- `showOnCalendar`、图标、dots、详情跳转会继续分裂成多套口径。
- 首页页面文件会继续膨胀，维护成本持续增加。

### 若治理方式选择不当的风险

- 若强行全量切到 `timeline_events`：
  - 需要解决 food 与 goal 的投影语义问题
  - 容易重演这次目标完成态错位问题
- 若继续让页面直接聚合业务表：
  - 结构会越来越重
  - 规则分散在 UI 层，无法复用给其他首页相关能力

### 推荐控制方式

- 优先引入首页聚合层，不改表结构、不改主业务模型
- 先统一“首页口径”，再决定未来是否继续收敛底层事实源
- 为每个模块补齐“新增 / 编辑 / 删除 / 软删 / 历史补录 / 配置开关”测试矩阵

