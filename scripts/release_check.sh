#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[Release] 1) 基础审计"
./scripts/audit.sh

echo "[Release] 2) MVP 验收自检"
./scripts/mvp_self_check.sh

echo "[Release] 3) 关键文档检查"
required=(
  "README.md"
  "CHANGELOG.md"
  "docs/MVP_ACCEPTANCE_CHECKLIST.md"
  ".github/workflows/flutter_quality.yml"
)
for f in "${required[@]}"; do
  [[ -f "$f" ]] || { echo "[Release] 缺失 $f"; exit 1; }
done

echo "[Release] 4) 版本号检查"
VERSION_LINE="$(rg -n "^version: " pubspec.yaml)"
echo "[Release] $VERSION_LINE"
echo "$VERSION_LINE" | rg -q '^.+version: [0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$'

echo "[Release] 5) UAT 脚本自测"
./scripts/test_uat_scripts.sh

echo "[Release] 发布前检查通过"
