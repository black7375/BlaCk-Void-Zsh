export BVZSH=$( cd "$(dirname "$0")" ; pwd )
##-------------------------Performance-------------------------
# https://gist.github.com/ctechols/ca1035271ad134841284
# On slow systems, checking the cached .zcompdump file to see if it must be 
# regenerated adds a noticable delay to zsh startup.  This little hack restricts 
# it to once a day.  It should be pasted into your own completion file.
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.

# Perform compinit only once a day.
autoload -Uz compinit

setopt EXTENDEDGLOB
for dump in $HOME/.zcompdump(#qN.m1); do
    compinit
    if [[ -s "$dump" && (! -s "$dump.zwc" || "$dump" -nt "$dump.zwc") ]]; then
        zcompile "$dump"
    fi
    echo "Initializing Completions..."
done
unsetopt EXTENDEDGLOB
compinit -C

##-------------------------From bashrc-------------------------
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

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

BVFPATH=${BVZSH}/autoload
fpath+="${BVFPATH}"
if [[ -d "$BVFPATH" ]]; then
    for func in $BVFPATH/*; do
        autoload -Uz ${func:t}
    done
fi
unset BVFPATH

#Alias
alias tar-compress-gz='tar -zcvf'
alias tar-extract-gz='tar -zxvf'
alias map='telnet mapscii.me'
alias prettyping='$BVZSH/prettyping'

#Apple Terminal New Tab
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]
then
  function chpwd {
    printf '\e]7;%s\a' "file://$HOSTNAME${PWD// /%20}"
  }

  chpwd
fi

##-------------------------Completion set
source $BVZSH/completion.zsh

# Complete words from tmux pane(s) {{{1
# Source: http://blog.plenz.com/2012-01/zsh-complete-words-from-tmux-pane.html
# Gist: https://gist.github.com/blueyed/6856354
_tmux_pane_words() {
  local expl
  local -a w
  if [[ -z "$TMUX_PANE" ]]; then
    _message "not running inside tmux!"
    return 1
  fi

  # Based on vim-tmuxcomplete's splitwords function.
  # https://github.com/wellle/tmux-complete.vim/blob/master/sh/tmuxcomplete
  _tmux_capture_pane() {
    tmux capture-pane -J -p -S -100 $@ |
      # Remove "^C".
      sed 's/\^C\S*/ /g' |
      # copy lines and split words
      sed -e 'p;s/[^a-zA-Z0-9_]/ /g' |
      # split on spaces
      tr -s '[:space:]' '\n' |
      # remove surrounding non-word characters
      =grep -o "\w.*\w"
  }
  # Capture current pane first.
  w=( ${(u)=$(_tmux_capture_pane)} )
  echo $w > /tmp/w1
  local i
  for i in $(tmux list-panes -F '#D'); do
    # Skip current pane (handled before).
    [[ "$TMUX_PANE" = "$i" ]] && continue
    w+=( ${(u)=$(_tmux_capture_pane -t $i)} )
  done
  _wanted values expl 'words from current tmux pane' compadd -a w
}

zle -C tmux-pane-words-prefix   complete-word _generic
zle -C tmux-pane-words-anywhere complete-word _generic
bindkey '^X^Tt' tmux-pane-words-prefix
bindkey '^X^TT' tmux-pane-words-anywhere
zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' completer _tmux_pane_words
zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' ignore-line current
# Display the (interactive) menu on first execution of the hotkey.
zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' menu yes select interactive
# zstyle ':completion:tmux-pane-words-anywhere:*' matcher-list 'b:=* m:{A-Za-z}={a-zA-Z}'
zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' matcher-list 'b:=* m:{A-Za-z}={a-zA-Z}'
# }}}

function _tmux_completions() {
  local -a sessions
  sessions=($(tmux-ls))
  compadd -a sessions
}
compdef _tmux_completions tmux-open

function tm() {
    [[ -z "$1" ]] && { echo "usage: tm <session>" >&2; return 1; }
    tmux has -t $1 && tmux attach -t $1 || tmux new -s $1
}

function __tmux-sessions() {
    local expl
    local -a sessions
    sessions=( ${${(f)"$(command tmux list-sessions)"}/:[ $'\t']##/:} )
    _describe -t sessions 'sessions' sessions "$@"
}
compdef __tmux-sessions tm

##-------------------------FZF set
source $BVZSH/fzf-set.zsh

##-------------------------Zplugin set-------------------------
ZPLGIN_BIN=~/.zplugin/bin/zplugin.zsh
if ! [ -e $ZPLGIN_BIN ]; then
  echo "\n--------------------"
  echo "Change Plugin Manager!!"
  echo "--------------------"

  echo "\n--------------------"
  echo "Install Zplugin"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"

  echo "\n--------------------"
  echo "Remove Antigen"
  rm -rfv $BVZSH/antigen.zsh
  rm -rfv ~/.antigen
fi

source $ZPLGIN_BIN
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
autoload compinit
autoload -Uz cdr
autoload -Uz chpwd_recent_dirs
compinit
zplugin cdreplay -q

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
  multisrc"${_OMZ_SOURCES}" compile"(${(j.|.)_OMZ_SOURCES})"
zplugin light robbyrussell/oh-my-zsh

##----- Bundles form the custom repo.
zplugin light chrissicool/zsh-256color
zplugin light mafredri/zsh-async
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
if [[ -e $BVZSH/hhighlighter ]]; then
  rm -rfv $BVZSH/hhighlighter
fi
#zplugin ice wait"2" from"gl" as"program" pick"tldr" lucid
zplugin ice from"gl" as"program" pick"tldr" lucid
zplugin light pepa65/tldr-bash-client

_OMZ_LIB=~/.zplugin/snippets/https--github.com--robbyrussell--oh-my-zsh--tree--master--lib/
if [[ -e $_OMZ_LIB ]]; then
  rm -rfv $_OMZ_LIB/compfix.zsh $_OMZ_LIB/termsupport.zsh
  if [[ "$( find $_OMZ_LIB -mindepth 1 -maxdepth 1 | wc -l )" -eq 0  ]]; then
    rm -rfv $_OMZ_LIB
  fi
fi
_OMZ_PLUGIN=~/.zplugin/snippets/https--github.com--robbyrussell--oh-my-zsh--tree--master--plugins
_OMZ_PLUGIN_LIST=(
  $_OMZ_PLUGIN--autojump
  $_OMZ_PLUGIN--command-not-found
  $_OMZ_PLUGIN--fzf
  $_OMZ_PLUGIN--git
  $_OMZ_PLUGIN--pip
  $_OMZ_PLUGIN--sudo
  $_OMZ_PLUGIN--thefuck
  $_OMZ_PLUGIN--urltools
  $_OMZ_PLUGIN--tmux
  $_OMZ_PLUGIN--tmuxinator
)
if [[ -e $_OMZ_PLUGIN--autojump ]]; then
  rm -rfv $_OMZ_PLUGIN_LIST
fi

##-------------------------Theme Set
## Load the theme.
zplugin light romkatv/powerlevel10k

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
