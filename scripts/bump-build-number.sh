#!/bin/sh
# CURRENT_PROJECT_VERSION を git のコミット数で自動採番する。
# project.yml の直書き設定（4 target）を sed で書き換え、xcodegen で .xcodeproj に伝播。
# Xcode の Build Phase（Pre-actions）から呼ぶか、fastlane の before_all で呼ぶ。

set -eu
cd "$(dirname "$0")/.."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "skip: not a git repo"
  exit 0
fi

NEW=$(git rev-list HEAD --count)
FILE="project.yml"

if [ ! -f "$FILE" ]; then
  echo "missing $FILE"
  exit 1
fi

# 4 target の CURRENT_PROJECT_VERSION 行を全部書き換える
TMP=$(mktemp)
awk -v new="$NEW" '
  /^[[:space:]]+CURRENT_PROJECT_VERSION:/ {
    match($0, /^[[:space:]]+/)
    indent = substr($0, 1, RLENGTH)
    print indent "CURRENT_PROJECT_VERSION: \"" new "\""
    next
  }
  { print }
' "$FILE" > "$TMP"
mv "$TMP" "$FILE"

# Version.xcconfig も同期しておく（legacy 参照向け）
if [ -f Version.xcconfig ]; then
  TMP2=$(mktemp)
  awk -v new="$NEW" '
    /^CURRENT_PROJECT_VERSION/ { print "CURRENT_PROJECT_VERSION = " new; next }
    { print }
  ' Version.xcconfig > "$TMP2"
  mv "$TMP2" Version.xcconfig
fi

# xcodegen で .xcodeproj に反映
if [ -x ./.tools/xcodegen.artifactbundle/xcodegen-2.45.4-macosx/bin/xcodegen ]; then
  ./.tools/xcodegen.artifactbundle/xcodegen-2.45.4-macosx/bin/xcodegen generate >/dev/null
elif command -v xcodegen >/dev/null 2>&1; then
  xcodegen generate >/dev/null
fi

echo "CURRENT_PROJECT_VERSION = $NEW"
