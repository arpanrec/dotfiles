# My Dotfiles and Scripts Repository

* Caution: If some of my choices trigger you always remember the legend named `xkcd` and his wisdom about workflow which can be found [here in 1172](https://xkcd.com/1172/). If you are too lazy to read, just know "My setup works for me".

This repository contains my dotfiles and scripts, which I use to set up and configure my development environment. These files are essential for my workflow and help me maintain a consistent environment across different machines.

## Installation

```bash
bash <(curl -s https://raw.githubusercontent.com/arpanrec/dotfiles/main/.script.d/dotfiles-setup.sh)
```

## Technical Details

Git bare directory is `${HOME}/.dotfiles`.

The alias `dotfiles` is used to interact with the repository.

```bash
alias dotfiles='git --git-dir="${HOME}/.dotfiles" --work-tree=${HOME}'
```

Also all the untracked files are ignored by default.

```bash
dotfiles config --local status.showUntrackedFiles no
```

FYI: If any directory name is matching with any branch then it will cause an error. For example, if you have a directory named `main` and you are trying to checkout `main` branch then it will cause an error.

## [Dotfiles](/docs/dotfiles.md)

## [Scripts](/docs/scripts.md)

## License

[`GLWTS`](/docs/LICENSE)
