: <<COMMENT
Author: arpan <arpan.rec@gmail.com>
This file is managed from https://github.com/arpanrecme/dotfiles/blob/main/.zshrc
COMMENT

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[ -f "$HOME/.exporterrc" ] && source $HOME/.exporterrc

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

ENABLE_CORRECTION="false"

COMPLETION_WAITING_DOTS="true"

plugins=(git
    mvn
    fzf
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    )

autoload -U compinit && compinit

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

[[ ! -f "$ZSH/oh-my-zsh.sh" ]] || source "$ZSH/oh-my-zsh.sh"

[ -f "$HOME/.aliasrc" ] && source $HOME/.aliasrc

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# unsetopt correct_all

if hash terraform &>/dev/null ; then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C "$(readlink -f "$(which terraform)")" terraform
fi

if hash kubectl &>/dev/null ; then
    source <(kubectl completion zsh)
fi
