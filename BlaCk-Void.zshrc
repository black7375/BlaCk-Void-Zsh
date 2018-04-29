export TERM="xterm-256color"
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
alias tar_compress_gz='tar -zcvf'
alias tar_extract_gz='tar -zxvf'
setopt nonomatch
eval "$(thefuck --alias)"

[[ -s /home/black_void/.autojump/etc/profile.d/autojump.sh ]] && source /home/black_void/.autojump/etc/profile.d/autojump.sh
source /usr/share/autojump/autojump.zsh

. /usr/share/powerline/bindings/zsh/powerline.zsh

function fzf-view()
{
    fzf --preview '[[ $(file --mime {}) =~ binary ]] &&
                 echo {} is a binary file ||
                 (highlight -O ansi -l {} ||
                  coderay {} ||
                  rougify {} ||
                  cat {}) 2> /dev/null | head -500'
}
function fzf-file()
{
    fzf --height 40% --reverse --preview 'file {}' --preview-window down:1
}
export FZF_DEFAULT_COMMAND='rg --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_COMMAND='
  (git ls-tree -r --name-only HEAD ||
   find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
      sed s/^..//) 2> /dev/null'

##-------------------------Antigen set
source ~/BlaCk-Void-Zsh/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo.
antigen bundle chrissicool/zsh-256color
antigen bundle djui/alias-tips
#antigen bundle hchbaw/auto-fu.zsh
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle hlissner/zsh-autopair
antigen bundle unixorn/autoupdate-antigen.zshplugin
antigen bundle command-not-found
antigen bundle zsh-users/zsh-completions
antigen bundle b4b4r07/enhancd
antigen bundle zdharma/fast-syntax-highlighting
antigen bundle wfxr/forgit
antigen bundle ytet5uy4/fzf-widgets
antigen bundle git
antigen bundle seletskiy/zsh-git-smart-commands
antigen bundle heroku
antigen bundle supercrabtree/k
antigen bundle lein
antigen bundle pip
#antigen bundle zsh-users/zsh-syntax-highlighting ##fast-syntax-highlighting is better!!

POWERLEVEL9K_INSTALLATION_PATH=$ANTIGEN_BUNDLES/bhilburn/powerlevel9k

# Load the theme.
antigen theme bhilburn/powerlevel9k powerlevel9k

# Tell Antigen that you're done.
antigen apply

##-------------------------Plugin Set
#-----alias-tip
export ZSH_PLUGINS_ALIAS_TIPS_FORCE=0

#-----auto-fu
#zle-line-init () {auto-fu-init;}; zle -N zle-line-init
#zstyle ':completion:*' completer _oldlist _complete
#zle -N zle-keymap-select auto-fu-zle-keymap-select

#-----enhancd
ENHANCD_FILTER=fzy:fzf:peco
export ENHANCD_FILTER

#-----zsh-git-smart-commands
alias c='git-smart-commit'
alias a='git-smart-add'
alias p='git-smart-push seletskiy'
alias u='git-smart-pull'
alias r='git-smart-remote'

##-------------------------PowerLevel9k Set
#-----Basic Set
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(root_indicator context dir dir_writable rbenv vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs command_execution_time history load)

##-----Command-Execution-time set
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2

##-----Double-Lined Prompt
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
#POWERLEVEL9K_RPROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

##-----IconSet
#get_icon_names
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="↱"
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="↳ "
#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
#POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX=" ❯ "

#POWERLEVEL9K_ANDROID_ICON=$'\ue70e'
#POWERLEVEL9K_APPLE_ICON=$'\ue711'
#POWERLEVEL9K_AWS_EB_ICON="🌱"
#POWERLEVEL9K_AWS_ICON=$'\ue7ad'
#POWERLEVEL9K_BACKGROUND_JOBS_ICON=$'\ue615' # ⚙
#POWERLEVEL9K_BATTERY_ICON=$'\uf240'
#POWERLEVEL9K_CARRIAGE_RETURN_ICON=$'\u ' # ↵
#POWERLEVEL9K_DISK_ICON=$'\uf0a0'
POWERLEVEL9K_EXECUTION_TIME_ICON="Due" #$'\uf252' #
POWERLEVEL9K_FAIL_ICON="✘"
#POWERLEVEL9K_FOLDER_ICON=$'\ue5ff'
#POWERLEVEL9K_FREEBSD_ICON=$'\uf30c'
#POWERLEVEL9K_GO_ICON=$'\ue724'
#POWERLEVEL9K_HOME_ICON=$'\ue617'
#POWERLEVEL9K_HOME_SUB_ICON=$'\uf46d'
#POWERLEVEL9K_LEFT_SEGMENT_END_SEPARATOR=$'\uf12d'
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\ue0b0' # 
POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$'\ue0b1' # 
POWERLEVEL9K_LINUX_ICON=$'\ue712'
POWERLEVEL9K_LOAD_ICON=$'\uf524' # L $'\uf140'
POWERLEVEL9K_LOCK_ICON=$'\ue0a2' #""
#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="↱"
#POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX="↳"
#POWERLEVEL9K_NETWORK_ICON=$'\uf012' # $'\uf1fe'
#POWERLEVEL9K_NODE_ICON=$'\ue24f' # ⬢
POWERLEVEL9K_OK_ICON="✔" # $'\uf100c'
#POWERLEVEL9K_PUBLIC_IP_ICON=$'\uf469'
#POWERLEVEL9K_PYTHON_ICON=$'\ue606'
#POWERLEVEL9K_RAM_ICON=$'\uf2db' # $'\uf0e4'
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\ue0b2' #
POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$'\ue0b3' #
#POWERLEVEL9K_ROOT_ICON=$'\uf0e7' # ⚡
#POWERLEVEL9K_RUBY_ICON=$'\ue34e'
#POWERLEVEL9K_RUST_ICON=$'\ue7a8'
#POWERLEVEL9K_SERVER_ICON=$'\uf473'
#POWERLEVEL9K_SSH_ICON=$'\ue795' # (ssh)
#POWERLEVEL9K_SUNOS_ICON="Sun"
#POWERLEVEL9K_SWAP_ICON=$'\ue206'
#POWERLEVEL9K_SWIFT_ICON=$'\ue755'
#POWERLEVEL9K_SYMFONY_ICON=$'\ue757'
#POWERLEVEL9K_TEST_ICON=$'\ue29a'
#POWERLEVEL9K_TODO_ICON=$'\uf046' # ☑
#POWERLEVEL9K_VCS_BOOKMARK_ICON= # ☿
#POWERLEVEL9K_VCS_BRANCH_ICON=$'\ue702' # 
#POWERLEVEL9K_VCS_COMMIT_ICON=$'\ue729'
#POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON=$'\ue703'
#POWERLEVEL9K_VCS_GIT_GITHUB_ICON=$'\uf408'
#POWERLEVEL9K_VCS_GIT_GITLAB_ICON=$'\uf296'
#POWERLEVEL9K_VCS_GIT_ICON=$'\uf1d2'
#POWERLEVEL9K_VCS_HG_ICON=$'\uf223'
#POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=$'\u727' # ↓
#POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=$'\ue726' # ↑
#POWERLEVEL9K_VCS_REMOTE_BRANCH_ICON=$'\ue725' # →
#POWERLEVEL9K_VCS_STAGED_ICON=$'\uf067' # ✚
#POWERLEVEL9K_VCS_STASH_ICON=$'\uf192' # ⍟
#POWERLEVEL9K_VCS_SVN_ICON=$'\ue268' 
#POWERLEVEL9K_VCS_TAG_ICON=$'\uf02c'
#POWERLEVEL9K_VCS_UNSTAGED_ICON=$'\uf111' # ●
#POWERLEVEL9K_VCS_UNTRACKED_ICON=$'\uf128' #?

##-----Length Set
POWERLEVEL9K_SHORTEN_DIR_LENGTH=5

##-----ColorSet
#for code ({000..255}) print -P -- "$code: %F{$code}This is how your text would look like%f"

#POWERLEVEL9K_NODE_VERSION_BACKGROUND='28'
#POWERLEVEL9K_NODE_VERSION_FOREGROUND='15'
#POWERLEVEL9K_BACKGROUND_JOBS_ICON=''
#POWERLEVEL9K_VCS_STAGED_ICON='\u00b1'
#POWERLEVEL9K_VCS_UNTRACKED_ICON='\u25CF'
#POWERLEVEL9K_VCS_UNSTAGED_ICON='\u00b1'
#POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='\u2193'
#POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='\u2191'
#POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'
#POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'

POWERLEVEL9K_ROOT_INDICATOR_BACKGROUND="226"
POWERLEVEL9K_ROOT_INDICATOR_FOREGROUND="000"
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND="039"
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="000"
POWERLEVEL9K_DIR_HOME_BACKGROUND="039"
POWERLEVEL9K_DIR_HOME_FOREGROUND="000"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND="039"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="000"
POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_BACKGROUND="196"
POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_FOREGROUND="226"

POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='000'
POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND='226'
POWERLEVEL9K_STATUS_OK_BACKGROUND="000" #alpha
POWERLEVEL9K_STATUS_OK_FOREGROUND="002" #green
POWERLEVEL9K_STATUS_ERROR_BACKGROUND="196" #red
POWERLEVEL9K_STATUS_ERROR_FOREGROUND="226" #yellow
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='196'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='226'
POWERLEVEL9K_HISTORY_BACKGROUND='244'
POWERLEVEL9K_HISTORY_FOREGROUND='000'
POWERLEVEL9K_LOAD_CRITICAL_BACKGROUND="196"
POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND="226"
POWERLEVEL9K_LOAD_WARNING_BACKGROUND="040"
POWERLEVEL9K_LOAD_WARNING_FOREGROUND="000"
POWERLEVEL9K_LOAD_NORMAL_BACKGROUND="040"
POWERLEVEL9K_LOAD_NORMAL_FOREGROUND="000"

##-----Others
#POWERLEVEL9K_TIME_FORMAT="%D{%H:%M  \uE868  %d.%m.%y}"
#POWERLEVEL9K_CHANGESET_HASH_LENGTH=6
#POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"

##-------------------------Other System Configs
