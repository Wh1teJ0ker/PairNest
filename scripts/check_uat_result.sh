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

date_line="$(rg -m1 "^日期：" "$UAT_FILE" || true)"
build_line="$(rg -m1 "^构建版本：" "$UAT_FILE" || true)"
tester_line="$(rg -m1 "^测试人：" "$UAT_FILE" || true)"
device_a_line="$(rg -m1 "^- 设备 A：" "$UAT_FILE" || true)"
device_b_line="$(rg -m1 "^- 设备 B：" "$UAT_FILE" || true)"
bluetooth_line="$(rg -m1 "^- 蓝牙：" "$UAT_FILE" || true)"
location_line="$(rg -m1 "^- 定位：" "$UAT_FILE" || true)"
wifi_line="$(rg -m1 "^- WiFi：" "$UAT_FILE" || true)"
permission_line="$(rg -m1 "^- 权限：" "$UAT_FILE" || true)"

for required_line in \
  "$date_line" \
  "$build_line" \
  "$tester_line" \
  "$device_a_line" \
  "$device_b_line" \
  "$bluetooth_line" \
  "$location_line" \
  "$wifi_line" \
  "$permission_line"; do
  if [[ -z "$required_line" ]]; then
    echo "[uat] 缺少必要字段，请检查 UAT 结果模板结构"
    exit 5
  fi
done

extract_backtick_value() {
  local raw="$1"
  echo "$raw" | sed -E 's/^.*：`([^`]*)`[[:space:]]*$/\1/'
}

date_value="$(extract_backtick_value "$date_line")"
build_value="$(extract_backtick_value "$build_line")"
tester_value="$(extract_backtick_value "$tester_line")"
device_a_value="$(extract_backtick_value "$device_a_line")"
device_b_value="$(extract_backtick_value "$device_b_line")"
bluetooth_value="$(extract_backtick_value "$bluetooth_line")"
location_value="$(extract_backtick_value "$location_line")"
wifi_value="$(extract_backtick_value "$wifi_line")"
permission_value="$(extract_backtick_value "$permission_line")"

if ! echo "$date_value" | rg -q '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
  echo "[uat] 日期格式错误，应为 YYYY-MM-DD：$date_value"
  exit 5
fi

if ! echo "$build_value" | rg -q '^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$'; then
  echo "[uat] 构建版本格式错误，应为 x.y.z+n：$build_value"
  exit 5
fi

if [[ -z "$tester_value" ]]; then
  echo "[uat] 测试人不能为空"
  exit 5
fi

if [[ -z "$device_a_value" || -z "$device_b_value" ]]; then
  echo "[uat] 设备信息不能为空"
  exit 5
fi

if [[ "$device_a_value" == "$device_b_value" ]]; then
  echo "[uat] 设备 A/B 信息完全相同，请确认是两台不同设备"
  exit 5
fi

if [[ "$bluetooth_value" != "on" && "$bluetooth_value" != "off" ]]; then
  echo "[uat] 蓝牙字段仅允许 on/off：$bluetooth_value"
  exit 5
fi

if [[ "$location_value" != "on" && "$location_value" != "off" ]]; then
  echo "[uat] 定位字段仅允许 on/off：$location_value"
  exit 5
fi

if [[ "$wifi_value" != "on" && "$wifi_value" != "off" ]]; then
  echo "[uat] WiFi 字段仅允许 on/off：$wifi_value"
  exit 5
fi

if [[ "$permission_value" != "granted" && "$permission_value" != "partial" ]]; then
  echo "[uat] 权限字段仅允许 granted/partial：$permission_value"
  exit 5
fi

required_screenshots=(
  "绑定二维码页"
  "自动模式运行中状态"
  "同步后B端首页与时间轴"
  "跨 pair_id 隔离提示"
)

for label in "${required_screenshots[@]}"; do
  line="$(rg -m1 "^- ${label}：" "$UAT_FILE" || true)"
  if [[ -z "$line" ]]; then
    echo "[uat] 缺少截图字段：$label"
    exit 4
  fi

  if ! echo "$line" | rg -q '：`[^`]+`$'; then
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
