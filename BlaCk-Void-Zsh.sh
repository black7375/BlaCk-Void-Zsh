#!/bin/bash
echo "----------------------------------------"
echo "         BlaCk-Void Zsh Setup"
echo "----------------------------------------"
set -e
BVZSH=$( cd "$(dirname "$0")" ; pwd )

echo ""
echo "--------------------"
echo "  Downloads"
echo ""
ARH_PACKAGE_NAME="zsh zshdb autojump powerline curl shellcheck git fzf ripgrep thefuck w3m"
DEB_PACKAGE_NAME="zsh zshdb autojump powerline curl shellcheck git w3m-img"
YUM_PACKAGE_NAME="zsh autojump powerline curl shellcheck git w3m-img"
MAC_PACKAGE_NAME="zsh zshdb autojump curl python shellcheck git socat coreutils w3m"
BSD_PACKAGE_NAME="zsh autojump py36-powerline-status curl git fzf ripgrep thefuck w3m-img"

arh_install()
{
  sudo pacman -Sy
  yes | sudo pacman -S $ARH_PACKAGE_NAME
}
deb_install()
{
  sudo apt-get update
  sudo apt-get install -y $DEB_PACKAGE_NAME
}
yum_install()
{
  sudo yum check-update
  sudo yum install -y $YUM_PACKAGE_NAME
}
mac_install()
{
  sudo brew update
  sudo brew install -y $MAC_PACKAGE_NAME
  sudo pip install powerline-status
}
bsd_install()
{
  sudo pkg update
  sudo pkg install -y $BSD_PACKAGE_NAME
}

set_brew()
{
  if [ -x "$(command -v brew)" ]; then
    echo "Now, Install Brew." >&2
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

      if [ -d "/home/linuxbrew/.linuxbrew/bin" ] ; then
        export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
      fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
  fi
  brew install -y fzf ripgrep thefuck
  $(brew --prefix)/opt/fzf/install
}
etc_install()
{
  curl -L git.io/antigen > $BVZSH/antigen.zsh
  git clone https://github.com/paoloantinori/hhighlighter.git $BVZSH/hhighlighter
  wget -P $BVZSH https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
  chmod +x prettyping
  source $BVZSH/install_font.sh
}

if   [[ "$OSTYPE" == "linux-gnu" ]]; then
  ##ARH Package
  if   cat /etc/*release | grep ^NAME    | grep Manjaro; then
    arh_install
  elif cat /etc/*release | grep ^NAME    | grep Chakra ; then
    arh_install
  elif cat /etc/*release | grep ^ID      | grep arch   ; then
    arh_install
  elif cat /etc/*release | grep ^ID_LIKE | grep arch   ; then
    arh_install

  ##Deb Package
  elif cat /etc/*release | grep ^NAME    | grep Ubuntu ; then
    deb_install
  elif cat /etc/*release | grep ^NAME    | grep Debian ; then
    deb_install
  elif cat /etc/*release | grep ^NAME    | grep Mint   ; then
    deb_install
  elif cat /etc/*release | grep ^NAME    | grep Knoppix; then
    deb_install
  elif cat /etc/*release | grep ^ID_LIKE | grep debian ; then
    deb_install

  ##Yum Package
  elif cat /etc/*release | grep ^NAME    | grep CentOS ; then
    yum_install
  elif cat /etc/*release | grep ^NAME    | grep Red    ; then
    yum_install
  elif cat /etc/*release | grep ^NAME    | grep Fedora ; then
    yum_install
  elif cat /etc/*release | grep ^ID_LIKE | grep rhel   ; then
    yum_install

  else
     echo "OS NOT DETECTED, couldn't install packages."
     exit 1;
  fi
  set_brew
elif [[ "$OSTYPE" == "darwin"*  ]]; then
  set_brew
  mac_install
elif [[ "$OSTYPE" == "FreeBSD"* ]]; then
  bsd_install
else
  echo "OS NOT DETECTED, couldn't install packages."
  exit 1;
fi

etc_install
source $BVZSH/install_font.sh

echo "--------------------"
echo "  Apply Settings"
echo ""
zshrc=~/.zshrc
if [ -e $zshrc ]
then
  echo "$zshrc found."
  echo "Now Backup.."
  cp -v $zshrc $zshrc.bak
else
  echo "$zshrc not found."
fi
zshenv=~/.zshenv
if [ -e $zshenv ]
then
    echo "$zshenv found."
    echo "Now Backup.."
    cp -v $zshenv $zshenv.bak
else
    echo "$zshenv not found."
fi

sudo chsh -s /usr/bin/zsh # chsh $USER -s $(which zsh);

echo "source $BVZSH/BlaCk-Void.zshrc"         >> $zshrc
echo "[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh" >> $zshrc
echo "source $BVZSH/BlaCk-Void.zshenv"        >> $zshenv
#cp -v BlaCk-Void.zshrc  $file
echo "Please relogin session or restart terminal"
echo "The End!!"
echo ""
echo "command: zsh-help"
echo "for BlaCk-Void Zsh update"
