#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

DEVICE='iPhone 17 Pro Max'
RESULT_BUNDLE=/tmp/AsobiUITests.xcresult
EXPORT_DIR=/tmp/asobi_screenshots
DEST_DIR=fastlane/screenshots/ja-JP

rm -rf "$RESULT_BUNDLE" "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR" "$DEST_DIR"

xcodebuild test \
  -project Asobi.xcodeproj \
  -scheme Asobi \
  -destination "platform=iOS Simulator,name=$DEVICE" \
  -only-testing:AsobiUITests/ScreenshotTests/test_captureAppStoreScreenshots \
  -resultBundlePath "$RESULT_BUNDLE" \
  CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  | tail -20

xcrun xcresulttool export attachments \
  --path "$RESULT_BUNDLE" \
  --output-path "$EXPORT_DIR" > /dev/null

python3 - <<'PY'
import json, os, shutil
manifest = json.load(open('/tmp/asobi_screenshots/manifest.json'))
dest = 'fastlane/screenshots/ja-JP'

def walk(d):
    if isinstance(d, dict):
        if 'attachments' in d:
            for a in d['attachments']:
                yield a
        for v in d.values():
            yield from walk(v)
    elif isinstance(d, list):
        for v in d:
            yield from walk(v)

for a in walk(manifest):
    ename = a.get('exportedFileName')
    sname = a.get('suggestedHumanReadableName', '')
    if not sname or not ename:
        continue
    base = sname.split('_0_')[0] + '.png'
    src = os.path.join('/tmp/asobi_screenshots', ename)
    if os.path.exists(src):
        shutil.copy(src, os.path.join(dest, base))
        print(f'  {base}')
PY

echo "✅ fastlane/screenshots/ja-JP/ に5枚配置完了"
