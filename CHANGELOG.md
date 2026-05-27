# Changelog

PairNest 的所有重要更新都必须记录在本文件中，详细规范见 `docs/policies/CHANGELOG_POLICY.md`。

## [Unreleased]

## [0.1.4] - 2026-05-27

### Added

- 新增“奖惩记录”能力，可因具体事件对对方进行加分或减分，并支持附加图片保存与展示。
- 新增成长系统下的奖惩记录历史展示卡片与录入面板，统一沉淀到成长页和时间轴视图。
- 新增项目结构与命名规范文档，明确 feature 目录拆分、文件命名和 provider / repository 命名规则。

### Changed

- 重构成长页为更明确的分区式布局，将奖惩记录弹层和记录卡片拆分到 `features/growth/widgets/`。
- 重做全局主题、背景、导航、按钮、输入框和基础卡片体系，将应用视觉统一为更克制的暖白纸面与石墨深色模块风格。
- 重绘首页、成长页、同步状态卡和绑定入口页的主视觉层级，减少模板化彩色卡片堆叠，改为更现代的编辑感布局。

### Fixed

- 修复带图事件在双机同步后仅更新 `ADD_IMAGE` 事件、未回填真实展示事件的结构性问题，避免远端图片存在但页面不显示。
- 修复成长页签到按钮可重复连续点击的问题，新增本地交互锁和同日状态兜底，避免重复触发签到请求。

## [0.1.3] - 2026-05-27

### Changed

- 将仓库主页正式命名为“同频（PairNest）”，同步更新中英文 README 与版本说明文档，统一对外名称和当前发布基线。
- 完成 Android-only 仓库整理，移除对当前发布与预览无帮助的 iOS、macOS、Web 目录，减少远端无用平台目录和维护噪音。
- 调整静态分析范围，排除 `third_party` 下 vendored 插件示例工程，避免第三方示例代码干扰主应用质量门禁。

### Fixed

- 补齐双端配对状态投影，基于 `BIND_PAIR` 事件聚合当前空间的本机绑定、对端绑定、设备数和最近对端加入时间。
- 在首页和 Nearby 同步面板中新增“当前匹配状态”展示，明确区分“仅本机创建成功”和“已完成双端匹配”。
- 新增配对状态聚合测试，修复本轮状态链引入的页面与测试错误，保证 `flutter test` 可稳定验证配对状态规则。

## [0.1.2] - 2026-05-26

### Changed

- Pinned Android build inputs required for reproducible local and CI builds.
- Added GitHub tag-based Android release workflow and documented versioning rules.
- Standardized the repository homepage as Chinese-first with a maintained English companion README.
- Added a mandatory changelog policy and validation flow for every code update.
- Fixed Nearby runtime permission requests by splitting required permissions per Android SDK level.
- Made changelog validation compatible with GitHub runners that do not ship `rg`.
- Upgraded GitHub Actions checkout and Flutter setup dependencies to current stable pinned releases.

## [0.1.1] - 2026-05-26

### Changed

- Stabilized the Android GitHub Actions release workflow for tag-based publishing.
- Vendored the `nearby_connections` dependency to avoid upstream Android build instability.
- Standardized the initial release process around ABI-split APK assets and documented version governance.

## [0.1.0] - 2026-05-26

### Added

- Flutter MVP scaffold for PairNest.
- Local-first storage with SQLCipher-backed SQLite event log.
- Couple binding flow with QR invite generation and QR scan join.
- Home dashboard with:
  - love day count,
  - today status,
  - recent notes,
  - growth metrics,
  - anniversary reminder.
- Timeline with text, mood, tags, and image notes.
- Growth system with check-in reward accumulation.
- Anniversary create + countdown rendering.
- Nearby sync flow:
  - device discovery,
  - connection establishment,
  - missing-event sync,
  - duplicate detection,
  - image file transfer and event image-path backfill,
  - sync status metrics.
- Runtime permission handling for camera/gallery/nearby bluetooth-location stack.
- Developer quality gates:
  - local hooks (`pre-commit`, `pre-push`),
  - audit scripts,
  - CI quality workflow.
- Sync unit tests and MVP acceptance checklist.

### Quality

- `flutter analyze` passing.
- `flutter test` passing.
- `./scripts/qa/mvp_self_check.sh` passing.
