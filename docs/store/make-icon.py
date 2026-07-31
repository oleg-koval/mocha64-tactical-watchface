#!/usr/bin/env python3
"""Draw the launcher icon.

The icon shipped until now was the byte-identical copy of connectiq-starter's
template that every scaffolded project begins with -- a placeholder in the
store is worse than a plain one, because it reads as abandoned.

This draws the face's own grammar instead: corner brackets and a stack of
readings, in the palette the HUD actually uses. No text -- three characters at
40px is mush, and the brackets carry the identity on their own.

Rendered at 12x and downsampled once, which is what keeps a 1px bracket from
aliasing into grey at this size.

    python3 docs/store/make-icon.py

Two sizes. Most declared products ask for 40x40; the 454x454 AMOLED group
(Forerunner 965/970, fenix 8 47mm) asks for 65x65. Letting the compiler scale
a 40 up to 65 turns a 2px bracket into a grey smear, so each is drawn at its
own size and given its own resourcePath in monkey.jungle.
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]

# Mirrors source/Palette.mc.
BG = (0x00, 0x00, 0x00)
RULE = (0x55, 0x55, 0x55)
VALUE = (0xFF, 0xFF, 0xFF)
READY = (0x55, 0xFF, 0x55)
DATA = (0x55, 0xAA, 0xFF)
CAUTION = (0xFF, 0xAA, 0x00)

SS = 12


def render(size=40):
    s = size * SS
    im = Image.new("RGB", (s, s), BG)
    d = ImageDraw.Draw(im)

    # Corner brackets: the instrument-panel motif the face opens with.
    m = int(s * 0.10)
    arm = int(s * 0.22)
    w = max(1, int(s * 0.045))
    for cx, cy, dx, dy in (
        (m, m, 1, 1),
        (s - m, m, -1, 1),
        (m, s - m, 1, -1),
        (s - m, s - m, -1, -1),
    ):
        d.line([(cx, cy), (cx + dx * arm, cy)], fill=VALUE, width=w)
        d.line([(cx, cy), (cx, cy + dy * arm)], fill=VALUE, width=w)

    # Three readings, descending -- the recovery column in miniature. Colour
    # order matches the face: body battery green, heart rate blue, stress amber.
    bar_h = int(s * 0.10)
    gap = int(s * 0.09)
    x0 = int(s * 0.26)
    top = int(s * 0.30)
    full = int(s * 0.48)
    for i, (colour, frac) in enumerate(
        ((READY, 1.0), (DATA, 0.72), (CAUTION, 0.44))
    ):
        y = top + i * (bar_h + gap)
        # An unlit track behind each bar, so the stack reads as gauges rather
        # than as three unrelated dashes.
        d.rectangle([x0, y, x0 + full, y + bar_h], fill=RULE)
        d.rectangle([x0, y, x0 + int(full * frac), y + bar_h], fill=colour)

    return im.resize((size, size), Image.LANCZOS)


def main():
    for size, target in ((40, "resources"), (65, "resources-65")):
        icon = render(size)
        path = ROOT / target / "drawables" / "launcher_icon.png"
        path.parent.mkdir(parents=True, exist_ok=True)
        icon.save(path)
        print(f"wrote {target}/drawables/launcher_icon.png {icon.size}")


if __name__ == "__main__":
    main()
