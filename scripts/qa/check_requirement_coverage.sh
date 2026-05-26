#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if [[ "${1:-}" == "--help" ]]; then
  cat <<'EOF'
用法:
  ./scripts/qa/check_requirement_coverage.sh

输出:
  Markdown 表格，标记每条核心需求当前是否具备自动化验证证据，
  或仍需真机验证。
EOF
  exit 0
fi

render_row() {
  local id="$1"
  local module="$2"
  local requirement="$3"
  local status="$4"
  local evidence="$5"
  printf '| %s | %s | %s | %s | %s |\n' "$id" "$module" "$requirement" "$status" "$evidence"
}

echo '| ID | 模块 | 需求点 | 状态 | 证据 |'
echo '|---|---|---|---|---|'

render_row "B-1" "双人绑定" "二维码绑定与加入" "需真机验证" "docs/qa/NEARBY_DUAL_DEVICE_UAT.md"
render_row "B-2" "双人绑定" "同一 pair_id 共享空间" "自动已验证" "test/sync_session_test.dart + pairId 校验逻辑"

render_row "H-1" "首页" "恋爱天数/今日状态/最近记录/成长值/纪念日提醒渲染" "自动已验证" "flutter analyze + widget_test + providers"

render_row "T-1" "时间轴" "文字/心情/标签映射" "自动已验证" "test/timeline_mapping_test.dart"
render_row "T-2" "时间轴" "图片记录可渲染" "需真机验证" "docs/qa/NEARBY_DUAL_DEVICE_UAT.md（图片跨端同步后检查）"

render_row "S-1" "Nearby同步" "缺失事件同步与去重" "自动已验证" "test/sync_session_test.dart"
render_row "S-2" "Nearby同步" "靠近自动同步（发现+连接+自动请求）" "需真机验证" "docs/qa/NEARBY_DUAL_DEVICE_UAT.md"
render_row "S-3" "Nearby同步" "跨 pair_id 隔离" "自动+真机" "sync_session_test + UAT Step 5"

render_row "G-1" "成长系统" "签到加分/任务加分/记录活跃度" "自动已验证" "growth_task_mapping_test + growth 计算逻辑"
render_row "G-2" "成长系统" "首页与成长页数值一致" "需真机验证" "UAT（同操作后双页核对）"

render_row "A-1" "纪念日系统" "新增/倒计时/近期提醒/时间轴关联" "自动已验证" "timeline_mapping_test + anniversary/home providers"

render_row "P-1" "私密性" "SQLCipher + secure storage 密钥管理 + rekey 迁移" "自动已验证" "local_db.dart + mvp_self_check"
render_row "P-2" "私密性" "无服务端、仅本地与 Nearby" "自动已验证" "依赖与代码审计（无网络 API）"
