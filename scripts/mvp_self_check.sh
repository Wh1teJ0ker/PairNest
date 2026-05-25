#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[MVP] 1) 代码质量检查"
dart format lib test >/dev/null
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test

echo "[MVP] 2) 核心能力文件存在性检查"
required=(
  "lib/src/features/bonding/bonding_page.dart"
  "lib/src/features/bonding/scan_bind_page.dart"
  "lib/src/features/timeline/timeline_page.dart"
  "lib/src/features/sync/sync_panel.dart"
  "lib/src/features/sync/nearby_sync_service.dart"
  "lib/src/features/growth/growth_page.dart"
  "lib/src/features/anniversary/anniversary_page.dart"
)
for f in "${required[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "[MVP] 缺失: $f"
    exit 1
  fi
done

echo "[MVP] 3) 关键字段检查"
rg -n "pair_id|ADD_NOTE|ADD_IMAGE|ADD_SCORE|DAILY_CHECKIN|SQLCipher|sqflite_sqlcipher|flutter_secure_storage|PRAGMA rekey" lib pubspec.yaml README.md >/dev/null

echo "[MVP] 基线通过"
