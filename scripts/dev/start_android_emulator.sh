#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
EMULATOR_BIN="$SDK_ROOT/emulator/emulator"
ADB_BIN="$SDK_ROOT/platform-tools/adb"
AVD_NAME="${1:-PairNest_API_35}"

if [[ ! -x "$EMULATOR_BIN" ]]; then
  echo "[emulator] emulator binary not found: $EMULATOR_BIN" >&2
  exit 1
fi

if [[ ! -x "$ADB_BIN" ]]; then
  echo "[emulator] adb not found: $ADB_BIN" >&2
  exit 1
fi

if ! "$EMULATOR_BIN" -list-avds 2>/dev/null | rg -Fxq "$AVD_NAME"; then
  echo "[emulator] AVD not found: $AVD_NAME" >&2
  echo "[emulator] Available AVDs:" >&2
  "$EMULATOR_BIN" -list-avds 2>/dev/null >&2 || true
  exit 1
fi

if "$ADB_BIN" devices | rg -q '^emulator-[0-9]+\s+device$'; then
  echo "[emulator] An emulator is already running."
  "$ADB_BIN" devices -l
  exit 0
fi

echo "[emulator] Starting $AVD_NAME"
nohup "$EMULATOR_BIN" -avd "$AVD_NAME" -no-snapshot -gpu swiftshader_indirect >/tmp/pairnest-emulator.log 2>&1 &

for _ in {1..90}; do
  if "$ADB_BIN" devices | rg -q '^emulator-[0-9]+\s+device$'; then
    echo "[emulator] Ready"
    "$ADB_BIN" devices -l
    exit 0
  fi
  sleep 2
done

echo "[emulator] Timed out waiting for emulator to become ready" >&2
tail -n 80 /tmp/pairnest-emulator.log >&2 || true
exit 1
