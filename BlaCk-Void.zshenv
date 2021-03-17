# Unused vars don't check
# shellcheck disable=SC2034,1090

## == Custom Values ============================================================
## -- Performance Related ------------------------------------------------------
## Avoid loading global configuration
# https://unix.stackexchange.com/questions/497050/case-insensitve-tab-completion-zsh-without-increasing-startup-time-significantly
unsetopt GLOBAL_RCS

# https://blog.patshead.com/2011/04/improve-your-oh-my-zsh-startup-time-maybe.html
skip_global_compinit=1

# http://disq.us/p/f55b78
setopt noglobalrcs

# 10ms for key sequences (Decrease key input delay)
# https://www.johnhawthorn.com/2012/09/vi-escape-delays/
export KEYTIMEOUT=1

## -- Reserved Variables -------------------------------------------------------
## XDG  Base Directory
# https://specifications.freedesktop.org/basedir-spec/latest/
# https://wiki.archlinux.org/index.php/XDG_Base_Directory
## (( ${+*} )) = if variable is set don't set it anymore. or use [[ -z ${*} ]]
(( ${+XDG_CONFIG_HOME} )) || export XDG_CONFIG_HOME="$HOME/.config"
(( ${+XDG_CACHE_HOME}  )) || export XDG_CACHE_HOME="$HOME/.cache"
(( ${+XDG_DATA_HOME}   )) || export XDG_DATA_HOME="$HOME/.local/share"

## Other System
(( ${+USER}     )) || export USER="$USERNAME"
(( ${+HOSTNAME} )) || export HOSTNAME="$HOST"
(( ${+LANG}     )) || export LANG="en_US.UTF-8"
(( ${+LANGUAGE} )) || export LANGUAGE="$LANG"
(( ${+LC_ALL}   )) || export LC_ALL="$LANG"

## Common Apps
# https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html#tag_08_01
export EDITOR="vim"
export VISUAL=$EDITOR
export FCEDIT=$EDITOR
export SYSTEMD_EDITOR=$EDITOR # for systemctl
export PAGER=less
export MANPAGER="$PAGER"

## == Set Path =================================================================
## -- CDPATH ---------------------------------------------------------------------
# on cd command offer dirs in home and one dir up.
export cdpath+=("$HOME" "..")

## -- FPATH ---------------------------------------------------------------------

## -- MANPATH ---------------------------------------------------------------------
export manpath+=(/usr/local/man /usr/share/man)

## -- PATH ---------------------------------------------------------------------
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/Application" ] ; then
    export PATH="$PATH:$HOME/Application"
fi

if [ -d "$HOME/Applications" ] ; then
    export PATH="$PATH:$HOME/Applications"
fi

if [ -d "$HOME/bin" ] ; then
    export PATH="$PATH:$HOME/bin"
fi

if [ -d "$HOME/.bin" ] ; then
    export PATH="$PATH:$HOME/.bin"
fi

if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$PATH:$HOME/.local/bin"
fi

if [ -d "$HOME/.cargo/bin" ] ; then
    export PATH="$PATH:$HOME/.cargo/bin"
fi

if [ -d "$HOME/.yarn/bin" ] ; then
    export PATH="$PATH:$HOME/.yarn/bin"
fi

if [ -d "/home/linuxbrew/.linuxbrew/bin" ] ; then
    export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
fi

if [ -d "/snap/bin" ] ; then
    export PATH="$PATH:/snap/bin"
fi

if [ -d "/usr/sbin" ] ; then
    export PATH="$PATH:/usr/sbin"
fi

if [ -d "/usr/local/bin" ] ; then
    export PATH="$PATH:/usr/local/bin"
fi

## -- Cleanup --------------------------------------------------------------------
# remove empty components to avoid '::' ending up + resulting in './' being in $PATH
path=( "${path[@]:#}" )

## eliminates duplicates in *paths
typeset -gU cdpath fpath path

## == Zprofile =================================================================
# https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zshenv
# Ensure that a non-login, non-interactive shell has a defined environment.
export ZDOTDIR=${ZDOTDIR:-$HOME}
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "$ZDOTDIR/.zprofile" ]]; then
    source "$ZDOTDIR/.zprofile"
fi
