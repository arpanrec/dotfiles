# My Dotfiles and Scripts Repository

* Caution: If some of my choices trigger you always remember the legend named `xkcd` and his wisdom about workflow which can be found [here in 1172](https://xkcd.com/1172/). If you are too lazy to read, just know "My setup works for me".

This repository contains my dotfiles and scripts, which I use to set up and configure my development environment. These files are essential for my workflow and help me maintain a consistent environment across different machines.

Dotfiles are configuration files in Linux that start with a dot (e.g. .bashrc, .zshrc).
They are used to customize and configure your system and applications.
In this repository, you'll find my personal dotfiles for various applications and tools, including:

* Bash: [.bashrc](/.bashrc), [.bash_profile](/.bash_profile)
* Zsh: [.zshrc](/.zshrc), [.p10k.zsh](/.p10k.zsh)
* SSH: [.ssh/config](/.ssh/config)
* And more...

## Installation

```bash
rm -rf "${HOME}/.dotfiles"
git clone --bare https://github.com/arpanrec/dotfiles.git "${HOME}/.dotfiles"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config --local status.showUntrackedFiles no
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout main --force
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" config --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
```

## License

[`GLWTS`](/docs/LICENSE)
