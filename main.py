#!/usr/bin/env python3

from pathlib import Path
from PIL import Image
from math import gcd

WALLPAPER_DIR = Path("./wallpapers")

MONITORS = {
    "BLR_HOME_BENQ": (3840, 2160),
    "S1_DEV_INTERNAL": (2560, 1600),
    "S2_DEV_INTERNAL": (2880, 1800),
}

RATIO_TOLERANCE = 0.01
LOW_THRESHOLD = 0.70  # 70%

def aspect_ratio(w, h):
    g = gcd(w, h)
    return (w // g, h // g, w / h)

def ratio_match(a, b):
    return abs(a - b) <= RATIO_TOLERANCE

def resolution_flags(img_w, img_h, mon_w, mon_h):
    scale_w = img_w / mon_w
    scale_h = img_h / mon_h
    scale = min(scale_w, scale_h)

    flags = []

    # Native resolution check
    if img_w >= mon_w and img_h >= mon_h:
        flags.append("🟢 NATIVE+")
    else:
        flags.append("🔻 BELOW NATIVE")

    # Quality classification
    if scale >= 1.0:
        pass
    elif scale >= LOW_THRESHOLD:
        flags.append("⚠️ LOW")
    else:
        flags.append("❌ VERY LOW")

    return " ".join(flags)

def main():
    for path in sorted(WALLPAPER_DIR.iterdir()):
        if path.suffix.lower() not in {".jpg", ".jpeg", ".png", ".webp"}:
            continue

        try:
            with Image.open(path) as img:
                w, h = img.width, img.height
        except Exception:
            print(f"{path.name:<70} ERROR")
            continue

        r_w, r_h, r_img = aspect_ratio(w, h)

        matches = []
        for name, (mw, mh) in MONITORS.items():
            _, _, r_mon = aspect_ratio(mw, mh)
            if ratio_match(r_img, r_mon):
                flags = resolution_flags(w, h, mw, mh)
                matches.append(f"{name} [{flags}]")

        match_str = ", ".join(matches) if matches else "❓ NO MATCH"

        print(
            f"{path.name:<65} "
            f"{w:>5}x{h:<5} "
            f"({r_w}:{r_h}) -> {match_str}"
        )

if __name__ == "__main__":
    main()
