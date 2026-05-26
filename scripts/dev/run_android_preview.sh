#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
ADB_BIN="$SDK_ROOT/platform-tools/adb"

cd "$ROOT_DIR"

./scripts/dev/start_android_emulator.sh

DEVICE_ID="$("$ADB_BIN" devices | awk '/^emulator-/{print $1; exit}')"
if [[ -z "$DEVICE_ID" ]]; then
  echo "[preview] No running emulator detected" >&2
  exit 1
fi

echo "[preview] Running on $DEVICE_ID"
flutter run -d "$DEVICE_ID"
