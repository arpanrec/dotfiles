#!/usr/bin/env python3

import shutil
from dataclasses import dataclass
from math import gcd
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from PIL import Image


@dataclass
class MainConfig:
    allowed_extensions: list[str]
    allowed_aspect_ratios: list[str]
    brightness_threshold: int
    target_resolution: str


CONFIG = MainConfig(
    allowed_extensions=[".jpg", ".jpeg", ".png", ".webp"],
    allowed_aspect_ratios=["16x9", "16x10"],
    brightness_threshold=120,
    target_resolution="3840x2160",
)

WALLPAPER_DIR = Path("wallpapers")

IMAGE_EXTS = tuple(CONFIG.allowed_extensions)
ALLOWED_ASPECT_RATIOS = CONFIG.allowed_aspect_ratios
BRIGHTNESS_THRESHOLD = CONFIG.brightness_threshold

TARGET_W, TARGET_H = map(int, CONFIG.target_resolution.split("x"))
# --------------------------------------------

CROP_LABELS = {
    "l": "left",
    "r": "right",
    "t": "top",
    "d": "down",
    "c": "center",
}


def perceived_brightness(path: Path) -> float:
    img = Image.open(path).convert("RGB")
    arr = np.asarray(img)
    luminance = 0.2126 * arr[:, :, 0] + 0.7152 * arr[:, :, 1] + 0.0722 * arr[:, :, 2]
    return luminance.mean()


def reduced_aspect_ratio(width: int, height: int) -> str:
    g = gcd(width, height)
    return f"{width // g}x{height // g}"


def scale_to_fill(img: Image.Image) -> Image.Image:
    w, h = img.size
    scale = max(TARGET_W / w, TARGET_H / h)
    new_w = round(w * scale)
    new_h = round(h * scale)
    return img.resize((new_w, new_h), Image.Resampling.LANCZOS)


def possible_crops(w: int, h: int):
    crops = {}

    if w > TARGET_W:
        crops["l"] = (0, 0, TARGET_W, TARGET_H)
        crops["r"] = (w - TARGET_W, 0, w, TARGET_H)
        crops["c"] = ((w - TARGET_W) // 2, 0, (w + TARGET_W) // 2, TARGET_H)

    elif h > TARGET_H:
        crops["t"] = (0, 0, TARGET_W, TARGET_H)
        crops["d"] = (0, h - TARGET_H, TARGET_W, h)
        crops["c"] = (0, (h - TARGET_H) // 2, TARGET_W, (h + TARGET_H) // 2)

    return crops


def show_previews(original, scaled, crops, title):
    total = 1 + len(crops)
    fig, axes = plt.subplots(1, total, figsize=(5 * total, 5))

    if total == 1:
        axes = [axes]

    axes[0].imshow(original)
    axes[0].set_title("Original")
    axes[0].axis("off")

    for ax, (key, box) in zip(axes[1:], crops.items()):
        ax.imshow(scaled.crop(box))
        ax.set_title(f"{key} = {CROP_LABELS[key]}")
        ax.axis("off")

    fig.suptitle(title, fontsize=14)
    plt.tight_layout()
    plt.show()


def resize_and_crop(path: Path):
    with Image.open(path) as img_open:
        img = img_open.convert("RGB")

        if img.size == (TARGET_W, TARGET_H):
            return

        scaled = scale_to_fill(img)
        sw, sh = scaled.size

        crops = possible_crops(sw, sh)

        if not crops:
            scaled.save(path, quality=95)
            return

        show_previews(img, scaled, crops, path.name)

        valid = " ".join(crops.keys())
        valid_with_skip = f"{valid} s"

        while True:
            choice = (
                input(f"Choose crop ({valid_with_skip}) for {path.name}: ")
                .strip()
                .lower()
            )

            if choice == "s":
                return

            if choice in crops:
                final_img = scaled.crop(crops[choice])
                final_img.save(path, quality=95)
                return

            print("Invalid choice")


def classify_and_move(path: Path):
    with Image.open(path) as img:
        width, height = img.size

    aspect = reduced_aspect_ratio(width, height)

    if aspect not in ALLOWED_ASPECT_RATIOS:
        print(
            f"Skipping {path.name}: "
            f"aspect {width}x{height} → {aspect} (not allowed)"
        )
        return

    brightness = perceived_brightness(path)
    tone = "dark" if brightness < BRIGHTNESS_THRESHOLD else "light"

    dest_dir = WALLPAPER_DIR / aspect / tone
    dest_dir.mkdir(parents=True, exist_ok=True)

    dest_path = dest_dir / path.name

    print(
        f"{path.name} → {aspect}/{tone} "
        f"(res={width}x{height}, lum={brightness:.1f})"
    )

    shutil.move(path, dest_path)


def main():
    for path in sorted(WALLPAPER_DIR.iterdir()):
        if not path.is_file():
            continue
        if path.suffix.lower() not in IMAGE_EXTS:
            continue

        print(f"\nProcessing: {path.name}")

        try:
            resize_and_crop(path)
            # classify_and_move(path)
        except Exception as e:
            print(f"Error processing {path.name}: {e}")

    print("\nAll wallpapers processed!")


if __name__ == "__main__":
    main()
