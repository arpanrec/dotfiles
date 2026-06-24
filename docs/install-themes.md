# Install Themes

Installs GTK, KDE Plasma, icon, cursor, and font assets. Detects GNOME Shell and switches between Layan GTK and Layan KDE accordingly.

## Installed Assets

| Category         | Assets                                                                                                                                                                                                                                                                                                                                |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GTK / KDE themes | [Nordic](https://github.com/EliverLara/Nordic), [Nordic KDE](https://github.com/EliverLara/Nordic-kde), [Layan KDE](https://github.com/vinceliuice/Layan-kde), [Layan GTK](https://github.com/vinceliuice/Layan-gtk-theme), [Sweet](https://github.com/EliverLara/Sweet), [Sweet Mars](https://github.com/EliverLara/Sweet/tree/mars) |
| Icon themes      | [Tela Icons](https://github.com/vinceliuice/Tela-icon-theme), [Candy Icons](https://github.com/EliverLara/candy-icons), [BeautyLine](https://github.com/gvolpe/BeautyLine)                                                                                                                                                            |
| Cursor themes    | [Layan Cursors](https://github.com/vinceliuice/Layan-cursors), [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor) (latest release)                                                                                                                                                                                              |
| Fonts            | [Nerd Fonts: JetBrainsMono, Hack, Meslo](https://github.com/ryanoasis/nerd-fonts), [Cascadia Code](https://github.com/microsoft/cascadia-code), MesloLGS NF (patched for Powerlevel10k)                                                                                                                                               |
| Wallpapers       | From the `assets` branch of this repository                                                                                                                                                                                                                                                                                           |

**Prerequisites:** `curl`, `git`, `unzip`, `gtk-update-icon-cache`, `jq`, `fc-cache`

## Usage

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/install-themes.sh)
```
