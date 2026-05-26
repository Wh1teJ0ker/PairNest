#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

UAT_FILE="docs/NEARBY_DUAL_DEVICE_UAT_RESULT.md"

if [[ ! -f "$UAT_FILE" ]]; then
  echo "[uat] 缺失 $UAT_FILE"
  exit 1
fi

total=$(rg -n "^- \[( |x)\] " "$UAT_FILE" | wc -l | tr -d ' ' || true)
passed=$(rg -n "^- \[x\] " "$UAT_FILE" | wc -l | tr -d ' ' || true)
pending=$(rg -n "^- \[ \] " "$UAT_FILE" | wc -l | tr -d ' ' || true)

if rg -n "YYYY-MM-DD|<name>|<model / android version>|<issue / screenshot path / reproducing steps>" "$UAT_FILE" >/dev/null; then
  echo "[uat] 检测到模板占位符未替换，请先填写真实验收信息"
  exit 3
fi

echo "[uat] total=$total passed=$passed pending=$pending"

if [[ "$total" -eq 0 ]]; then
  echo "[uat] 未找到验收条目，请检查模板"
  exit 1
fi

if [[ "$pending" -gt 0 ]]; then
  echo "[uat] 仍有未完成验收项"
  exit 2
fi

echo "[uat] 双机验收项全部通过"
