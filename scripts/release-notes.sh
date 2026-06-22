#!/bin/sh
# 直近タグから HEAD までの commit メッセージを fastlane changelog 用にまとめる。
#
# 使い方:
#   sh scripts/release-notes.sh                       # 直近タグ→HEAD（タグ無しなら全 commit）
#   sh scripts/release-notes.sh v1.0.0                # 指定タグ→HEAD
#   sh scripts/release-notes.sh v1.0.0 v1.1.0         # タグ間
#
# 出力先:
#   - 標準出力（fastlane の changelog_from_git_commits 代替に使える）
#   - fastlane/metadata/ja/release_notes.txt （存在時のみ上書き）

set -eu
cd "$(dirname "$0")/.."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "skip: not a git repo" >&2
  exit 0
fi

FROM="${1:-$(git describe --tags --abbrev=0 2>/dev/null || true)}"
TO="${2:-HEAD}"

if [ -n "$FROM" ]; then
  RANGE="${FROM}..${TO}"
else
  # タグ無し: 全 commit を対象に
  RANGE="$TO"
fi

# `feat:` `fix:` `chore:` 等の Conventional Commits prefix を尊重しつつ、
# 1行 1 commit、Co-Authored-By 行は除外。
NOTES=$(git log "$RANGE" \
  --pretty=format:'- %s' \
  --no-merges \
  --invert-grep \
  --grep='^Co-Authored-By:' \
  2>/dev/null)

if [ -z "$NOTES" ]; then
  echo "(no commits in range $RANGE)"
  exit 0
fi

echo "$NOTES"

# fastlane に渡す日本語リリースノートも更新（存在すれば）。
JA_PATH="fastlane/metadata/ja/release_notes.txt"
if [ -d "$(dirname "$JA_PATH")" ]; then
  printf "%s\n" "$NOTES" > "$JA_PATH"
  echo "→ wrote $JA_PATH" >&2
fi
