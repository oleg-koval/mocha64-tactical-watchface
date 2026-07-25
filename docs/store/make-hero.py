from PIL import Image, ImageDraw, ImageFont

W, H = 1440, 720

BG = (0, 0, 0)
PANEL = (0, 0, 0x55)
RULE = (0x55, 0x55, 0x55)
LABEL = (0xAA, 0xAA, 0xAA)
VALUE = (0xFF, 0xFF, 0xFF)
READY = (0x55, 0xFF, 0x55)
CAUTION = (0xFF, 0xAA, 0x00)
STRAIN = (0xFF, 0x55, 0x55)
DATA = (0x55, 0xAA, 0xFF)

MONO = "/System/Library/Fonts/Menlo.ttc"


def font(size, bold=False):
    try:
        return ImageFont.truetype(MONO, size, index=1 if bold else 0)
    except Exception:
        return ImageFont.load_default()


im = Image.new("RGB", (W, H), BG)
d = ImageDraw.Draw(im)

# Faint panel wash behind the left column, keeping the cool cast of PANEL.
SEAM = 760
d.rectangle([0, 0, SEAM, H], fill=PANEL)
d.line([(SEAM, 0), (SEAM, H)], fill=RULE, width=2)

# Corner ticks -- the same bracket language as the watch face.
T, M, WT = 46, 40, 3
for (cx, cy, dx, dy) in [(M, M, 1, 1), (W - M, M, -1, 1), (M, H - M, 1, -1), (W - M, H - M, -1, -1)]:
    d.line([(cx, cy), (cx + dx * T, cy)], fill=RULE, width=WT)
    d.line([(cx, cy), (cx, cy + dy * T)], fill=RULE, width=WT)

x = 108
d.text((x, 150), "MOCHA-64", font=font(96, True), fill=VALUE)
d.text((x, 252), "TACTICAL", font=font(72, True), fill=DATA)

d.line([(x, 372), (x + 560, 372)], fill=RULE, width=2)

d.text((x, 404), "A military instrument panel", font=font(30), fill=LABEL)
d.text((x, 444), "for your body.", font=font(30), fill=LABEL)

# Legend row: the three status colours, doing the job they do on the face.
ly = 530
for i, (name, col) in enumerate([("READY", READY), ("CAUTION", CAUTION), ("STRAIN", STRAIN)]):
    bx = x + i * 190
    d.rectangle([bx, ly, bx + 26, ly + 26], fill=col)
    d.text((bx + 38, ly + 2), name, font=font(22), fill=LABEL)

d.text((x, 604), "fenix 6 Pro  |  64-colour palette, re-derived", font=font(22), fill=RULE)

# Watch face render on the right.
try:
    face = Image.open("face-tight.png").convert("RGB")
    size = 470
    face = face.resize((size, size), Image.LANCZOS)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, size - 1, size - 1], fill=255)
    fx, fy = 860, (H - size) // 2
    d.ellipse([fx - 14, fy - 14, fx + size + 14, fy + size + 14], outline=RULE, width=2)
    im.paste(face, (fx, fy), mask)
except Exception as e:
    print("face image missing:", e)

im.save("hero-1440x720.png")
print("saved", im.size)
