# Dotfiles: Assets

Dynamical assets for dotfiles.

## [Root Certificate Authority](./root_ca_crt.pem)

## [Machine Key ECDSA](./id_ecdsa.pub)

## Wallpapers

~~Wallpapers are stored in the [wallpapers](./wallpapers) directory with format `./wallpapers/<aspect ratio>/{light/dark}/*.*`~~

Scripts

~~- [Wallpaper Resize and Luminance Detector](./wallpaper_resizer_luminance.py): Resizes wallpapers to fit the screen resolution and places them in the correct directory based on luminance.~~

- [Wallpaper Resize](./wallpaper_resizer_luminance.py): Resizes wallpapers to fit the screen resolution.

Note: Convert all to JPGs:

```shell
find . -type f \( -iname "*.png" -o -iname "*.jpeg" -o -iname "*.jpg" \) ! -iname "*.jpg" \
    -exec sh -c '
for f; do
  out="${f%.*}.jpg"
  ffmpeg -y -i "$f" -q:v 1 "$out" && rm "$f"
done
' sh {} +

```
