#!/usr/bin/env bash

# shellcheck source=/dev/null
if [ -f "/etc/bashrc" ]; then
    source /etc/bashrc
fi

# if [ -f "${HOME}/.profile" ]; then
# shellcheck source=/dev/null
# source "${HOME}/.profile"
# fi

# shellcheck source=/dev/null
if [ -f /etc/bash.bashrc ]; then
    source /etc/bash.bashrc
fi

# shellcheck source=/dev/null
[ -f "$HOME/.aliasrc" ] && source "$HOME/.aliasrc"
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# shellcheck source=/dev/null
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi

unset rc

export HISTCONTROL=ignoreboth
shopt -s histappend
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTTIMEFORMAT="%F %T "
shopt -s checkwinsize
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# shellcheck source=/dev/null
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# shellcheck source=/dev/null
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# [ -f "/usr/local/bin/zsh" ] && exec /usr/local/bin/zsh -l

export BASH_IT="$HOME/.bash_it"
# shellcheck source=/dev/null
if [ -f "$BASH_IT/bash_it.sh" ]; then
    export BASH_IT_THEME='atomic'
    export BASH_IT_DEVELOPMENT_BRANCH='master'
    unset MAILCHECK
    export THEME_SHOW_PYTHON=true
    export IRC_CLIENT='irssi'
    export TODO="t"
    export BASH_IT_COMMAND_DURATION=true
    export COMMAND_DURATION_MIN_SECONDS=1
    export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1
    export THEME_SHOW_EXITCODE=true
    source "$BASH_IT/bash_it.sh"
fi

if hash powerline-shell &>/dev/null && [[ ! -f "$BASH_IT/bash_it.sh" ]]; then
    function _update_ps1() {
        PS1=$(powerline-shell $?)
    }
    if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
        PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    fi
fi

# shellcheck source=/dev/null
[ -f "$HOME/.exporterrc" ] && source "$HOME/.exporterrc"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if hash terraform &>/dev/null; then
    complete -C "$(readlink -f "$(which terraform)")" terraform
fi

if hash vault &>/dev/null; then
    complete -C "$(readlink -f "$(which vault)")" vault
fi

if hash gh &>/dev/null; then
    eval "$(gh completion -s bash)"
fi

if hash mc &>/dev/null; then
    complete -C "$(readlink -f "$(which mc)")" mc
fi
