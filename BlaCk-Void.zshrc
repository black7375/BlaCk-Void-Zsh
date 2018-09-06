export TERM="xterm-256color"
export BVZSH=$( cd "$(dirname "$0")" ; pwd )
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

##-------------------------Custom set
source /etc/zsh_command_not_found
alias tar-compress-gz='tar -zcvf'
alias tar-extract-gz='tar -zxvf'
setopt nonomatch
setopt interactive_comments
setopt correct
setopt noclobber
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt HIST_SAVE_NO_DUPS

[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && source $HOME/.autojump/etc/profile.d/autojump.sh
source /usr/share/autojump/autojump.zsh

#. /usr/share/powerline/bindings/zsh/powerline.zsh

if [ -d "$HOME/.cargo/bin" ] ; then
  export PATH="$PATH:$HOME/.cargo/bin"
  alias exa-grid='exa --long --grid'
  alias exa-tree='exa --long --tree'
fi

if [ -d "$HOME/.local/bin" ] ; then
  export PATH="$PATH:$HOME/.local/bin"
fi

if [ -d "/home/linuxbrew/.linuxbrew/bin" ] ; then
  export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
fi

if [ -d "/snap/bin" ] ; then
  export PATH="$PATH:/snap/bin"
fi

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
alias url-short='curl -s http://tinyurl.com/api-create.php?url='
alias prettyping='$BVZSH/prettyping'

ip-info()
{
    ip-address=$1
    while [ "$#" -gt 0 ];
    do
      case $1 in
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
    curl ipinfo.io/$1
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

##-------------------------Antigen set
source $BVZSH/antigen.zsh

## Load the oh-my-zsh's library.
antigen use oh-my-zsh

## Bundles from the default repo.
antigen bundle autojump
antigen bundle command-not-found
antigen bundle git
antigen bundle lein
antigen bundle pip
antigen bundle sudo
antigen bundle thefuck
antigen bundle tmux
antigen bundle tmuxinator
antigen bundle urltools
antigen bundle z

## Bundles form the custom repo.
antigen bundle chrissicool/zsh-256color
antigen bundle djui/alias-tips
#antigen bundle hchbaw/auto-fu.zsh ##crash with fzf..
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle hlissner/zsh-autopair
antigen bundle unixorn/autoupdate-antigen.zshplugin
antigen bundle zsh-users/zsh-completions
antigen bundle b4b4r07/enhancd
antigen bundle zdharma/fast-syntax-highlighting
antigen bundle wfxr/forgit
antigen bundle ytet5uy4/fzf-widgets
antigen bundle andrewferrier/fzf-z
antigen bundle seletskiy/zsh-git-smart-commands
antigen bundle smallhadroncollider/antigen-git-store
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle changyuheng/zsh-interactive-cd
#antigen bundle zsh-users/zsh-syntax-highlighting ##fast-syntax-highlighting is better!!
antigen bundle supercrabtree/k
antigen bundle peterhurford/up.zsh
antigen bundle jocelynmallon/zshmarks

POWERLEVEL9K_INSTALLATION_PATH=$ANTIGEN_BUNDLES/bhilburn/powerlevel9k

## Load the theme.
antigen theme bhilburn/powerlevel9k powerlevel9k
#POWERLEVEL9K_MODE='nerdfont-complete' ##Now I USE Custom Icon Setting

## Tell Antigen that you're done.
antigen apply

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

##-------------------------PowerLevel9k Set
##-----Prompt Set
## System Status Segments
#background_jobs battery context dir dir_writable disk_usage history host ip vpn_ip public_ip load os_icon ram root_indicator status swap time user vi_mode ssh

## Development Environment Segments
#vcs

## Language Segments
#GO: go_version
#Javascript: node_version nodeenv nvm
#PHP: php_version symfony2tests symfony2_version
#Python: virtualenv anaconda pyenv
#Ruby: chruby rbenv rspec_stats rvm
#Rust: rust_version
#Swift: swift_version

## Cloud Segments
#AWS: aws aws_en_env
#Other: docker_machine kubecontext

## Other Segments
#custom_commmand command_execution_time todo detect_virt newline

## Prompt
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ssh context root_indicator dir dir_writable vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs command_execution_time history load)

## Double-Lined Prompt
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
#POWERLEVEL9K_RPROMPT_ON_NEWLINE=true

##-----Icon Set
#get_icon_names

POWERLEVEL9K_ANDROID_ICON=$'\uf17b ' # or '\ue70e' 
POWERLEVEL9K_APPLE_ICON=$'\uf179 ' #
POWERLEVEL9K_AWS_EB_ICON=$'\uf270 ' # or 
POWERLEVEL9K_AWS_ICON=$'\uf1b3 ' # or $'\ue7ad' 
POWERLEVEL9K_BACKGROUND_JOBS_ICON=$'\uf013 ' #
POWERLEVEL9K_BATTERY_ICON=$'\uf241 ' # or $'\uf240 ' 
POWERLEVEL9K_CARRIAGE_RETURN_ICON=$'\u21b5' # ↵
POWERLEVEL9K_DISK_ICON=$'\uf0a0 ' #
POWERLEVEL9K_EXECUTION_TIME_ICON="Due" #or $'\uf252 ' 
POWERLEVEL9K_FAIL_ICON='\u2718' #✘
#POWERLEVEL9K_FOLDER_ICON=$'\uf07b ' #
POWERLEVEL9K_FREEBSD_ICON="BSD" #or 
#POWERLEVEL9K_GO_ICON=$'\ue724' # or $'\ue626' 
#POWERLEVEL9K_HOME_ICON=$'\uf015 ' #
#POWERLEVEL9K_HOME_SUB_ICON=$'\uf07c ' #
#POWERLEVEL9K_LEFT_SEGMENT_END_SEPARATOR=$'\uf105' # or $'\uf12d' 
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\ue0b0' # 
POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$'\ue0b1' # 
POWERLEVEL9K_LINUX_ICON=$'\uf17c ' #
POWERLEVEL9K_LOAD_ICON=$'\uf524' # or L or $'\uf140 ' 
POWERLEVEL9K_LOCK_ICON=$'\ue0a2' #
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="↱"
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="↳ "
POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX='├─'
POWERLEVEL9K_NETWORK_ICON=$'\uf012 ' # or $'\uf1fe ' 
POWERLEVEL9K_NODE_ICON=$'\ue24f' # ⬢
POWERLEVEL9K_OK_ICON=$'\u2714' #✔ or $'\uf00c ' 
POWERLEVEL9K_PUBLIC_IP_ICON=$'\uf080 ' # or $'\uf469'  or 
POWERLEVEL9K_PYTHON_ICON=$'\uf81f' #
POWERLEVEL9K_RAM_ICON=$'\uf2db ' # or $'\uf0e4 ' 
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\ue0b2' #
POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$'\ue0b3' #
POWERLEVEL9K_ROOT_ICON="\uf0e7 Root" # or \uf292 
POWERLEVEL9K_RUBY_ICON=$'\ue791' # or $'\ue739' 
POWERLEVEL9K_RUST_ICON=$'\ue7a8' #
POWERLEVEL9K_SERVER_ICON=$'\uf233 ' # or $'\uf473' 
POWERLEVEL9K_SSH_ICON="(ssh)" #$uf120'  or $'\ue795' 
POWERLEVEL9K_SUNOS_ICON=$'\uf185 ' #
POWERLEVEL9K_SWAP_ICON=$'\uf0c7 ' # or $'\uf109 ' 
POWERLEVEL9K_SWIFT_ICON=$'\ue755' #
#POWERLEVEL9K_SYMFONY_ICON=$'\ue757' #
POWERLEVEL9K_TEST_ICON=$'\ue29a ' #
POWERLEVEL9K_TODO_ICON=$'\uf046 ' #
POWERLEVEL9K_VCS_BOOKMARK_ICON=$'\uf02e' # or $'\uf097'  or $'\uf08d'  or $'\uf223'  or ☿
POWERLEVEL9K_VCS_BRANCH_ICON=$'\uf126 ' # or $'\ue702'  or 
POWERLEVEL9K_VCS_COMMIT_ICON="-o-" # or $'\ue729' 
POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON=$'\uf171 ' # or $'\uf172 '  or $'\ue703' 
POWERLEVEL9K_VCS_GIT_GITHUB_ICON=$'\uf113 ' # or $'\uf09b '  or $'\uf092 ' 
POWERLEVEL9K_VCS_GIT_GITLAB_ICON=$'\uf296 ' #
POWERLEVEL9K_VCS_GIT_ICON=$'\uf1d3 ' # or $'\uf1d2' 
POWERLEVEL9K_VCS_HG_ICON=$'\uf223 ' # or 
POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=$'\uf063' # or $'\uf01a'  or $'\uf0ab'  or $'\ud727'  or $'\u2193' ↓
POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=$'\uf062' # or $'\uf01b'  or $'\uf0aa'  or $'\ue726'  or $'\u2191' ↑
POWERLEVEL9K_VCS_REMOTE_BRANCH_ICON=$'\uf061' # or $'\uf18e'  or $'\uf0a9'   or $'\ue725'  or →
POWERLEVEL9K_VCS_STAGED_ICON=$'\uf067' #✚ or $'\uf055'  or $'\uf0fe' 
POWERLEVEL9K_VCS_STASH_ICON=$'\uf01c' # or $'\uf192'  or ⍟
POWERLEVEL9K_VCS_SVN_ICON="SVN" #$'\ue268'  or 
POWERLEVEL9K_VCS_TAG_ICON=$'\uf02c ' #
POWERLEVEL9K_VCS_UNSTAGED_ICON=$'\uf111 ' # or $'\uf06a'  or $'\uf12a'  or $'\uf071'  or '\u25CF' ●
POWERLEVEL9K_VCS_UNTRACKED_ICON=$'\uf128 ' # or $'\uf059'  $'\uf29c'  or $'\u00b1' ?
POWERLEVEL9K_VPN_ICON="(vpn)"
POWERLEVEL9K_WINDOWS_ICON=$'\uf17a ' #

##-----Color Set
#for code ({000..255}) print -P -- "$code: %F{$code}This is how your text would look like%f"
#getColorCode background
#getColorCode foreground

POWERLEVEL9K_ROOT_INDICATOR_BACKGROUND='226' #yellow
POWERLEVEL9K_ROOT_INDICATOR_FOREGROUND='000' #alpha
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='039' #blue
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='000' #alpha
POWERLEVEL9K_DIR_HOME_BACKGROUND='039' ##blue
POWERLEVEL9K_DIR_HOME_FOREGROUND='000' #alpha
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='039' #blue
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='000' #alpha
POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_BACKGROUND='196' #red
POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_FOREGROUND='226' #yellow
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='000' #alpha
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='040' #green or'165' #purple
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='000' #alpha
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='040' #green
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='000' #alpha
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='208' #orange
#POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND='teal'

POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='000'  #alpha
POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND='226' #yellow
POWERLEVEL9K_STATUS_OK_BACKGROUND='000' #alpha
POWERLEVEL9K_STATUS_OK_FOREGROUND='040' #green
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='196' #red
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='226' #yellow
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='196'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='226' #yellow
POWERLEVEL9K_HISTORY_BACKGROUND='244' #gray
POWERLEVEL9K_HISTORY_FOREGROUND='000' #alpha
POWERLEVEL9K_LOAD_CRITICAL_BACKGROUND='196' #red
POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND='226' #yellow
POWERLEVEL9K_LOAD_WARNING_BACKGROUND='226' #yellow
POWERLEVEL9K_LOAD_WARNING_FOREGROUND='000' #alpha
POWERLEVEL9K_LOAD_NORMAL_BACKGROUND='040' #green
POWERLEVEL9K_LOAD_NORMAL_FOREGROUND='000' #alpha

##-----Others Set
## Command-Execution-time set
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2

#POWERLEVEL9K_CHANGESET_HASH_LENGTH=6
#POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=5
#POWERLEVEL9K_TIME_FORMAT="%D{%H:%M  \uE868  %d.%m.%y}"

##-------------------------Other System Configs
zsh-update()
{
    echo "--------------------"
    echo "  BlaCk-Zsh Update"
    echo "--------------------\n"

    echo "\n--------------------"
    echo "Setting files update"
    cd $BVZSH && git pull

    echo "\n--------------------"
    echo "Plugins update"
    cd $BVZSH/hhighlighter && git pull
    antigen selfupdate
    antigen update
    rm ~/.antigen_system_lastupdate ~/.antigen_plugin_lastupdate

    echo "\n--------------------"
    echo "Fonts update"
    cd $BVZSH/nerd-fonts && git pull && sudo ./install.sh
}
