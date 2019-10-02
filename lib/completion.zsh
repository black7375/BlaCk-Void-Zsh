#Useful Completion @finnurtorfa/zsh(https://github.com/finnurtorfa/zsh)
# Add zsh-completions to $fpath.
fpath=("${BVZSH}/completion" $ZPLG_FPATH_BEFORE $fpath )

setopt auto_list
setopt auto_menu
setopt always_to_end

## completion system
zstyle ':completion:*:approximate:'                 max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )' # allow one error for every three characters typed in approximate completer
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'              # don't complete backup files as executables
zstyle ':completion:*:correct:*'                    insert-unambiguous true             # start menu completion only if it could find no unambiguous initial string
zstyle ':completion:*:corrections'                  format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}' #
zstyle ':completion:*:correct:*'                    original true                       #
zstyle ':completion:*:default'                      list-colors ${(s.:.)LS_COLORS}      # activate color-completion(!)
zstyle ':completion:*:descriptions'                 format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'  # format on completion
zstyle ':completion:*:*:cd:*:directory-stack'       menu yes select                     # complete 'cd -<tab>' with menu
zstyle ':completion:*:expand:*'                     tag-order all-expansions            # insert all expansions for expand completer
zstyle ':completion:*:history-words'                list false                          #
zstyle ':completion:*:history-words'                menu yes                            # activate menu
zstyle ':completion:*:history-words'                remove-all-dups yes                 # ignore duplicate entries
zstyle ':completion:*:history-words'                stop yes                            #
zstyle ':completion:*'                              matcher-list 'm:{a-z}={A-Z}'        # match uppercase from lowercase
zstyle ':completion:*:matches'                      group 'yes'                         # separate matches into groups
zstyle ':completion:*'                              group-name ''                       # group results by category
if [[ -z "$NOMENU" ]] ; then
  zstyle ':completion:*'                            menu select=2                       # if there are more than 5 options allow selecting from a menu
else
  setopt no_auto_menu # don't use any menus at all
fi
zstyle -e ':completion:*'                           special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'
zstyle ':completion:*:messages'                     format '%d'                         #
zstyle ':completion:*:options'                      auto-description '%d'               #
zstyle ':completion:*:options'                      description 'yes'                   # describe options in full
zstyle ':completion:*:processes'                    command 'ps -au$USER'               # on processes completion complete all user processes
zstyle ':completion:*:*:-subscript-:*'              tag-order indexes parameters        # offer indexes before parameters in subscripts
zstyle ':completion:*'                              verbose true                        # provide verbose completion information
zstyle ':completion:*:warnings'                     format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d' # set format for warnings
zstyle ':completion:*:*:zcompile:*'                 ignored-patterns '(*~|*.zwc)'       # define files to ignore for zcompile
zstyle ':completion:correct:'                       prompt 'correct to: %e'             #
zstyle ':completion::(^approximate*):*:functions'   ignored-patterns '_*'               # Ignore completion functions for commands you don't have:
zstyle ':completion::complete:*'                    gain-privileges 1                   # enabling autocompletion of privileged environments in privileged commands

# complete manual by their section
zstyle ':completion:*:manuals'                      separate-sections true
zstyle ':completion:*:manuals.*'                    insert-sections   true
zstyle ':completion:*:man:*'                        menu yes select


# Kill
zstyle ':completion:*:*:*:*:processes'              command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes'           list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*'                     menu yes select
zstyle ':completion:*:*:kill:*'                     force-list always
zstyle ':completion:*:*:kill:*'                     insert-ids single


# Media Players
zstyle ':completion:*:*:mpg123:*'                   file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:mpg321:*'                   file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:ogg123:*'                   file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mocp:*'                     file-patterns '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):ogg\ files *(-/):directories'

# Mutt
if [[ -s "$HOME/.mutt/aliases" ]]; then
  zstyle ':completion:*:*:mutt:*'                   menu yes select
  zstyle ':completion:*:mutt:*'                     users ${${${(f)"$(<"$HOME/.mutt/aliases")"}#alias[[:space:]]}%%[[:space:]]*}
fi

# SSH/SCP/RSYNC
zstyle ':completion:*:(ssh|scp|rsync):*'            tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*'                group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*'                        group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

## correction
# run rehash on completion so new installed program are found automatically:
_force_rehash() {
  (( CURRENT == 1 )) && rehash
  return 1 # Because we didn't really complete anything
}

# some people don't like the automatic correction - so run 'NOCOR=1 zsh' to deactivate it
if [[ -n "$NOCOR" ]] ; then
  zstyle ':completion:*'                            completer _oldlist _expand _force_rehash _complete _files
  setopt nocorrect # do not try to correct the spelling if possible
else
  #    zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _correct _approximate _files
  setopt correct  # try to correct the spelling if possible
  zstyle -e ':completion:*'                         completer '
  if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]]; then
    _last_try="$HISTNO$BUFFER$CURSOR"
    reply=(_complete _match _prefix _files)
  else
    if [[ $words[1] = (rm|mv) ]]; then
      reply=(_complete _files)
    else
      reply=(_oldlist _expand _force_rehash _complete _correct _approximate _files)
    fi
  fi'
fi

# command for process lists, the local web server details and host completion
zstyle ':completion:*:urls'                         local 'www' '/var/www/' 'public_html'

# caching
zstyle ':completion:*' accept-exact '*(N)'

[ -d $BVZSH/cache ] && zstyle ':completion:*'       use-cache yes && \
  zstyle ':completion::complete:*'                  cache-path $BVZSH/cache/

# host completion /* add brackets as vim can't parse zsh's complex cmdlines 8-) {{{ */
[ -r ~/.ssh/known_hosts ] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[ -r /etc/hosts ] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()

hosts=(`hostname` "$_ssh_hosts[@]" "$_etc_hosts[@]" localhost)
zstyle ':completion:*:hosts' hosts $hosts

# Complete words from tmux pane(s) {{{1
# Source: http://blog.plenz.com/2012-01/zsh-complete-words-from-tmux-pane.html
# Gist: https://gist.github.com/blueyed/6856354
_tmux_pane_words()
{
    local expl
    local -a w
    if [[ -z "$TMUX_PANE" ]]; then
        _message "not running inside tmux!"
        return 1
    fi

    # Based on vim-tmuxcomplete's splitwords function.
    # https://github.com/wellle/tmux-complete.vim/blob/master/sh/tmuxcomplete
    _tmux_capture_pane()
    {
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
