#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "[changelog] 检查 CHANGELOG.md"

if command -v rg >/dev/null 2>&1; then
  search_regex() {
    rg -q "$1" "$2"
  }

  search_fixed() {
    rg -Fq "$1" "$2"
  }

  search_regex_lines() {
    rg -n "$1" "$2"
  }
else
  search_regex() {
    grep -Eq "$1" "$2"
  }

  search_fixed() {
    grep -Fq "$1" "$2"
  }

  search_regex_lines() {
    grep -En "$1" "$2"
  }
fi

[[ -f CHANGELOG.md ]] || {
  echo "[changelog] 缺失 CHANGELOG.md"
  exit 1
}

[[ -f docs/policies/CHANGELOG_POLICY.md ]] || {
  echo "[changelog] 缺失 docs/policies/CHANGELOG_POLICY.md"
  exit 1
}

if ! search_regex '^## \[Unreleased\]' CHANGELOG.md; then
  echo "[changelog] 缺少 Unreleased 段落"
  exit 1
fi

if ! search_regex '^## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$' CHANGELOG.md; then
  echo "[changelog] 缺少规范的已发布版本段落"
  exit 1
fi

CURRENT_VERSION="$(sed -En 's/^version: ([0-9]+\.[0-9]+\.[0-9]+)\+[0-9]+$/\1/p' pubspec.yaml)"
if [[ -z "$CURRENT_VERSION" ]]; then
  echo "[changelog] 无法从 pubspec.yaml 解析当前版本"
  exit 1
fi

if ! search_fixed "## [$CURRENT_VERSION]" CHANGELOG.md; then
  echo "[changelog] CHANGELOG.md 缺少当前版本条目: $CURRENT_VERSION"
  exit 1
fi

if search_regex_lines '^- (fix bug|优化|更新代码|调整部分逻辑)$' CHANGELOG.md >/dev/null; then
  echo "[changelog] 检测到过于笼统的日志描述，请改为可审计表述"
  exit 1
fi

echo "[changelog] 通过"
