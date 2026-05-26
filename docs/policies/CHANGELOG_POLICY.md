# Changelog Policy

本规范用于约束 PairNest 项目的代码更新日志，目标是保证每次变更都具备可审计性、可追踪性和可回滚性。

## 适用范围

以下情况必须更新日志：

- 任何准备合入 `main` 的功能变更
- 任何影响行为、界面、数据结构、同步逻辑、构建流程、发布流程的修改
- 任何版本发布

以下情况原则上也应更新日志：

- 重要测试补充
- 文档规范调整
- CI / 构建链路修复

## 基本要求

每次代码更新必须同时满足：

1. 更新 `CHANGELOG.md`
2. 在 Pull Request 描述中填写变更摘要
3. 标明验证方式
4. 标明影响范围和潜在风险

不接受以下写法：

- `fix bug`
- `优化`
- `调整部分逻辑`
- `更新代码`

这类描述无法用于回溯问题来源，也不满足发布审计要求。

## CHANGELOG 结构

`CHANGELOG.md` 使用以下层级：

```md
## [Unreleased]

### Added
- ...

### Changed
- ...

### Fixed
- ...

### Removed
- ...
```

发布版本使用：

```md
## [0.1.1] - 2026-05-26
```

## 条目撰写规则

每个日志条目应尽量回答以下问题：

- 改了什么
- 为什么改
- 用户或开发者会感知到什么变化
- 是否影响兼容性、数据、同步、构建或发布

推荐写法：

- `Stabilized the Android GitHub Actions release workflow for tag-based publishing.`
- `Added changelog validation to release checks so undocumented updates are blocked before publish.`
- `Fixed Nearby sync duplicate handling for repeated reverse sync pushes.`

不推荐写法：

- `更新 release`
- `修复问题`
- `优化代码结构`

## PR 描述要求

Pull Request 必须至少包含：

- 变更内容
- 影响范围
- 验证结果
- 风险点
- 回滚方案
- 更新日志说明

## 发布要求

发布前必须确认：

1. `pubspec.yaml` 版本号已更新
2. `CHANGELOG.md` 已包含当前版本条目
3. `README.md` 与 `README.en.md` 中的当前基线信息已同步
4. `./scripts/release/release_check.sh` 通过

## 自动校验

以下流程应阻止缺失日志的变更继续推进：

- 本地发布前检查
- GitHub Actions 质量门禁

如需跳过，必须有明确的仓库管理员批准，不允许默认绕过。
