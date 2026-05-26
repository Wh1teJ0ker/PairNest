#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v flutter >/dev/null 2>&1; then
  echo "[audit] flutter 未安装或不在 PATH"
  exit 1
fi

echo "[audit] flutter pub get"
flutter pub get >/dev/null

echo "[audit] dart format --set-exit-if-changed"
dart format --output=none --set-exit-if-changed lib test

echo "[audit] flutter analyze"
flutter analyze

echo "[audit] flutter test"
flutter test

echo "[audit] check changelog"
./scripts/check_changelog.sh

echo "[audit] 通过"
