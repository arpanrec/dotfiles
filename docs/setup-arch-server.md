# Setup Arch Server

Configures a freshly installed Arch Linux base system (run from within `arch-chroot` or on a live system). Sets timezone to `Asia/Kolkata`, locale to `en_US.UTF-8`, hostname, pacman, and installs a comprehensive package set covering networking, storage, dev toolchains, cross-compilers, monitoring, and optionally Docker and NVIDIA drivers. Randomises the root password, creates a `wheel`-group admin user, hardens SSH, and optionally sets up `systemd-boot` with Secure Boot signing via `sbctl`.

**Allowed Hostnames:** `s1-dev`, `s2-dev`

## Interactive Prompts

| Prompt                 | Description                                          |
| ---------------------- | ---------------------------------------------------- |
| Systemd Secure Boot    | Install and sign bootloader with `sbctl`             |
| Enable pacman multilib | Enable the multilib repository                       |
| NVIDIA with DRM        | Install `nvidia-open` and configure DRM mode-setting |
| Install Docker         | Install Docker and related packages                  |
| Update mirrorlist      | Run `reflector` to pick fastest Indian mirrors       |

## Usage

```bash
bash setup-arch-server.sh [hostname]
```
