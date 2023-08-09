#!/bin/bash
echo "--------------------"
echo "  Fonts Settings"
echo ""

options()
{
    echo "0) None Install Fonts."
    echo "1) Only Necessary Fonts(Will install Hack Nerd Font)."
    echo "2) All Fonts Install(Nerd Fonts)."
}

font_install()
{
    while [[ -z "$BVZSH_FONT" ]]; do
        read -rp "$* [0/1/2]: " ans
        case $ans in
            [0]*)
                echo "Don't Install Fonts."
                BVZSH_FONT=0
                break
                ;;
            [1]*)
                echo "Install Hack Nerd Fonts."
                necessary
                BVZSH_FONT=1
                break
                ;;
            [2]*)
                echo "All Fonts Install."
                all
                BVZSH_FONT=2
        esac
        echo "Please answer again."
        options
    done
}

necessary()
{
    if   [[ "$OSTYPE" == "linux-gnu" ]]; then
        local fontDir="/usr/share/fonts/"
    elif [[ "$OSTYPE" == "darwin"*  ]] ; then
        local fontDir="/Library/Fonts/"
    elif uname -a | grep FreeBSD       ; then
        local fontDir="/usr/local/share/fonts/"
    else
        echo "OS NOT DETECTED, couldn't install fonts."
        exit 1;
    fi
    cd "$fontDir" || exit
    sudo curl -fLo "Hack Bold Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Bold/HackNerdFont-Bold.ttf
    sudo curl -fLo "Hack Bold Italic Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/BoldItalic/HackNerdFont-BoldItalic.ttf
    sudo curl -fLo "Hack Italic Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Italic/HackNerdFont-Italic.ttf
    sudo curl -fLo "Hack Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf
    sudo chmod 644 Hack*

    if ! [[ "$OSTYPE" == "darwin"*  ]] ; then
      fc-cache -f -v
    fi
    cd "$BVZSH" || exit
}

all()
{
    git clone https://github.com/ryanoasis/nerd-fonts.git "$BVZSH"/nerd-fonts
    cd nerd-fonts && ./install.sh
    cd ..
}
options
font_install "$@"
