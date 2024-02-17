# My Dotfiles and Scripts Repository

* Caution: If you are triggered by some of my choices always remember the legend by the name of `xkcd` and his wisdom about workflow which can be found [here in 1172](https://xkcd.com/1172/). If you are too lazy to read then just know "My setup works for me".

This repository contains my personal dotfiles and scripts, which I use to set up and configure my development environment. These files are essential for my workflow and help me maintain a consistent environment across different machines.

Dotfiles are configuration files in Unix-like systems (like Linux or MacOS) that start with a dot (e.g., .bashrc, .zshrc). They are used to customize and configure your system and applications. In this repository, you'll find my personal dotfiles for various applications and tools, including:

Bash: .bashrc, .bash_profile
Zsh: .zshrc, .p10k.zsh
SSH: .ssh/config
And more...
Scripts
The scripts in this repository automate various tasks, making it easier to set up and configure my environment. These scripts include:

Dotfiles setup: .script.d/dotfiles-setup.sh
Git configuration: .script.d/git-config.sh
And more...
Usage
To use these dotfiles and scripts, clone this repository to your local machine and run the appropriate scripts. Please note that these files are tailored to my personal preferences and may not work perfectly in your environment without modification.

## Setup Dot Files

```bash
bash <(curl -s https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/dotfiles-setup.sh)
```
