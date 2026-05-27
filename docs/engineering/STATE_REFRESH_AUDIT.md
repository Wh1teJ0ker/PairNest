# 状态刷新一致性审计

本文档记录当前项目里“写操作完成后，哪些投影 provider 需要刷新”，用于降低后续功能演进时的遗漏风险。

## 一、统一入口

当前统一收口到：

- [projection_refresh.dart](/Users/joker/Code/PairNest/lib/src/app/projection_refresh.dart)

后续新增写操作时，优先：

1. 先判断是否能复用现有刷新组合
2. 如不能复用，再新增新的统一刷新方法
3. 不再鼓励在页面里继续散写一串 `ref.invalidate(...)`

## 二、当前写操作与刷新映射

### 1. 时间轴新增记录

入口：

- [timeline_page.dart](/Users/joker/Code/PairNest/lib/src/features/timeline/timeline_page.dart)

刷新：

- `timelineProvider`
- `growthProvider`
- `todayStatusProvider`

原因：

- 会新增时间轴内容
- 记录会给成长值带来活动度增量
- 今日状态里的记录数与心情展示可能变化

### 2. 奖惩记录

入口：

- [growth_page.dart](/Users/joker/Code/PairNest/lib/src/features/growth/growth_page.dart)

刷新：

- `growthProvider`
- `partnerScoreHistoryProvider`
- `timelineProvider`

原因：

- 奖惩直接影响成长值
- 奖惩历史列表需要更新
- 时间轴需要显示奖惩事件

### 3. 每日签到

入口：

- [growth_page.dart](/Users/joker/Code/PairNest/lib/src/features/growth/growth_page.dart)

刷新：

- `growthProvider`
- `todayStatusProvider`

原因：

- 签到带来成长值变化
- 今日状态里的签到状态需要更新

备注：

- 当前 `timelineProvider` 不需要刷新，因为时间轴投影并不展示 `DAILY_CHECKIN` 事件
- 已有测试覆盖该判断：
  - [timeline_mapping_test.dart](/Users/joker/Code/PairNest/test/timeline_mapping_test.dart)

### 4. 共同任务完成

入口：

- [growth_page.dart](/Users/joker/Code/PairNest/lib/src/features/growth/growth_page.dart)

刷新：

- `growthProvider`
- `growthTaskHistoryProvider`
- `todayStatusProvider`

原因：

- 任务完成会带来成长值变化
- 任务历史列表需要更新
- 今日状态里的任务数量需要更新

备注：

- 当前 `timelineProvider` 不需要刷新，因为时间轴投影并不展示 `COMPLETE_TASK` 事件
- 已有测试覆盖该判断：
  - [timeline_mapping_test.dart](/Users/joker/Code/PairNest/test/timeline_mapping_test.dart)

### 5. 纪念日新增

入口：

- [anniversary_page.dart](/Users/joker/Code/PairNest/lib/src/features/anniversary/anniversary_page.dart)

刷新：

- `anniversaryProvider`
- `timelineProvider`

原因：

- 纪念日列表本身变化
- 时间轴会同步展示纪念日事件

### 6. 创建空间 / 扫码加入 / 同步事件合并

入口：

- [bonding_page.dart](/Users/joker/Code/PairNest/lib/src/features/bonding/bonding_page.dart)
- [scan_bind_page.dart](/Users/joker/Code/PairNest/lib/src/features/bonding/scan_bind_page.dart)
- [sync_panel.dart](/Users/joker/Code/PairNest/lib/src/features/sync/sync_panel.dart)

刷新：

- `timelineProvider`
- `growthProvider`
- `growthTaskHistoryProvider`
- `partnerScoreHistoryProvider`
- `anniversaryProvider`
- `todayStatusProvider`
- `pairingStatusProvider`

原因：

- 这些动作会整体改变当前情侣空间的投影上下文
- 尤其是同步合并后，几乎所有首页摘要与分页面历史都可能变化

### 7. 同步图片落盘

入口：

- [sync_panel.dart](/Users/joker/Code/PairNest/lib/src/features/sync/sync_panel.dart)

刷新：

- `timelineProvider`
- `partnerScoreHistoryProvider`
- `pairingStatusProvider`

原因：

- 目前图片主要影响时间轴和奖惩记录显示
- 同步后配对状态区也会一起显示最近同步识别结果

## 三、本轮审计结论

在当前代码中，首页、成长、时间轴、纪念日、同步页之间的主写入路径已统一接入刷新辅助层。

已确认：

- feature 页面中已不再保留分散的大量直接 `ref.invalidate(...)`
- 刷新策略已集中，可继续演进
- 已重新核对首页、成长、时间轴、纪念日、同步页依赖的 provider 与当前事件映射，未发现新的主路径遗漏刷新
- 自动化检查已通过：
  - `flutter analyze`
  - `flutter test`

## 四、剩余风险

当前剩余风险主要不在“刷新遗漏”，而在“真实运行态验证”：

1. 双机 Nearby 同步需要继续人工验收
2. 图片同步后的远端展示需继续真机复核
3. 后续如新增新的事件类型，必须同步更新此文档与刷新辅助层
