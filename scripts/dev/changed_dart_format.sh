#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

CHANGED_DART_FILES=$(
  git diff --cached --name-only --diff-filter=ACMR \
    | rg '^(lib|test)/.+\.dart$' \
    || true
)
if [[ -z "$CHANGED_DART_FILES" ]]; then
  echo "[pre-commit] 无 Dart 变更，跳过格式化检查"
  exit 0
fi

echo "[pre-commit] 检查暂存 Dart 文件格式"
# shellcheck disable=SC2086
dart format --output=none --set-exit-if-changed $CHANGED_DART_FILES
