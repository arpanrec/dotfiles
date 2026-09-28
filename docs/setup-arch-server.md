# Setup Arch Server

Configures an Arch Linux base system from `arch-chroot` or on a running machine. It sets the timezone to `Asia/Kolkata`, locale to `en_US.UTF-8`, hostname, and pacman mirrors, then installs packages for networking, storage, development toolchains, cross-compilers, and monitoring. It also generates a random root password, adds a `wheel`-group admin user, hardens SSH, and can optionally install Docker, NVIDIA drivers, or `systemd-boot` with Secure Boot signing through `sbctl`.

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
