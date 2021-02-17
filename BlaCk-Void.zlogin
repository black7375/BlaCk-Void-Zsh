# Disable for `&!` http://zsh.sourceforge.net/Doc/Release/Jobs-_0026-Signals.html
# shellcheck disable=SC1009

# Auto zcompile
if [[ ! -f ${BVZSH}/BlaCk-Void.zshrc.zwc ]]; then
    zsh-compile &!
fi

# Execute code in the background to not affect the current session
{
    # Compile zcompdump, if modified, to increase startup speed.
    zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
    if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
        zcompile "$zcompdump"
    fi
} &!
