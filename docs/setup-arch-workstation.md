# Setup Arch Workstation

Installs the full graphical workstation environment on top of an Arch base. Primary compositor is **Hyprland** with Waybar, Rofi, Dunst, and Kitty. KDE components (KWallet, Dolphin, Konsole, Gwenview, etc.) are installed for Wayland portal support, secret management, and file management, with an option to enable the full KDE Plasma session via SDDM.

Installs AUR packages (yay, NordVPN, Brave, Google Chrome, OnlyOffice, Yubico Authenticator, SDDM Silent theme) using a temporary unprivileged build user. Configures PipeWire audio, CUPS printing, Bluetooth, WireGuard, and GPU drivers (NVIDIA/AMD/Intel) as detected.

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
