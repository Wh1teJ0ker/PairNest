#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SKIP_UAT="false"
if [[ "${1:-}" == "--skip-uat" ]]; then
  SKIP_UAT="true"
fi

echo "[Final] 1) 发布前自动化检查"
./scripts/release_check.sh

if [[ "$SKIP_UAT" == "true" ]]; then
  echo "[Final] 2) 跳过双机UAT检查（--skip-uat）"
  echo "[Final] 最终检查通过（未校验双机UAT）"
  exit 0
fi

echo "[Final] 2) 双机UAT结果检查"
if ! ./scripts/check_uat_result.sh; then
  echo "[Final] UAT 强校验未通过，输出预检问题清单："
  ./scripts/lint_uat_result.sh || true
  exit 1
fi

echo "[Final] 最终检查通过（含双机UAT）"
