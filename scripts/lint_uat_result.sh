#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

UAT_FILE="docs/NEARBY_DUAL_DEVICE_UAT_RESULT.md"
errors=()

add_error() {
  errors+=("$1")
}

extract_backtick_value() {
  local raw="$1"
  echo "$raw" | sed -E 's/^.*：`([^`]*)`[[:space:]]*$/\1/'
}

if [[ ! -f "$UAT_FILE" ]]; then
  echo "[uat-lint] 缺失 $UAT_FILE"
  exit 1
fi

if rg -n "YYYY-MM-DD|<name>|<model / android version>|<issue / screenshot path / reproducing steps>|<path/to/" "$UAT_FILE" >/dev/null; then
  add_error "检测到模板占位符未替换"
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

if [[ -z "$date_line" ]]; then add_error "缺少字段：日期"; fi
if [[ -z "$build_line" ]]; then add_error "缺少字段：构建版本"; fi
if [[ -z "$tester_line" ]]; then add_error "缺少字段：测试人"; fi
if [[ -z "$device_a_line" ]]; then add_error "缺少字段：设备 A"; fi
if [[ -z "$device_b_line" ]]; then add_error "缺少字段：设备 B"; fi
if [[ -z "$bluetooth_line" ]]; then add_error "缺少字段：蓝牙"; fi
if [[ -z "$location_line" ]]; then add_error "缺少字段：定位"; fi
if [[ -z "$wifi_line" ]]; then add_error "缺少字段：WiFi"; fi
if [[ -z "$permission_line" ]]; then add_error "缺少字段：权限"; fi

if [[ -n "$date_line" ]]; then
  date_value="$(extract_backtick_value "$date_line")"
  if ! echo "$date_value" | rg -q '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    add_error "日期格式错误（应为 YYYY-MM-DD）：$date_value"
  fi
fi

if [[ -n "$build_line" ]]; then
  build_value="$(extract_backtick_value "$build_line")"
  if ! echo "$build_value" | rg -q '^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$'; then
    add_error "构建版本格式错误（应为 x.y.z+n）：$build_value"
  fi
fi

if [[ -n "$tester_line" ]]; then
  tester_value="$(extract_backtick_value "$tester_line")"
  if [[ -z "$tester_value" ]]; then
    add_error "测试人不能为空"
  fi
fi

if [[ -n "$device_a_line" && -n "$device_b_line" ]]; then
  device_a_value="$(extract_backtick_value "$device_a_line")"
  device_b_value="$(extract_backtick_value "$device_b_line")"
  if [[ -z "$device_a_value" || -z "$device_b_value" ]]; then
    add_error "设备 A/B 信息不能为空"
  elif [[ "$device_a_value" == "$device_b_value" ]]; then
    add_error "设备 A/B 信息完全相同，请确认是两台不同设备"
  fi
fi

if [[ -n "$bluetooth_line" ]]; then
  bluetooth_value="$(extract_backtick_value "$bluetooth_line")"
  if [[ "$bluetooth_value" != "on" && "$bluetooth_value" != "off" ]]; then
    add_error "蓝牙字段仅允许 on/off：$bluetooth_value"
  fi
fi

if [[ -n "$location_line" ]]; then
  location_value="$(extract_backtick_value "$location_line")"
  if [[ "$location_value" != "on" && "$location_value" != "off" ]]; then
    add_error "定位字段仅允许 on/off：$location_value"
  fi
fi

if [[ -n "$wifi_line" ]]; then
  wifi_value="$(extract_backtick_value "$wifi_line")"
  if [[ "$wifi_value" != "on" && "$wifi_value" != "off" ]]; then
    add_error "WiFi 字段仅允许 on/off：$wifi_value"
  fi
fi

if [[ -n "$permission_line" ]]; then
  permission_value="$(extract_backtick_value "$permission_line")"
  if [[ "$permission_value" != "granted" && "$permission_value" != "partial" ]]; then
    add_error "权限字段仅允许 granted/partial：$permission_value"
  fi
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
    add_error "缺少截图字段：$label"
    continue
  fi

  if ! echo "$line" | rg -q '：`[^`]+`$'; then
    add_error "截图字段格式错误（需使用反引号包裹路径）：$label"
    continue
  fi

  value="$(extract_backtick_value "$line")"
  if [[ "$value" == *"<"* || "$value" == *">"* ]]; then
    add_error "截图字段仍包含占位符：$label"
    continue
  fi

  if ! echo "$value" | rg -qi '\.(png|jpg|jpeg|webp)$'; then
    add_error "截图字段不是图片路径：$label -> $value"
    continue
  fi

  if ! echo "$value" | rg -qi '^https?://'; then
    if [[ ! -f "$value" && ! -f "$ROOT_DIR/$value" ]]; then
      add_error "截图文件不存在：$label -> $value"
    fi
  fi
done

total=$(rg -n "^- \[( |x)\] " "$UAT_FILE" | wc -l | tr -d ' ' || true)
pending=$(rg -n "^- \[ \] " "$UAT_FILE" | wc -l | tr -d ' ' || true)
if [[ "$total" -eq 0 ]]; then
  add_error "未找到验收清单条目"
fi
if [[ "$pending" -gt 0 ]]; then
  add_error "仍有未勾选验收项（pending=${pending}）"
fi

if [[ "${#errors[@]}" -gt 0 ]]; then
  echo "[uat-lint] 发现 ${#errors[@]} 个问题："
  for i in "${!errors[@]}"; do
    idx=$((i + 1))
    echo "  $idx. ${errors[$i]}"
  done
  echo
  echo "[uat-lint] 处理建议："
  echo "  1) 按 docs/NEARBY_DUAL_DEVICE_UAT.md 完成双机测试"
  echo "  2) 填写 docs/NEARBY_DUAL_DEVICE_UAT_RESULT.md 所有字段与截图路径"
  echo "  3) 先运行 ./scripts/lint_uat_result.sh，清零问题后再运行 ./scripts/check_uat_result.sh"
  exit 1
fi

echo "[uat-lint] 预检通过，可执行 ./scripts/check_uat_result.sh"
