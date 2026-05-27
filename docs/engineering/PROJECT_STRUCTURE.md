# 项目结构与命名规范

本项目当前已经进入 Android-only 的持续演进阶段，后续新增代码应遵循以下结构，避免继续把页面、业务逻辑、弹窗和展示组件堆叠在单文件中。

## 一、目录原则

### 1. feature 内聚

`lib/src/features/<feature_name>/` 只放该 feature 的内容：

- `<feature>_page.dart`：该 feature 的页面入口
- `widgets/`：只属于该 feature 的局部组件
- `models/`：只属于该 feature 的轻量模型
- `controllers/` 或 `services/`：只属于该 feature 的本地业务编排

示例：

```text
lib/src/features/growth/
  growth_page.dart
  widgets/
    partner_score_sheet.dart
    partner_score_entry_card.dart
```

### 2. 跨 feature 通用能力单独放置

- `lib/src/domain/`：稳定业务模型、事件类型、跨页面共享实体
- `lib/src/data/`：仓库、数据库、持久化映射
- `lib/src/core/`：权限、常量、平台基础能力
- `lib/src/widgets/`：跨 feature 复用组件

不要把只有单个 feature 使用的组件提前抽到 `widgets/`，优先放在 feature 自己的 `widgets/` 目录。

## 二、命名规范

### 1. 文件名

统一使用 `snake_case.dart`。

推荐：

- `growth_page.dart`
- `partner_score_sheet.dart`
- `partner_score_entry_card.dart`
- `pair_invite.dart`

不推荐：

- `GrowthPage.dart`
- `growthPage.dart`
- `partnerScoreDialog.dart`

### 2. 页面类名

页面类统一使用 `PascalCase`，并以 `Page` 结尾：

- `GrowthPage`
- `TimelinePage`
- `BondingPage`

### 3. 局部组件类名

组件类用 `PascalCase`，名称体现语义，不用模糊命名：

- `PartnerScoreEntryCard`
- `PartnerScoreSheet`
- `SectionCard`

避免：

- `ItemWidget`
- `CustomBox`
- `Panel2`

### 4. provider 命名

Riverpod provider 统一使用 `<meaning>Provider`：

- `growthProvider`
- `todayStatusProvider`
- `partnerScoreHistoryProvider`

### 5. 仓库方法命名

仓库方法优先表达业务动作：

- `addTimelineEntry`
- `addPartnerScoreRecord`
- `checkinTogether`
- `recentPartnerScoreRecords`

避免过度抽象的名字：

- `saveData`
- `submitThing`
- `handleAction`

## 三、新增功能时的落点规则

### 1. 新功能只改一个页面时

至少拆出：

- 页面入口文件
- 一个 `widgets/` 子目录

### 2. 新功能涉及事件模型时

必须同时评估：

- `domain/models.dart`
- `data/pair_repository.dart`
- `sync` 图片/事件同步链路
- 相关 provider
- 最少一份映射或聚合测试

### 3. 新功能涉及图片时

必须确认：

- 本地持久化是否生效
- 时间轴或历史页是否能显示
- Nearby 同步后远端是否也能显示

## 四、下一步整理建议

当前仓库仍有一些可继续收敛的位置：

1. `timeline_page.dart` 仍偏大，建议拆出 `timeline_editor_card.dart` 与 `timeline_entry_card.dart`
2. `home_page.dart` 已承载较多摘要卡片，建议拆出 `widgets/` 子目录
3. `sync_panel.dart` 逻辑密度较高，后续应拆成：
   - 连接状态展示
   - 自动同步控制
   - 文件同步处理
4. 如 feature 内文件超过 300 行，优先考虑拆分

本规范从本轮开始执行，后续新增功能默认按此结构落地。
