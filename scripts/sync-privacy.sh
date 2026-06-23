#!/usr/bin/env bash
# docs/privacy-policy.html を satori7227-dot/asobi-privacy リポジトリの index.html に同期する。
#
# 使い方:
#   export GH_PAT=github_pat_xxx   # asobi-privacy の Contents: Read and write を持つ fine-grained PAT
#   bash scripts/sync-privacy.sh
#
# 内容が変わっていない時は何もせず終了する（差分が出た時だけ commit + push）。
# CI から呼ぶ場合は GitHub Secrets に PAT を仕込んで env で渡せばよい。

set -euo pipefail

cd "$(dirname "$0")/.."

if [ -z "${GH_PAT:-}" ]; then
  echo "ERROR: GH_PAT 環境変数を設定してください（fine-grained PAT、asobi-privacy の Contents: Read and write）" >&2
  exit 1
fi

SOURCE=docs/privacy-policy.html
if [ ! -f "$SOURCE" ]; then
  echo "ERROR: $SOURCE が見つかりません" >&2
  exit 1
fi

SRC_SHA=$(git rev-parse --short HEAD)
TMP=$(mktemp -d -t asobi-privacy-sync.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

git clone --quiet "https://oauth2:${GH_PAT}@github.com/satori7227-dot/asobi-privacy.git" "$TMP/asobi-privacy"

cp "$SOURCE" "$TMP/asobi-privacy/index.html"

cd "$TMP/asobi-privacy"

if git diff --quiet index.html; then
  echo "No changes (asobi-privacy index.html is already in sync with asobi-app $SRC_SHA)"
  exit 0
fi

git -c user.email='satori7227@gmail.com' -c user.name='Satori Idogawa' add index.html
git -c user.email='satori7227@gmail.com' -c user.name='Satori Idogawa' commit -m "Sync privacy-policy from asobi-app $SRC_SHA

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
git push --quiet 2>&1 | sed "s|${GH_PAT}|<REDACTED>|g"

echo "✅ Synced privacy-policy from asobi-app $SRC_SHA to asobi-privacy/index.html"
