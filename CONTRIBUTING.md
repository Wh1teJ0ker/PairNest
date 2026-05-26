# Contributing

## 主页与语言规范

- `README.md` 是中文主主页
- `README.en.md` 是英文版说明
- 涉及版本、发布、基线状态时，两份 README 需要同步更新

## 更新日志规范

每次代码更新都必须补充详细日志，不允许省略。

必读文档：

- `CHANGELOG.md`
- `docs/CHANGELOG_POLICY.md`

最低要求：

- 修改功能、构建、发布、同步、数据结构时必须更新 `CHANGELOG.md`
- 日志必须说明“改了什么、为什么改、影响范围、验证方式”
- 发布前必须执行：

```bash
./scripts/check_changelog.sh
```

## 本地代码审计（实时）

仓库已启用 `core.hooksPath=.githooks`，默认包含：

- `pre-commit`
  - 检查暂存的 Dart 文件格式
  - 若 `pubspec.yaml` 变更则执行 `flutter pub get`
- `pre-push`
  - 执行完整审计脚本 `./scripts/audit.sh`

## 手动执行完整审计

```bash
./scripts/audit.sh
```

该脚本会执行：

1. `flutter pub get`
2. `dart format --output=none --set-exit-if-changed lib test`
3. `flutter analyze`
4. `flutter test`
5. `./scripts/check_changelog.sh`

## CI 审计

GitHub Actions 工作流文件：

- `.github/workflows/flutter_quality.yml`

在 `push(main/master)` 和 `pull_request` 上执行格式检查、静态分析、测试。

## 发布前检查

```bash
./scripts/release_check.sh
```

该脚本会串行执行：

1. `./scripts/audit.sh`
2. `./scripts/mvp_self_check.sh`
3. 关键文档存在性检查
4. `pubspec.yaml` 版本号检查
5. 更新日志规范检查
