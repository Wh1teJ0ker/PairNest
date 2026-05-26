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

required_screenshots=(
  "绑定二维码页"
  "自动模式运行中状态"
  "同步后B端首页与时间轴"
  "跨 pair_id 隔离提示"
)

for label in "${required_screenshots[@]}"; do
  line="$(rg -n "^- ${label}：" "$UAT_FILE" | head -n 1 || true)"
  if [[ -z "$line" ]]; then
    echo "[uat] 缺少截图字段：$label"
    exit 4
  fi

  if ! echo "$line" | rg -q "：`[^`]+`$"; then
    echo "[uat] 截图字段格式错误（需使用反引号包裹路径）：$label"
    exit 4
  fi

  value="$(echo "$line" | sed -E 's/^.*：`(.*)`$/\1/')"
  if [[ "$value" == *"<"* || "$value" == *">"* ]]; then
    echo "[uat] 截图字段仍包含占位符：$label"
    exit 4
  fi

  if ! echo "$value" | rg -qi '\.(png|jpg|jpeg|webp)$'; then
    echo "[uat] 截图字段不是图片路径：$label -> $value"
    exit 4
  fi

  if ! echo "$value" | rg -qi '^https?://'; then
    if [[ ! -f "$value" && ! -f "$ROOT_DIR/$value" ]]; then
      echo "[uat] 截图文件不存在：$label -> $value"
      exit 4
    fi
  fi
done

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
