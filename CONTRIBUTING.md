# Contributing

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

## CI 审计

GitHub Actions 工作流文件：

- `.github/workflows/flutter_quality.yml`

在 `push(main/master)` 和 `pull_request` 上执行格式检查、静态分析、测试。
