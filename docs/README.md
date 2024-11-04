# My Dotfiles and Scripts Repository

* Caution: If some of my choices trigger you, always remember the legend named `xkcd` and his wisdom about workflow which can be found [here in 1172](https://xkcd.com/1172/). If you are too lazy to read, just know "My setup works for me".

This repository contains my dotfiles and scripts, which I use to set up and configure my development environment. These files are essential for my workflow and help me maintain a consistent environment across different machines.

Dotfiles are configuration files in Linux that start with a dot (e.g. .bashrc, .zshrc).
They are used to customize and configure your system and applications.
In this repository, you'll find my personal dotfiles for various applications and tools, including:

* Bash: [.bashrc](/.bashrc), [.bash_profile](/.bash_profile)
* Zsh: [.zshrc](/.zshrc), [.p10k.zsh](/.p10k.zsh)
* SSH: [.ssh/config](/.ssh/config)
* And more...

## [Installation](/.script.d/dot-install.sh)

```bash
bash <(curl -sSL https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/main/.script.d/dot-install.sh)
```

## Scripts

* [Debian - debian-cloudinit.sh](/docs/.script.d/debian-cloudinit.md)
* [Server Workspace - server-workspace.sh](/docs/.script.d/server-workspace.md)

## License

[`GLWTS`](/docs/LICENSE)
