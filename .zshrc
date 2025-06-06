if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[ -f "${HOME}/.exporterrc" ] && source ${HOME}/.exporterrc

export ZSH="${HOME}/.oh-my-zsh"

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

ZSH_THEME="powerlevel10k/powerlevel10k"

ENABLE_CORRECTION="false"

COMPLETION_WAITING_DOTS="true"

plugins=(fzf
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    )

autoload -U compinit && compinit

[[ ! -f "$ZSH/oh-my-zsh.sh" ]] || source "$ZSH/oh-my-zsh.sh"

[ -f "$HOME/.aliasrc" ] && source $HOME/.aliasrc

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# unsetopt correct_all

if command -v terraform &> /dev/null; then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C "$(readlink -f "$(which terraform)")" terraform
fi

if command -v kubectl &> /dev/null; then
    source <(kubectl completion zsh)
fi

# Remove bw completion because it's slow
# if command -v bw &> /dev/null; then
#         eval "$(bw completion --shell zsh 2>/dev/null); compdef _bw bw;" 2>/dev/null
# fi

if command -v vault &> /dev/null; then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C "$(readlink -f "$(which vault)")" vault
fi

if command -v gh &> /dev/null; then
    __auto_comp_file_path="${HOME}/.oh-my-zsh/completions/_gh"
    if [ ! -f "${__auto_comp_file_path}" ]; then
        mkdir "$(dirname "${__auto_comp_file_path}")" 2>/dev/null
        gh completion -s zsh > "${__auto_comp_file_path}"
    fi
    autoload -U compinit
    compinit -i
fi

if command -v mc &> /dev/null; then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C "$(readlink -f "$(which mc)")" mc
fi

FNM_PATH="${HOME}/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="${HOME}/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi
