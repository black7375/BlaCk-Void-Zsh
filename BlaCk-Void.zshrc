##-------------------------Init------------------------
export BVZSH=$( cd "$(dirname "$0")" ; pwd )

BVFPATH=${BVZSH}/autoload
fpath+="${BVFPATH}"
if [[ -d "$BVFPATH" ]]; then
    for func in $BVFPATH/*; do
        autoload -Uz ${func:t}
    done
fi
unset BVFPATH

if [[ ! -f ${BVZSH}/BlaCk-Void.zshrc.zwc ]]; then
    zsh-compile &!
fi

# If not Interactively.
case $- in
    *i*);;
    *) return 0;;
esac

##-------------------------Zplugin set-------------------------
ZPLGIN_BIN=~/.zplugin/bin/zplugin.zsh
source $ZPLGIN_BIN
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
autoload -Uz cdr
autoload -Uz chpwd_recent_dirs

##----- Bundles from the oh-my-zsh.
# https://github.com/zdharma/zplugin/issues/119
ZSH="$HOME/.zplugin/plugins/robbyrussell---oh-my-zsh/"
local _OMZ_SOURCES=(
    # Libs
    lib/compfix.zsh
    lib/git.zsh
    lib/termsupport.zsh

    # Plugins
    plugins/autojump/autojump.plugin.zsh
    plugins/command-not-found/command-not-found.plugin.zsh
    plugins/fzf/fzf.plugin.zsh
    plugins/git/git.plugin.zsh
    plugins/pip/pip.plugin.zsh
    plugins/sudo/sudo.plugin.zsh
    plugins/thefuck/thefuck.plugin.zsh
    plugins/urltools/urltools.plugin.zsh
)
if [ -x "$(command -v tmux)" ]; then
    _OMZ_SOURCES=(
        $_OMZ_SOURCES
        plugins/tmux/tmux.plugin.zsh
        plugins/tmuxinator/tmuxinator.plugin.zsh
    )
fi

zplugin ice from"gh" pick"/dev/null" nocompletions blockf lucid \
        multisrc"${_OMZ_SOURCES}" compile"(${(j.|.)_OMZ_SOURCES})" \
        atinit"_zpcompinit-custom; zpcdreplay"
zplugin light robbyrussell/oh-my-zsh

##----- Bundles form the custom repo.
zplugin light chrissicool/zsh-256color
zplugin light mafredri/zsh-async
zplugin light romkatv/powerlevel10k

#zplugin light hchbaw/auto-fu.zsh ##crash with fzf..
#zplugin ice wait"1" atload'_zsh_autosuggest_start' lucid
zplugin light zsh-users/zsh-autosuggestions
#zplugin ice wait"1"
zplugin light hlissner/zsh-autopair
#zplugin ice wait"1"
zplugin light zsh-users/zsh-completions
#zplugin ice as"completion" blockf
#zplugin ice wait"1"
zplugin light black7375/zsh-git-completion
#zplugin ice wait"1" atload'_zsh_highlight' lucid
zplugin light zdharma/fast-syntax-highlighting

#zplugin ice wait"2" lucid
zplugin light djui/alias-tips
#zplugin ice wait"2" lucid
zplugin light b4b4r07/enhancd
#zplugin ice wait"2" lucid
zplugin light wfxr/forgit
#zplugin ice wait"2" lucid
zplugin light ytet5uy4/fzf-widgets
#zplugin ice wait"0" lucid
zplugin light seletskiy/zsh-git-smart-commands
#zplugin ice wait"2" lucid
zplugin light zsh-users/zsh-history-substring-search
#zplugin ice wait"2" lucid
zplugin light changyuheng/zsh-interactive-cd
#zplugin ice wait"2" lucid
zplugin light peterhurford/up.zsh
#zplugin ice wait"2" lucid
zplugin light jocelynmallon/zshmarks
#zplugin ice wait"2" pick"h.sh" lucid
zplugin ice pick"h.sh" lucid
zplugin light paoloantinori/hhighlighter
#zplugin ice wait"2" from"gl" as"program" pick"tldr" lucid
zplugin ice from"gl" as"program" pick"tldr"
zplugin light pepa65/tldr-bash-client

_zpcompinit-custom
zplugin cdreplay -q

##-------------------------Theme Set
local ztheme=~/.ztheme
if [ -e $ztheme ]; then
    source $ztheme
else
    source $BVZSH/BlaCk-Void.ztheme
fi

if [ -z "$BVZSH_THEME" ] ; then
    export BVZSH_THEME='auto'
fi
_zsh-theme $BVZSH_THEME

##-------------------------Plugin Set
#-----thefuck
eval "$(thefuck --alias)"

#-----Tmuxinator
if [ -x "$(command -v tmux)" ]; then
    tmux set-window-option -g pane-base-index 1
fi

#-----alias-tip
export ZSH_PLUGINS_ALIAS_TIPS_FORCE=0

#-----auto-fu
#zle-line-init () {auto-fu-init;}; zle -N zle-line-init
#zstyle ':completion:*' completer _oldlist _complete
#zle -N zle-keymap-select auto-fu-zle-keymap-select

#-----enhancd
ENHANCD_FILTER=fzf:fzy:peco
export ENHANCD_FILTER

#-----fzf-widgets
# Map widgets to key
export DOT_BASE_DIR=$BVZSH
bindkey '^fw' fzf-select-widget
bindkey '^f.' fzf-edit-dotfiles
bindkey '^fc' fzf-change-directory
bindkey '^fn' fzf-change-named-directory
bindkey '^ff' fzf-edit-files
bindkey '^fk' fzf-kill-processes
bindkey '^fs' fzf-exec-ssh
bindkey '^\'  fzf-change-recent-directory
bindkey '^r'  fzf-insert-history
bindkey '^xf' fzf-insert-files
bindkey '^xd' fzf-insert-directory
bindkey '^xn' fzf-insert-named-directory

## Git
bindkey '^fg'  fzf-select-git-widget
bindkey '^fga' fzf-git-add-files
bindkey '^fgc' fzf-git-change-repository

# GitHub
bindkey '^fh'  fzf-select-github-widget
bindkey '^fhs' fzf-github-show-issue
bindkey '^fhc' fzf-github-close-issue

## Docker
bindkey '^fd'  fzf-select-docker-widget
bindkey '^fdc' fzf-docker-remove-containers
bindkey '^fdi' fzf-docker-remove-images
bindkey '^fdv' fzf-docker-remove-volumes

# Enable Exact-match by fzf-insert-history
FZF_WIDGET_OPTS[insert-history]='--exact'

# Start fzf in a tmux pane
FZF_WIDGET_TMUX=1

#-----zsh-git-smart-commands
alias c='git-smart-commit'
alias a='git-smart-add'
alias p='git-smart-push seletskiy'
alias u='git-smart-pull'
alias r='git-smart-remote'
alias s='git status'

#-----zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

##-------------------------From bashrc-------------------------
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

##-------------------------Custom set-------------------------
setopt nonomatch
setopt interactive_comments
setopt correct
setopt noclobber
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=$HISTSIZE
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# eliminates duplicates in *paths
typeset -gU cdpath fpath path

[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && source $HOME/.autojump/etc/profile.d/autojump.sh

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Alias
alias tar-compress-gz='tar -zcvf'
alias tar-extract-gz='tar -zxvf'
alias map='telnet mapscii.me'
alias prettyping='$BVZSH/prettyping'
alias rsync-ssh='rsync -avzshe ssh --progress'

# Apple Terminal New Tab
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]
then
  function chpwd {
    printf '\e]7;%s\a' "file://$HOSTNAME${PWD// /%20}"
  }

  chpwd
fi

##-------------------------Library set
#-----Completion
BVFPATH=${BVZSH}/completion
fpath+="${BVFPATH}"
unset BVFPATH

source $BVZSH/lib/completion.zsh

#-----Fzf
source $BVZSH/lib/fzf-set.zsh
