##-------------------------FZF set
##-----Color Scheme
export FZF_DEFAULT_OPTS="
    --color fg:-1,bg:-1,hl:196,fg+:254,bg+:239,hl+:040
    --color info:226,prompt:226,pointer:196,marker:254,spinner:226
    --preview 'file {}' 
    --preview-window down:1
  "
#hl: red, fg+: white, bg+: gray(or 244), hl+: green
#info: yellow, pointer: red, marker: white, spinner: yellow

zle     -N    _fzf_readline
bindkey '^x1' _fzf_readline

alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
local _gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
local _viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"

# ALT-I - Paste the selected entry from locate output into the command line
zle     -N    fzf-locate-widget
bindkey '\ei' fzf-locate-widget

export FZF_TMUX=1
#Directly executing the command (CTRL-X CTRL-R)
zle     -N     fzf-history-widget-accept
bindkey '^X^R' fzf-history-widget-accept

export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

#export FZF_DEFAULT_COMMAND='
#  (git ls-tree -r --name-only HEAD ||
#   find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
#      sed s/^..//) 2> /dev/null'
export FZF_DEFAULT_COMMAND='rg --type f'

##this is better #https://tinyurl.com/ydx5katm
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

##-----Completion
#hg
_fzf_complete_hg()
{
  ARGS="$@"
  if [[ $ARGS == 'hg merge'* ]] || [[ $ARGS == 'hg up'* ]]; then
    _fzf_complete "--no-sort" "$@" < <(
      { hg branches & hg tags }
    )
  else
    eval "zle ${fzf_default_completion:-expand-or-complete}"
  fi
}
_fzf_complete_hg_post()
{
  cut -f1 -d' '
}

#Git
_fzf_complete_git()
{
    ARGS="$@"
    local branches
    branches=$(git branch -vv --all)
    if [[ $ARGS == 'git co'* ]]; then
        _fzf_complete "--reverse --multi" "$@" < <(
            echo $branches
        )
    else
        eval "zle ${fzf_default_completion:-expand-or-complete}"
    fi
}
_fzf_complete_git_post()
{
    awk '{print $1}'
}
