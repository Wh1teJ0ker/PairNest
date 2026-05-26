#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANDROID_STUDIO_APP="/Applications/Android Studio.app"
ANDROID_STUDIO_JBR="$ANDROID_STUDIO_APP/Contents/jbr/Contents/Home"

if [[ ! -d "$ANDROID_STUDIO_APP" ]]; then
  echo "Android Studio not found: $ANDROID_STUDIO_APP" >&2
  exit 1
fi

mkdir -p "$ROOT_DIR/.gradle-local"

export JAVA_HOME="$ANDROID_STUDIO_JBR"
export GRADLE_USER_HOME="$ROOT_DIR/.gradle-local"

open -na "$ANDROID_STUDIO_APP" --args "$ROOT_DIR"
