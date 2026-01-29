# My Dotfiles and Scripts Repository

* Caution: If some of my choices trigger you, always remember the legend named `xkcd` and his wisdom about workflow which can be found [here in 1172](https://xkcd.com/1172/). If you are too lazy to read, just know "My setup works for me".

This repository contains my dotfiles and scripts, which I use to set up and configure my development environment. These files are essential for my workflow and help me maintain a consistent environment across different machines.

Dotfiles are configuration files in Linux that start with a dot (e.g. `.bashrc`, `.zshrc`).
They are used to customize and configure your system and applications.
In this repository, you'll find my personal dotfiles for various applications and tools, including:

* Bash: `.bashrc`, `.bash_profile`
* Zsh: `.zshrc`, `.p10k.zsh`
* SSH: `.ssh/config`
* And more...

Assets are present in [assets branch](https://github.com/arpanrec/dotfiles/tree/assets)

## Installation

```bash
bash <(curl -sSL --connect-timeout 10 --max-time 10 \
    https://raw.githubusercontent.com/arpanrec/dotfiles/refs/heads/assets/install-dotfiles.sh)
```

## Scripts

* [Setup Debian - setup-debian.sh](./setup-debian)
* [Set up Workspace - setup-workspace.sh](./setup-workspace)
* [Linode Stack Script - linode-stack-script.sh](./linode‐stack‐script)
