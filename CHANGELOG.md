# Changelog

PairNest 的所有重要更新都必须记录在本文件中，详细规范见 `docs/policies/CHANGELOG_POLICY.md`。

## [Unreleased]

### Changed

- 预留下一轮开发变更记录。

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
