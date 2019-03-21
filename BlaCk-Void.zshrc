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

##-------------------------Custom set-------------------------
source /etc/zsh_command_not_found
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

##-------------------------Antigen set-------------------------
source $BVZSH/antigen.zsh

## Load the oh-my-zsh's library.
antigen use oh-my-zsh

## Bundles from the default repo.
antigen bundle autojump
antigen bundle command-not-found
antigen bundle fzf
antigen bundle git
antigen bundle pip
antigen bundle sudo
antigen bundle thefuck
antigen bundle tmux
antigen bundle tmuxinator
antigen bundle urltools

## Bundles form the custom repo.
antigen bundle chrissicool/zsh-256color
antigen bundle djui/alias-tips
antigen bundle mafredri/zsh-async
#antigen bundle hchbaw/auto-fu.zsh ##crash with fzf..
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle hlissner/zsh-autopair
antigen bundle unixorn/autoupdate-antigen.zshplugin
antigen bundle zsh-users/zsh-completions
antigen bundle b4b4r07/enhancd
antigen bundle zdharma/fast-syntax-highlighting
antigen bundle wfxr/forgit
antigen bundle ytet5uy4/fzf-widgets
antigen bundle seletskiy/zsh-git-smart-commands
antigen bundle smallhadroncollider/antigen-git-store
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle changyuheng/zsh-interactive-cd
#antigen bundle zsh-users/zsh-syntax-highlighting ##fast-syntax-highlighting is better!!
antigen bundle peterhurford/up.zsh
antigen bundle jocelynmallon/zshmarks

## Load the theme.
_theme-powerline()
{
    source /usr/share/powerline/bindings/zsh/powerline.zsh
    antigen theme romkatv/powerlevel10k
    #POWERLEVEL9K_MODE='nerdfont-complete' ##Now I USE Custom Icon Setting

    export BVZSH_THEME='powerline'
}
_theme-simple()
{
    prompt_powerlevel9k_teardown
    antigen bundle mafredri/zsh-async
    antigen bundle sindresorhus/pure
    autoload -U promptinit; promptinit

    ##PROMPT
    PURE_CMD_MAX_EXEC_TIME=2
    PROMPT='%}%(?.%F{171}.%F{160}${prompt_pure_state[prompt]}%F{171})${prompt_pure_state[prompt]}%f '
    ##RPROMPT
    RPROMPT='%(1j.[%j] .)% ${(j.|.)pipestatus}'

    prompt_pure_setup "$@"

    export BVZSH_THEME='simple'
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

#-----fzf-widgets
# Map widgets to key
bindkey '^@'  fzf-select-widget
bindkey '^@.' fzf-edit-dotfiles
bindkey '^@c' fzf-change-directory
bindkey '^@n' fzf-change-named-directory
bindkey '^@f' fzf-edit-files
bindkey '^@k' fzf-kill-processes
bindkey '^@s' fzf-exec-ssh
bindkey '^\'  fzf-change-recent-directory
bindkey '^r'  fzf-insert-history
bindkey '^xf' fzf-insert-files
bindkey '^xd' fzf-insert-directory
bindkey '^xn' fzf-insert-named-directory

## Git
bindkey '^@g'  fzf-select-git-widget
bindkey '^@ga' fzf-git-add-files
bindkey '^@gc' fzf-git-change-repository

# GitHub
bindkey '^@h'  fzf-select-github-widget
bindkey '^@hs' fzf-github-show-issue
bindkey '^@hc' fzf-github-close-issue

## Docker
bindkey '^@d'  fzf-select-docker-widget
bindkey '^@dc' fzf-docker-remove-containers
bindkey '^@di' fzf-docker-remove-images
bindkey '^@dv' fzf-docker-remove-volumes

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

##-------------------------PowerLevel9k Set-------------------------
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
POWERLEVEL9K_ANDROID_ICON=$'\uF17B '              #   or  '\uE70E'  
POWERLEVEL9K_APPLE_ICON=$'\uF179 '                # 
POWERLEVEL9K_AWS_ICON=$'\uF1B3 '                  #  or  '\uF270 ' 
POWERLEVEL9K_AWS_EB_ICON=$'\uF1BD  '              #   or  '\uE7AD'  
POWERLEVEL9K_BACKGROUND_JOBS_ICON=$'\uF013 '      # 
POWERLEVEL9K_BATTERY_ICON=$'\uF241 '              #  or  '\uF240 ' 
POWERLEVEL9K_CARRIAGE_RETURN_ICON=$'\u21B5'       # ↵
POWERLEVEL9K_DATE_ICON=$'\uF073 '                 # 
POWERLEVEL9K_DISK_ICON=$'\uF0A0 '                 # 
POWERLEVEL9K_DROPBOX_ICON=$'\UF16B'               # 
#POWERLEVEL9K_ETC_ICON=$'\uF013'                   # 
POWERLEVEL9K_EXECUTION_TIME_ICON="Due"            #    or  '\uF252 ' 
POWERLEVEL9K_FAIL_ICON=$'\u2718'                  # ✘  or  '\uF00D' 
#POWERLEVEL9K_FOLDER_ICON=$'\uF07B '               #   or  '\uF115' 
POWERLEVEL9K_FREEBSD_ICON=$'\uF30C '              # 
POWERLEVEL9K_GO_ICON=$'\uE724'                    #  or  '\uE626' 
#POWERLEVEL9K_HOME_ICON=$'\uF015'                  # 
#POWERLEVEL9K_HOME_SUB_ICON=$'\uF07C'              # 
POWERLEVEL9K_JAVA_ICON=$'\U2615'                  # ☕︎
POWERLEVEL9K_KUBERNETES_ICON=$'\U2388'            # ⎈
POWERLEVEL9K_LARAVEL_ICON=$'\uE73f '              # 
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\uE0B0'     # 
POWERLEVEL9K_LEFT_SEGMENT_END_SEPARATOR=' '       #   or   '\uF105'  or '\uF12D' 
POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$' \uE0B1' # 
POWERLEVEL9K_LINUX_ICON=$'\uF17C '                # 
POWERLEVEL9K_LINUX_ARCH_ICON=$'\uF303'            # 
POWERLEVEL9K_LINUX_CENTOS_ICON=$'\uF304'          # 
POWERLEVEL9K_LINUX_COREOS_ICON=$'\uF305'          # 
POWERLEVEL9K_LINUX_DEBIAN_ICON=$'\uF306'          # 
POWERLEVEL9K_LINUX_ELEMENTARY_ICON=$'\uF309'      # 
POWERLEVEL9K_LINUX_FEDORA_ICON=$'\uF30A'          # 
POWERLEVEL9K_LINUX_GENTOO_ICON=$'\uF30D'          # 
POWERLEVEL9K_LINUX_MAGEIA_ICON=$'\uF310'          # 
POWERLEVEL9K_LINUX_MINT_ICON=$'\uF30E'            # 
POWERLEVEL9K_LINUX_NIXOS_ICON=$'\uF313'           # 
POWERLEVEL9K_LINUX_MANJARO_ICON=$'\uF312'         # 
POWERLEVEL9K_LINUX_DEVUAN_ICON=$'\uF307'          # 
POWERLEVEL9K_LINUX_ALPINE_ICON=$'\uF300'          # 
POWERLEVEL9K_LINUX_AOSC_ICON=$'\uF301'            # 
POWERLEVEL9K_LINUX_OPENSUSE_ICON=$'\uF314'        # 
POWERLEVEL9K_LINUX_SABAYON_ICON=$'\uF317'         # 
POWERLEVEL9K_LINUX_SLACKWARE_ICON=$'\uF319'       # 
POWERLEVEL9K_LINUX_UBUNTU_ICON=$'\uF31B'          # 
POWERLEVEL9K_LOAD_ICON=$'\uF524'                  #  or L           or $'\uF140 '  or '\uF080 ' 
POWERLEVEL9K_LOCK_ICON=$'\uF023'                  #  or '\uE0A2' 
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="↱"    #   or '\u256D'$'\U2500' ╭─
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="↳ "    #   or '\u251C'$'\U2500' ├─ or '\u2570'$'\U2500 '  ╰─
POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='\u251C'$'\U2500' # ├─
POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX='\u251C'$'\U2500'  # ├─
POWERLEVEL9K_NETWORK_ICON=$'\uF012 '              #  or $'\uF1fe '  or '\uF1EB' 
POWERLEVEL9K_NODE_ICON='\uE617 '                  #  or'\uE24F' ⬢
POWERLEVEL9K_OK_ICON=$'\u2714'                    # ✔ or $'\uF00c ' 
POWERLEVEL9K_PUBLIC_IP_ICON=$'\uF080 '            #  or $'\uF469'  or '\UF0AC' 
POWERLEVEL9K_PYTHON_ICON=$'\uF81F'                #  or '\uE73C ' # 
POWERLEVEL9K_RAM_ICON=$'\uF2db '                  #  or $'\uF0e4 ' 
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\uE0B2'    # 
POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$'\uE0B3' # 
POWERLEVEL9K_ROOT_ICON="\uF0e7 Root"              #   or \uF292   or '\uE614 ' 
POWERLEVEL9K_RUBY_ICON=$'\uF219 '                 #  or '\uE791'  or $'\uE739' 
POWERLEVEL9K_RUST_ICON=$'\uE7a8'                  # 
POWERLEVEL9K_SERVER_ICON=$'\uF233 '               #  or '\uF473'  or '\uF0AE ' 
POWERLEVEL9K_SSH_ICON="(ssh)"                     #    or 'uf120'  or '\uE795'  or '\uF489'  # 
POWERLEVEL9K_SUDO_ICON=$'\uF09C'                  # 
POWERLEVEL9K_SUNOS_ICON=$'\uF185 '                # 
POWERLEVEL9K_SWAP_ICON=$'\uF464'                  #  or '\uF0C7 '  or '\uF109 ' 
POWERLEVEL9K_SWIFT_ICON=$'\uE755'                 # 
POWERLEVEL9K_SYMFONY_ICON=$'\uE757'               # 
POWERLEVEL9K_TEST_ICON=$'\uE29A '                 #  or '\uF188' 
POWERLEVEL9K_TIME_ICON=$'\uF017 '                 # 
POWERLEVEL9K_TODO_ICON=$'\uF046 '                 #  or '\uF133' 
POWERLEVEL9K_VCS_BOOKMARK_ICON=$'\uF461 '         #  or '\uF02E'  or '\uF097'  or '\uF08D'  or $'\uF223'  or ☿
POWERLEVEL9K_VCS_BRANCH_ICON=$'\uF126 '           #  or '\uE702'  or 
POWERLEVEL9K_VCS_COMMIT_ICON='\uE729'             #  or "-o-"
POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON=$'\uF171 '    #  or '\uF172 '  or '\uE703' 
POWERLEVEL9K_VCS_GIT_GITHUB_ICON=$'\uF113 '       #  or '\uF09B '  or '\uF092 ' 
POWERLEVEL9K_VCS_GIT_GITLAB_ICON=$'\uF296 '       # 
POWERLEVEL9K_VCS_GIT_ICON=$'\uF1D3 '              #  or '\uF1D2' 
POWERLEVEL9K_VCS_HG_ICON=$'\uF223 '               #  or 
POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=$'\uF063'  #  or '\uF01a'  or '\uF0AB'  or '\ud727'  or '\u2193' ↓
POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=$'\uF062'  #  or '\uF01b'  or '\uF0AA'  or '\uE726'  or '\u2191' ↑
POWERLEVEL9K_VCS_REMOTE_BRANCH_ICON=$'\uF061 '    #  or '\uF18e'  or '\uF0A9'  or '\uE725'  or → or '\uE728 ' 
POWERLEVEL9K_VCS_STAGED_ICON=$'\uF067'            # ✚ or '\uF055'  or '\uF0FE' 
POWERLEVEL9K_VCS_STASH_ICON=$'\uF01C'             #  or '\uF192'  or ⍟
POWERLEVEL9K_VCS_SVN_ICON=$'\uE72D '              #  or'\uE268' 
POWERLEVEL9K_VCS_TAG_ICON=$'\uF02c '              #  or '\uF02B ' 
POWERLEVEL9K_VCS_UNSTAGED_ICON=$'\u25CF'          # ● or '\uF111'  or '\uF06A'  or '\uF12A'  or '\uF071' 
POWERLEVEL9K_VCS_UNTRACKED_ICON=$'\uF128'         #  or '\uF059'  '\uF29C'  or '\u00B1' ?
POWERLEVEL9K_VPN_ICON="(vpn)"
POWERLEVEL9K_WINDOWS_ICON=$'\uF17a '              #  or '\uF17A' 

##-----Color Set
#for code ({000..255}) print -P -- "$code: %F{$code}This is how your text would look like%f"
#getColorCode background
#getColorCode foreground

POWERLEVEL9K_ROOT_INDICATOR_BACKGROUND='226'          #yellow
POWERLEVEL9K_ROOT_INDICATOR_FOREGROUND='000'          #alpha
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='039'             #blue
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='000'             #alpha
POWERLEVEL9K_DIR_HOME_BACKGROUND='039'                #blue
POWERLEVEL9K_DIR_HOME_FOREGROUND='000'                #alpha
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='039'      #blue
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='000'      #alpha
POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_BACKGROUND='160'  #red
POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_FOREGROUND='226'  #yellow
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='000'               #alpha
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='040'               #green or'165' #purple
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='000'           #alpha
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='040'           #green
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='000'            #alpha
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='208'            #orange
#POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND='teal'

POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='000'         #alpha
POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND='226'         #yellow
POWERLEVEL9K_STATUS_OK_BACKGROUND='000'               #alpha
POWERLEVEL9K_STATUS_OK_FOREGROUND='040'               #green
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='160'            #red
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='226'            #yellow
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='160'  #red
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='226'  #yellow
POWERLEVEL9K_HISTORY_BACKGROUND='244'                 #gray
POWERLEVEL9K_HISTORY_FOREGROUND='000'                 #alpha
POWERLEVEL9K_LOAD_CRITICAL_BACKGROUND='160'           #red
POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND='226'           #yellow
POWERLEVEL9K_LOAD_WARNING_BACKGROUND='226'            #yellow
POWERLEVEL9K_LOAD_WARNING_FOREGROUND='000'            #alpha
POWERLEVEL9K_LOAD_NORMAL_BACKGROUND='040'             #green
POWERLEVEL9K_LOAD_NORMAL_FOREGROUND='000'             #alpha

##-----Others Set
## Command-Execution-time set
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2

#POWERLEVEL9K_CHANGESET_HASH_LENGTH=6
#POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=5
#POWERLEVEL9K_TIME_FORMAT="%D{%H:%M  \uE868  %d.%m.%y}"

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

    echo "\n--------------------"
    echo "Plugins update"
    antigen selfupdate
    antigen update
    rm ~/.antigen_system_lastupdate ~/.antigen_plugin_lastupdate
    cd $BVZSH/hhighlighter && git pull
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
