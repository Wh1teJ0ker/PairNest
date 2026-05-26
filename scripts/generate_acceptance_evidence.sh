#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_FILE="docs/ACCEPTANCE_EVIDENCE.md"
NOW_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
NOW_LOCAL="$(date +"%Y-%m-%d %H:%M:%S %Z")"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
COMMIT="$(git rev-parse --short HEAD)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ANALYZE_LOG="$TMP_DIR/analyze.log"
TEST_LOG="$TMP_DIR/test.log"
RELEASE_LOG="$TMP_DIR/release.log"
COVERAGE_TABLE="$TMP_DIR/coverage.md"
UAT_CHECK_LOG="$TMP_DIR/uat_check.log"
UAT_LINT_LOG="$TMP_DIR/uat_lint.log"
UAT_SCRIPT_TEST_LOG="$TMP_DIR/uat_script_test.log"

echo "[evidence] flutter analyze"
flutter analyze | tee "$ANALYZE_LOG"

echo "[evidence] flutter test"
flutter test | tee "$TEST_LOG"

echo "[evidence] ./scripts/release_check.sh"
./scripts/release_check.sh | tee "$RELEASE_LOG"

echo "[evidence] ./scripts/check_requirement_coverage.sh"
./scripts/check_requirement_coverage.sh > "$COVERAGE_TABLE"

echo "[evidence] ./scripts/check_uat_result.sh"
if ./scripts/check_uat_result.sh > "$UAT_CHECK_LOG" 2>&1; then
  UAT_STATUS="通过"
else
  UAT_STATUS="未完成"
fi

echo "[evidence] ./scripts/lint_uat_result.sh"
if ./scripts/lint_uat_result.sh > "$UAT_LINT_LOG" 2>&1; then
  UAT_LINT_STATUS="通过"
else
  UAT_LINT_STATUS="未完成"
fi

echo "[evidence] ./scripts/test_uat_scripts.sh"
if ./scripts/test_uat_scripts.sh > "$UAT_SCRIPT_TEST_LOG" 2>&1; then
  UAT_SCRIPT_TEST_STATUS="通过"
else
  UAT_SCRIPT_TEST_STATUS="失败"
fi

cat >"$OUT_FILE" <<EOF
# PairNest 验收证据报告

生成时间（本地）：\`$NOW_LOCAL\`  
生成时间（UTC）：\`$NOW_UTC\`

构建信息：

- 分支：\`$BRANCH\`
- 提交：\`$COMMIT\`

## 1) 自动化门禁结果

- \`flutter analyze\`：通过
- \`flutter test\`：通过
- \`./scripts/release_check.sh\`：通过

## 2) 需求追踪文档

- \`docs/REQUIREMENT_TRACEABILITY_MATRIX.md\`
- \`docs/MVP_ACCEPTANCE_CHECKLIST.md\`
- \`docs/NEARBY_DUAL_DEVICE_UAT.md\`

## 3) 仍需真机补证项（双机 Nearby）

以下项需按 \`docs/NEARBY_DUAL_DEVICE_UAT.md\` 在真机上执行并补充截图：

- [ ] 双人绑定（扫码加入）通过
- [ ] 自动模式靠近同步通过
- [ ] 图片跨端同步与回填通过
- [ ] 重复同步幂等通过
- [ ] 跨 \`pair_id\` 隔离通过

UAT 自动校验：\`$UAT_STATUS\`（来源：\`scripts/check_uat_result.sh\`）
UAT 预检：\`$UAT_LINT_STATUS\`（来源：\`scripts/lint_uat_result.sh\`）
UAT 脚本自测：\`$UAT_SCRIPT_TEST_STATUS\`（来源：\`scripts/test_uat_scripts.sh\`）

## 4) 需求覆盖状态（自动生成）

$(cat "$COVERAGE_TABLE")

## 5) 命令输出摘要

### flutter analyze（尾部）

\`\`\`text
$(tail -n 10 "$ANALYZE_LOG")
\`\`\`

### flutter test（尾部）

\`\`\`text
$(tail -n 20 "$TEST_LOG")
\`\`\`

### release_check（尾部）

\`\`\`text
$(tail -n 30 "$RELEASE_LOG")
\`\`\`

### UAT 校验

\`\`\`text
$(cat "$UAT_CHECK_LOG")
\`\`\`

### UAT 预检

\`\`\`text
$(cat "$UAT_LINT_LOG")
\`\`\`

### UAT 脚本自测

\`\`\`text
$(cat "$UAT_SCRIPT_TEST_LOG")
\`\`\`
EOF

echo "[evidence] 报告已生成: $OUT_FILE"
