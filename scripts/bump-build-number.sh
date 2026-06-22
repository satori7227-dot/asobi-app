#!/bin/sh
# CURRENT_PROJECT_VERSION を git のコミット数で自動採番する。
# Xcode の Build Phase（Pre-actions）から呼ぶか、fastlane の before_all で呼ぶ。
# 単独実行する場合は project root から `sh scripts/bump-build-number.sh` で OK。

set -eu
cd "$(dirname "$0")/.."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "skip: not a git repo"
  exit 0
fi

NEW=$(git rev-list HEAD --count)
FILE="Version.xcconfig"

if [ ! -f "$FILE" ]; then
  echo "missing $FILE"
  exit 1
fi

# CURRENT_PROJECT_VERSION 行のみ書き換える
TMP=$(mktemp)
awk -v new="$NEW" '
  /^CURRENT_PROJECT_VERSION/ { print "CURRENT_PROJECT_VERSION = " new; next }
  { print }
' "$FILE" > "$TMP"
mv "$TMP" "$FILE"

echo "CURRENT_PROJECT_VERSION = $NEW"
