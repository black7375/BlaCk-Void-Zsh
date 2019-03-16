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
    while true; do
        read -p "$* [0/1/2]: " ans
        case $ans in
            [0]*)
                echo "Don't Install Fonts."
                break
                ;;
            [1]*)
                echo "Install Hack Nerd Fonts."
                necessary
                break
                ;;
            [2]*)
                echo "All Fonts Install."
                all
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
    cd $fontDir
    sudo curl -fLo "Hack Bold Nerd Font Complete.ttf" https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/Bold/complete/Hack%20Bold%20Nerd%20Font%20Complete.ttf
    sudo curl -fLo "Hack Bold Italic Nerd Font Complete.ttf" https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/BoldItalic/complete/Hack%20Bold%20Italic%20Nerd%20Font%20Complete.ttf
    sudo curl -fLo "Hack Italic Nerd Font Complete.ttf" https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/Italic/complete/Hack%20Italic%20Nerd%20Font%20Complete.ttf
    sudo curl -fLo "Hack Regular Nerd Font Complete.ttf" https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
    sudo chmod 644 Hack*
    
    if ![[ "$OSTYPE" == "darwin"*  ]] ; then
      fc-cache -f -v
    fi
    cd $BVZSH
}

all()
{
    git clone https://github.com/ryanoasis/nerd-fonts.git $BVZSH/nerd-fonts
    cd nerd-fonts && ./install.sh
    cd ..
}
options
font_install
