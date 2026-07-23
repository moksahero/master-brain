#!/usr/bin/env python3
"""Phase 4: draw numbered callouts on an audit screenshot (PIL).

Red rounded rectangles around the evidence plus a numbered circle badge per box,
matching the report's figure style. Boxes are numbered in the order given, and
every number must be explained in the figure caption.

  python3 annotate.py in.png out.png --box 120,340,880,610 --box 60,1200,900,1400
  python3 annotate.py in.png out.png --box 0.1,0.2,0.6,0.4 --relative
  python3 annotate.py in.png out.png --box 120,340,880,610 --crop 0,200,1080,1600
  python3 annotate.py in.png out.png --box ... --start 3        # continue numbering

Coordinates are left,top,right,bottom in pixels of the ORIGINAL image (crop is
applied after the boxes are drawn, so you can copy numbers straight off the
full screenshot). With --relative they are fractions of width/height.
"""
import argparse
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("PIL missing: pip install --user pillow")

STROKE = (200, 40, 30)
BADGE_TEXT = (255, 255, 255)


def load_font(size):
    for path in (
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    ):
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


def parse_box(raw, size, relative):
    parts = [float(p) for p in raw.split(",")]
    if len(parts) != 4:
        raise ValueError(f"box needs 4 numbers, got {raw!r}")
    if relative:
        w, h = size
        parts = [parts[0] * w, parts[1] * h, parts[2] * w, parts[3] * h]
    left, top, right, bottom = (int(round(p)) for p in parts)
    if right <= left or bottom <= top:
        raise ValueError(f"box {raw!r} is inverted or empty")
    return left, top, right, bottom


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--box", action="append", default=[],
                    help="left,top,right,bottom (repeatable, numbered in order)")
    ap.add_argument("--relative", action="store_true",
                    help="treat box coords as fractions of the image size")
    ap.add_argument("--crop", help="left,top,right,bottom applied AFTER drawing")
    ap.add_argument("--start", type=int, default=1, help="first callout number")
    ap.add_argument("--width", type=int, help="stroke width override (default W/320)")
    args = ap.parse_args()

    img = Image.open(args.src).convert("RGB")
    draw = ImageDraw.Draw(img)
    w, _ = img.size

    stroke = args.width or max(3, round(w / 320))
    radius = max(8, round(stroke * 4))
    badge_r = max(16, round(w / 55))
    font = load_font(max(14, round(badge_r * 1.15)))

    for i, raw in enumerate(args.box, start=args.start):
        left, top, right, bottom = parse_box(raw, img.size, args.relative)
        draw.rounded_rectangle((left, top, right, bottom),
                               radius=radius, outline=STROKE, width=stroke)
        # badge sits on the top-left corner of the box, nudged inside the canvas
        cx = max(badge_r + 2, left)
        cy = max(badge_r + 2, top)
        draw.ellipse((cx - badge_r, cy - badge_r, cx + badge_r, cy + badge_r),
                     fill=STROKE, outline=STROKE)
        label = str(i)
        tb = draw.textbbox((0, 0), label, font=font)
        draw.text((cx - (tb[2] - tb[0]) / 2 - tb[0], cy - (tb[3] - tb[1]) / 2 - tb[1]),
                  label, font=font, fill=BADGE_TEXT)

    if args.crop:
        img = img.crop(parse_box(args.crop, img.size, args.relative))

    img.save(args.dst)
    print(f"✓ {args.dst}  {img.size[0]}x{img.size[1]}  "
          f"{len(args.box)} callout(s) starting at {args.start}")


if __name__ == "__main__":
    main()
