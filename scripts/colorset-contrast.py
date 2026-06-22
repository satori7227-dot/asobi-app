#!/usr/bin/env python3
"""各 .colorset の light/dark に対し、白テキスト・黒テキストとの
WCAG コントラスト比を計算して出力する。

ScenePicker のシーンカードは accent 色塗りなので、白か黒の
どちらかが AA Large (3:1) を満たせば「読める」と判定する。

使い方:
    python3 scripts/colorset-contrast.py
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "Asobi" / "Resources" / "Assets.xcassets"


def channel(value: str) -> float:
    s = value.strip()
    if s.startswith("0x"):
        return int(s, 16) / 255.0
    n = float(s)
    return n if 0 <= n <= 1 else n / 255.0


def relative_luminance(r: float, g: float, b: float) -> float:
    def lin(c: float) -> float:
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)


def contrast(lum1: float, lum2: float) -> float:
    a, b = max(lum1, lum2), min(lum1, lum2)
    return (a + 0.05) / (b + 0.05)


WHITE_LUM = relative_luminance(1, 1, 1)
BLACK_LUM = relative_luminance(0, 0, 0)


def best_text_contrast(r: float, g: float, b: float) -> tuple[str, float]:
    lum = relative_luminance(r, g, b)
    cw = contrast(lum, WHITE_LUM)
    cb = contrast(lum, BLACK_LUM)
    return ("white", cw) if cw >= cb else ("black", cb)


def parse_colorset(path: Path) -> dict[str, tuple[float, float, float]]:
    data = json.loads((path / "Contents.json").read_text())
    result: dict[str, tuple[float, float, float]] = {}
    for entry in data.get("colors", []):
        comp = entry.get("color", {}).get("components", {})
        if not comp:
            continue
        rgb = (channel(comp["red"]), channel(comp["green"]), channel(comp["blue"]))
        appearances = entry.get("appearances", [])
        key = "light"
        for a in appearances:
            if a.get("appearance") == "luminosity":
                key = a.get("value", "light")
        result[key] = rgb
    return result


def main() -> int:
    print(f"{'name':30} {'mode':6} {'text':6} {'ratio':>6} {'AA-Large(3:1)':>14}")
    print("-" * 70)
    for colorset in sorted(ROOT.rglob("*.colorset")):
        name = str(colorset.relative_to(ROOT).with_suffix(""))
        colors = parse_colorset(colorset)
        for mode in ("light", "dark"):
            if mode not in colors:
                continue
            r, g, b = colors[mode]
            text, ratio = best_text_contrast(r, g, b)
            verdict = "PASS" if ratio >= 3.0 else "FAIL"
            print(f"{name:30} {mode:6} {text:6} {ratio:6.2f} {verdict:>14}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
