# Setup Fedora KDE

Configures a Fedora KDE workstation. It adds repositories for RPM Fusion, NordVPN, Docker, Brave, and Google Chrome, then installs packages for development, multimedia, web browsing, and system administration. For NVIDIA hardware, it installs CUDA drivers and the container toolkit. It also configures Docker, Snap, Flatpak (Flathub), and NordVPN services.

The script sets the hostname, generates a random root password, creates an admin user in the `sudo` group, enables passwordless `sudo` for `wheel`, and imports a custom root CA certificate from the `assets` branch.

**Allowed Hostnames:** `s1-dev`, `s1-dev-*`, `s2-dev`, `s2-dev-*`

**Environment Variables:**

| Variable                | Default    | Description                    |
| ----------------------- | ---------- | ------------------------------ |
| `SYSTEM_ADMIN_USER`     | `admin1`   | Username for the admin account |
| `SYSTEM_ADMIN_PASSWORD` | `password` | Password for the admin account |

## What It Installs

| Category          | Packages                                                                                                        |
| ----------------- | --------------------------------------------------------------------------------------------------------------- |
| Repositories      | RPM Fusion (free + nonfree), NordVPN, Docker CE, Brave Browser, Google Chrome                                   |
| Shell / core      | `curl`, `git`, `wget`, `tar`, `zip`, `unzip`, `zsh`, `bash-completion`, `fuse`, `fuse-libs`                     |
| Docker            | `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`                  |
| Dev tools         | `ninja-build`, `cmake`, `gcc`, `make`, `gettext`, `shfmt`, `python3-devel`, `python3-pyyaml`, `lua`, `luarocks` |
| Browsers          | `google-chrome-stable`, `brave-browser`                                                                         |
| Multimedia        | `vlc`, `haruna`, `ffmpeg` (replaces `ffmpeg-free`), `ffmpegthumbnailer`, `ffmpegthumbs`                         |
| Desktop           | `kvantum`, `gtk-murrine-engine`, `gtk2-engines`, `dolphin-plugins`, `kate`, `qbittorrent`                       |
| System            | `htop`, `fastfetch`, `nordvpn-gui`, `flatpak`, `snapd`, `restic`, `rsync`, `vim`                                |
| NVIDIA (if found) | `cuda-drivers`, `nvtop`, `nvidia-container-toolkit`                                                             |

## What It Configures

- **Hostname:** Set from the first argument or current hostname; written to `/etc/hostname` and `/etc/hosts` with domain `blr-home.easyiac.com`
- **Root password:** Randomised via `openssl rand`
- **Admin user:** Created with `sudo` group membership; removed from `wheel` if present
- **Sudoers:** `wheel` gets passwordless sudo, `sudo` group gets password-required sudo
- **Docker:** `docker.service` and `docker.socket` enabled
- **Snap:** `snapd.socket` enabled
- **NordVPN:** `nordvpnd.socket` and `nordvpnd.service` enabled
- **Flatpak:** Flathub remote added
- **NVIDIA (if detected):** CUDA drivers installed, container toolkit configured for Docker, dracut module added
- **Root CA:** Custom intermediate CA certificate installed from the `assets` branch and added to system trust

## Usage

```bash
sudo bash setup-fedora-kde.sh [hostname]
```
