# Unused vars don't check
# shellcheck disable=SC2034,1090

## == Custom Values ============================================================
## -- Performance Related ------------------------------------------------------
# https://blog.patshead.com/2011/04/improve-your-oh-my-zsh-startup-time-maybe.html
skip_global_compinit=1

# http://disq.us/p/f55b78
setopt noglobalrcs

# 10ms for key sequences (Decrease key input delay)
# https://www.johnhawthorn.com/2012/09/vi-escape-delays/
export KEYTIMEOUT=1

## -- Default Setup ------------------------------------------------------------

## == Set Path =================================================================
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
    alias exa-grid='exa --long --grid'
    alias exa-tree='exa --long --tree'
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

## == Zprofile =================================================================
# https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zshenv
# Ensure that a non-login, non-interactive shell has a defined environment.
export ZDOTDIR=${ZDOTDIR:-$HOME}
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "$ZDOTDIR/.zprofile" ]]; then
    source "$ZDOTDIR/.zprofile"
fi
