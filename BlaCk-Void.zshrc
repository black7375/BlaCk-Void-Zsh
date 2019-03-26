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
setopt HIST_SAVE_NO_DUPS

[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && source $HOME/.autojump/etc/profile.d/autojump.sh

#Histoy
history-clear()
{
    mv ~/.zsh_histoy ~/.zsh_histoy.bak
}
history-restore()
{
    mv ~/.zsh_histoy.bak ~/.zsh_histoy
}

#Alias
alias tar-compress-gz='tar -zcvf'
alias tar-extract-gz='tar -zxvf'
alias map='telnet mapscii.me'
alias prettyping='$BVZSH/prettyping'

#URL Short
url-short()
{
    curl -s http://tinyurl.com/api-create.php?url\=$1
}

#IP Info
ip-info()
{
    ip_address=$1
    while [ "$#" -gt 0 ];
    do
      case $ip_address in
        -h* | --help*)
        echo "Command: ip-info IP_ADDRESS\n"
        echo "Default: your ip address"
        echo "Option -s or --simple"
        echo "==>Print only Your address"
        return
        ;;

        -s* | --simple*)
        curl ipinfo.io/ip
        return
        ;;

        *)
        shift
        ;;
      esac
    done

    # change Paris to your default location
    curl ipinfo.io/$ip_address
}

#Weather
weather()
{
    locale=$1
    lang=${2:-${LANG%_*}}
    while [ "$#" -gt 0 ];
    do
      case $1 in
        -h* | --help*)
        echo "-------------------------"
        echo "    Terminal Weather"
        echo "-------------------------\n"
        echo "Command: weather"
        echo "or"
        echo "Command: weather LOCALE LANGUAGE(option)\n"
        echo "Default LANGUAGE: SYSYEM_LANGUAGE"
        echo "-------------------------\n"
        curl wttr.in/:help
        return
        ;;

        *)
        shift
        ;;
      esac
    done

    # change Paris to your default location
    curl -H "Accept-Language: $lang" wttr.in/$locale
}

#Terminal image viewer based @z3bra
img()
{
    echo "-------------------------"
    echo "  Terminal Image Viewer"
    echo "-------------------------\n"
    echo "Default: show during 2s."
    echo "command: img IMAGE_NAME SHOW_TIME"

    WARNING="\n**Warning!!**"
    NONEXIST="File $1 does not exist.\n"

    if [ ! -f "$1" ] || [ -z "$1"  ]
    then
        echo $WARNING
        echo $NONEXIST
        return 1
    fi

    W3MIMGDISPLAY="/usr/lib/w3m/w3mimgdisplay"
    FILENAME=$1
    FONTH=15 #15 # Size of one terminal row
    FONTW=8 #8  # Size of one terminal column
    COLUMNS=`tput cols`
    LINES=`tput lines`

    if [ ! -f "$W3MIMGDISPLAY" ]
    then
        echo "\nRequire 'w3m-img' !!"
        return 1
    fi

    read width height <<< `echo -e "5;$FILENAME" | $W3MIMGDISPLAY`

    max_width=$(($FONTW * $COLUMNS))
    max_height=$(($FONTH * $(($LINES - 2)))) # substract one line for prompt

    if test $width -gt $max_width
    then
        height=$(($height * $max_width / $width))
        width=$max_width
    fi
    if test $height -gt $max_height
    then
        width=$(($width * $max_height / $height))
        height=$max_height
    fi
    erase="6;1;0;$(( FONTW*COLUMNS ));$(( FONTH*LINES ))\n3;"
    w3m_command="0;1;0;0;$width;$height;;;;;$FILENAME\n4;\n3;"

    tput cup $(($height/$FONTH)) 0
    echo -e $erase | $W3MIMGDISPLAY
    echo -e $w3m_command|$W3MIMGDISPLAY

    if [ -n "$2"  ]
    then
        sleep $2
    else
        sleep 2
    fi
}

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

##-------------------------Hhighlighter set
source $BVZSH/hhighlighter/h.sh

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

##----- Bundles from the oh-my-zsh.
OMZ='https://github.com/robbyrussell/oh-my-zsh/tree/master'
zplugin snippet $OMZ/lib/compfix.zsh
zplugin snippet $OMZ/lib/termsupport.zsh
zplugin snippet $OMZ/plugins/autojump/autojump.plugin.zsh
zplugin snippet $OMZ/plugins/command-not-found/command-not-found.plugin.zsh
zplugin snippet $OMZ/plugins/fzf/fzf.plugin.zsh
zplugin snippet $OMZ/plugins/git/git.plugin.zsh
zplugin snippet $OMZ/plugins/pip/pip.plugin.zsh
zplugin snippet $OMZ/plugins/sudo/sudo.plugin.zsh
zplugin snippet $OMZ/plugins/thefuck/thefuck.plugin.zsh
zplugin snippet $OMZ/plugins/tmux/tmux.plugin.zsh
zplugin snippet $OMZ/plugins/tmuxinator/tmuxinator.plugin.zsh
zplugin snippet $OMZ/plugins/urltools/urltools.plugin.zsh

##----- Bundles form the custom repo.
zplugin light chrissicool/zsh-256color
zplugin light mafredri/zsh-async
#zplugin light hchbaw/auto-fu.zsh ##crash with fzf..
zplugin light zsh-users/zsh-autosuggestions
zplugin light hlissner/zsh-autopair
zplugin light zsh-users/zsh-completions
zplugin light zdharma/fast-syntax-highlighting

zplugin light djui/alias-tips
zplugin light b4b4r07/enhancd
zplugin light wfxr/forgit
zplugin light ytet5uy4/fzf-widgets
zplugin light seletskiy/zsh-git-smart-commands
zplugin light zsh-users/zsh-history-substring-search
zplugin light changyuheng/zsh-interactive-cd
zplugin light peterhurford/up.zsh
zplugin light jocelynmallon/zshmarks
zplugin ice pick"h.sh" lucid
zplugin light paoloantinori/hhighlighter
if [[ -e $BVZSH/hhighlighter ]]; then
  rm -rfv $BVZSH/hhighlighter
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

_theme-powerline()
{
    export BVZSH_THEME='powerline'
    if [ -x "$(command -v powerline)" ] &&
       ! [ "$(zplugin loaded powerline-binding | rg black7375 |
          sed -E "s/[[:cntrl:]]\[[0-9]{1,3}m//g")" = "black7375/powerline-binding *" ] ; then
      zplugin light black7375/powerline-binding
    fi
    _powerline-nerd
}
_theme-simple()
{
    export BVZSH_THEME='simple'
    _simple-nerd
}
_theme-auto()
{
    case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
        export TERM="xterm-256color"
        if [ $(tput colors) -ge "256" ]; then
            _theme-powerline
        else
            _theme-simple
        fi
    ;;
    *)
        _theme-simple
    ;;
    esac

    export BVZSH_THEME='auto'
}

zsh-theme()
{
    local theme_set=$1
    case $theme_set in
    -h* | --help*)
        echo "--------------------"
        echo "  BlaCk-Zsh Theme"
        echo "--------------------\n"
        echo "Command: zsh-theme THEME_NAME\n"
        echo "Default: auto"
        echo "Options: auto powerline simple"
        return
    ;;

    'auto')
        _theme-auto
    ;;

    'powerline')
        _theme-powerline
    ;;

    'simple')
        _theme-simple
    ;;

    *)
        echo "This theme is not available."
        return 1
    ;;
    esac
}

if [ -z "$BVZSH_THEME" ] ; then
    export BVZSH_THEME='auto'
fi
zsh-theme $BVZSH_THEME

##-------------------------Plugin Set
#-----thefuck
eval "$(thefuck --alias)"

#-----Tmuxinator
tmux set-window-option -g pane-base-index 1

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

##-------------------------Other System Configs-------------------------
zsh-help()
{
    echo "--------------------"
    echo "  BlaCk-Zsh Help"
    echo "--------------------\n"
    echo "command: zsh-update -> zsh update"
    echo "command: font-update -> NerdFont update"
}
zsh-update()
{
    echo "--------------------"
    echo "  BlaCk-Zsh Update"
    echo "--------------------\n"

    echo "\n--------------------"
    echo "Setting files update"
    cd $BVZSH && git pull
    zcompile $BVZSH/BlaCk-Void.zshrc
    zcompile $BVZSH/BlaCk-Void.ztheme
    zcompile $BVZSH/fzf-set.zsh
    zcompile $BVZSH/completion.zsh

    echo "\n--------------------"
    echo "Plugins update"
    zplugin self-update
    zplugin update
    git pull $BVZSH/hhighlighter
}
font-update()
{
    echo "\n--------------------"
    echo "Fonts update"
    if [ -d "$BVZSH/nerd-fonts" ]
    then
        echo "Nerd Fonts is not installed.\n"
        while true; do
            read -p "Do you Install Nerd Fonts? [Y/N]" ans
            case $ans in
                [Yy]*)
                    source $BVZSH/install_font.sh
                    return
                    ;;
                [Nn]*)
                    echo "Don't Install Fonts."
                    return
            esac
            echo "Please answer again."
        done
    fi

    cd $BVZSH/nerd-fonts && git pull && ./install.sh
}
