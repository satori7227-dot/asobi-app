#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

DEVICE='iPhone 17 Pro Max'
RESULT_BUNDLE=/tmp/AsobiUITests.xcresult
EXPORT_DIR=/tmp/asobi_screenshots

rm -rf "$RESULT_BUNDLE" "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR" fastlane/screenshots/ja-JP fastlane/screenshots/en-US

# LANGUAGES env var で 撮影言語を制御。デフォルトは ja のみ。
# 例: LANGUAGES=both bash scripts/capture-screenshots.sh
TESTS_ARG="-only-testing:AsobiUITests/ScreenshotTests/test_captureAppStoreScreenshots_ja"
if [ "${LANGUAGES:-ja}" = "both" ]; then
  TESTS_ARG="-only-testing:AsobiUITests/ScreenshotTests"
elif [ "${LANGUAGES:-ja}" = "en" ]; then
  TESTS_ARG="-only-testing:AsobiUITests/ScreenshotTests/test_captureAppStoreScreenshots_en"
fi

xcodebuild test \
  -project Asobi.xcodeproj \
  -scheme Asobi \
  -destination "platform=iOS Simulator,name=$DEVICE" \
  $TESTS_ARG \
  -resultBundlePath "$RESULT_BUNDLE" \
  CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  | tail -20

xcrun xcresulttool export attachments \
  --path "$RESULT_BUNDLE" \
  --output-path "$EXPORT_DIR" > /dev/null

python3 - <<'PY'
import json, os, shutil
manifest = json.load(open('/tmp/asobi_screenshots/manifest.json'))

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

LANG_TO_DIR = {'ja': 'fastlane/screenshots/ja-JP', 'en': 'fastlane/screenshots/en-US'}

for a in walk(manifest):
    ename = a.get('exportedFileName')
    sname = a.get('suggestedHumanReadableName', '')
    if not sname or not ename:
        continue
    # sname: 'ja_01_scene_picker_0_<uuid>.png' or 'en_01_...'
    stem = sname.split('_0_')[0]
    parts = stem.split('_', 1)
    if len(parts) < 2 or parts[0] not in LANG_TO_DIR:
        continue
    lang, rest = parts[0], parts[1]
    base = rest + '.png'
    dest = LANG_TO_DIR[lang]
    src = os.path.join('/tmp/asobi_screenshots', ename)
    if os.path.exists(src):
        shutil.copy(src, os.path.join(dest, base))
        print(f'  {lang}/{base}')
PY

echo "✅ fastlane/screenshots/{ja-JP,en-US}/ に各5枚配置完了"
