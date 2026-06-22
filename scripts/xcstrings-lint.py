#!/usr/bin/env python3
"""Localizable.xcstrings を簡易 lint する。

検出するもの:
- en 翻訳の欠落（value が空 or 未設定）
- 翻訳忘れ疑い（en の値に日本語が含まれる）
- en 値の重複（同じ英訳が複数キーに存在）

使い方:
    python3 scripts/xcstrings-lint.py
    python3 scripts/xcstrings-lint.py --strict   # 何かしらの警告で exit 1
"""
import argparse
import json
import sys
from collections import Counter
from pathlib import Path

PATH = Path(__file__).resolve().parent.parent / "Asobi" / "Resources" / "Localizable.xcstrings"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--strict", action="store_true", help="exit 1 on any warning")
    args = parser.parse_args()

    data = json.loads(PATH.read_text(encoding="utf-8"))
    strings = data.get("strings", {})
    issues = []

    en_values = []
    for key, entry in strings.items():
        en = entry.get("localizations", {}).get("en", {}).get("stringUnit", {}).get("value")
        if en is None or en == "":
            issues.append(f"[missing-en] {key!r}")
            continue
        en_values.append(en)
        # ja キーと同じ日本語が en 側に紛れ込んでいないかチェック
        if any("　" <= c <= "鿿" or "゠" <= c <= "ヿ" or "぀" <= c <= "ゟ" for c in en):
            issues.append(f"[en-has-japanese] {key!r} -> {en!r}")

    counts = Counter(en_values)
    for value, n in counts.items():
        if n > 1:
            keys = [
                k for k, e in strings.items()
                if e.get("localizations", {}).get("en", {}).get("stringUnit", {}).get("value") == value
            ]
            issues.append(f"[dup-en] {value!r} appears {n} times: {keys}")

    print(f"checked {len(strings)} keys, en values: {len(en_values)}")
    if not issues:
        print("OK: no issues found")
        return 0

    print(f"\n{len(issues)} issue(s):")
    for line in issues:
        print(" ", line)
    return 1 if args.strict else 0


if __name__ == "__main__":
    raise SystemExit(main())
