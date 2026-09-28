# Setup Arch Workstation

Installs a graphical desktop environment on an Arch Linux base. The primary compositor is Hyprland, paired with Waybar, Rofi, Dunst, and Kitty. It installs KDE tools (KWallet, Dolphin, Konsole, Gwenview) for Wayland portal integration, secret storage, and file management, with an option to enable a full KDE Plasma session in SDDM.

A temporary unprivileged build user installs AUR packages (yay, NordVPN, Brave, Google Chrome, OnlyOffice, Yubico Authenticator, SDDM Silent theme). The script also configures PipeWire audio, CUPS printing, Bluetooth, WireGuard, and graphics drivers (NVIDIA, AMD, or Intel).

## Interactive Prompts

| Prompt               | Description                                      |
| -------------------- | ------------------------------------------------ |
| KDE as second option | Install KDE components and portal support        |
| Minimal KDE Plasma   | Install `plasma` and `plasma-meta` metapackages  |
| NVIDIA with DRM      | Install NVIDIA drivers and environment variables |

## Usage

```bash
bash setup-arch-workstation.sh
```
