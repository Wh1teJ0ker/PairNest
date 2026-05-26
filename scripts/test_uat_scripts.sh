#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

SCREEN_DIR="$TMP_DIR/screens"
mkdir -p "$SCREEN_DIR"
touch "$SCREEN_DIR/qr.png" "$SCREEN_DIR/auto.png" "$SCREEN_DIR/synced.png" "$SCREEN_DIR/isolation.png"

PASS_FILE="$TMP_DIR/uat_pass.md"
cat >"$PASS_FILE" <<EOF
# PairNest 双机 Nearby 验收结果

日期：\`2026-05-26\`
构建版本：\`0.1.0+1\`
测试人：\`qa\`

设备信息：

- 设备 A：\`Pixel 7 / Android 14\`
- 设备 B：\`OnePlus 11 / Android 14\`

网络与权限：

- 蓝牙：\`on\`
- 定位：\`on\`
- WiFi：\`on\`
- 权限：\`granted\`

验收清单：

- [x] 双人绑定（扫码加入）通过
- [x] 自动模式靠近同步通过
- [x] 图片跨端同步与回填通过
- [x] 重复同步幂等通过
- [x] 跨 \`pair_id\` 隔离通过

备注：

- \`none\`

截图证据（必填）：

- 绑定二维码页：\`$SCREEN_DIR/qr.png\`
- 自动模式运行中状态：\`$SCREEN_DIR/auto.png\`
- 同步后B端首页与时间轴：\`$SCREEN_DIR/synced.png\`
- 跨 pair_id 隔离提示：\`$SCREEN_DIR/isolation.png\`
EOF

PENDING_FILE="$TMP_DIR/uat_pending.md"
cp "$PASS_FILE" "$PENDING_FILE"
sed -i '' 's/^- \[x\] 自动模式靠近同步通过/- [ ] 自动模式靠近同步通过/' "$PENDING_FILE"

PLACEHOLDER_FILE="$TMP_DIR/uat_placeholder.md"
cp "$PASS_FILE" "$PLACEHOLDER_FILE"
sed -i '' 's/日期：`2026-05-26`/日期：`YYYY-MM-DD`/' "$PLACEHOLDER_FILE"

run_expect() {
  local expect_code="$1"
  shift
  set +e
  "$@"
  local got_code=$?
  set -e
  if [[ "$got_code" -ne "$expect_code" ]]; then
    echo "[uat-test] 失败：期望退出码 $expect_code，实际 $got_code，命令: $*"
    exit 1
  fi
}

echo "[uat-test] 场景1：完整结果应通过"
run_expect 0 env UAT_FILE="$PASS_FILE" ./scripts/lint_uat_result.sh
run_expect 0 env UAT_FILE="$PASS_FILE" ./scripts/check_uat_result.sh

echo "[uat-test] 场景2：存在未勾选项应被拦截"
run_expect 1 env UAT_FILE="$PENDING_FILE" ./scripts/lint_uat_result.sh
run_expect 2 env UAT_FILE="$PENDING_FILE" ./scripts/check_uat_result.sh

echo "[uat-test] 场景3：占位符未替换应被拦截"
run_expect 1 env UAT_FILE="$PLACEHOLDER_FILE" ./scripts/lint_uat_result.sh
run_expect 3 env UAT_FILE="$PLACEHOLDER_FILE" ./scripts/check_uat_result.sh

echo "[uat-test] 全部通过"
