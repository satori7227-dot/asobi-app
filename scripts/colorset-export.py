#!/usr/bin/env python3
"""xcassets 配下の .colorset から light / dark hex を CSV 出力する。

color-audit.html の表に Hex 値を流し込む補助スクリプト。

使い方:
    python3 scripts/colorset-export.py
    python3 scripts/colorset-export.py > docs/color-values.csv
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "Asobi" / "Resources" / "Assets.xcassets"


def to_hex(comp: dict) -> str:
    """`components` セクションから #RRGGBB を生成。0-1 の小数か 0-255 の整数を許容。"""
    def channel(value: str) -> int:
        s = value.strip()
        if s.startswith("0x"):
            return int(s, 16)
        try:
            n = float(s)
        except ValueError:
            return 0
        if 0 <= n <= 1:
            return int(round(n * 255))
        return int(n)

    r = channel(comp.get("red", "0"))
    g = channel(comp.get("green", "0"))
    b = channel(comp.get("blue", "0"))
    return f"#{r:02X}{g:02X}{b:02X}"


def parse_colorset(path: Path) -> dict[str, str]:
    """1 つの .colorset から {appearance: hex} を返す。"""
    json_path = path / "Contents.json"
    if not json_path.exists():
        return {}
    data = json.loads(json_path.read_text())
    result: dict[str, str] = {}
    for entry in data.get("colors", []):
        color = entry.get("color", {}).get("components", {})
        if not color:
            continue
        appearances = entry.get("appearances", [])
        if not appearances:
            result["light"] = to_hex(color)
        else:
            for a in appearances:
                if a.get("appearance") == "luminosity" and a.get("value") == "dark":
                    result["dark"] = to_hex(color)
                    break
    return result


def main() -> int:
    rows = [("name", "light", "dark")]
    for colorset in sorted(ROOT.rglob("*.colorset")):
        name = colorset.relative_to(ROOT).with_suffix("")
        colors = parse_colorset(colorset)
        rows.append((str(name), colors.get("light", "—"), colors.get("dark", "—")))
    for row in rows:
        print(",".join(row))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
