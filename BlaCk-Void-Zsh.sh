#!/bin/bash
# shellcheck disable=SC1091
# shellcheck source=./install_font.sh
echo "----------------------------------------"
echo "         BlaCk-Void Zsh Setup"
echo "----------------------------------------"
set -e
BVZSH=$( cd "$(dirname "$0")" ; pwd )

echo ""
echo "--------------------"
echo "  Downloads"
echo ""
ARH_RELEASE="arch\|Manjaro\|Chakra"
DEB_RELEASE="[Dd]ebian\|[Uu]buntu|[Mm]int|[Kk]noppix"
YUM_RELEASE="rhel\|CentOS\|RED\|Fedora"

ARH_PACKAGE_NAME=(zsh curl git w3m wmctrl ack tmux xdotool python-pip powerline)
DEB_PACKAGE_NAME=(zsh curl git w3m-img wmctrl ack tmux xdotool python3-pip powerline)
YUM_PACKAGE_NAME=(zsh curl git w3m-img wmctrl ack tmux xdotool python3-pip powerline)
MAC_PACKAGE_NAME=(zsh curl git socat w3m wmctrl ack tmux xdotool python3  xquartz)
BSD_PACKAGE_NAME=(zsh curl git thefuck w3m-img xdotool p5-ack tmux xdotool py37-pip py37-powerline-status)
PIP_PACKAGE_NAME=(thefuck)

PACAPT="/usr/local/bin/pacapt"
PACAPT_INSTALLED=true
pacapt_install()
{
  if ! [ -x "$(command -v pacapt)" ]; then
    echo "Universal Package Manager(icy/pacapt) Download && Install(need sudo permission)"
    sudo curl https://github.com/icy/pacapt/raw/ng/pacapt -Lo $PACAPT
    sudo chmod 755 $PACAPT
    sudo ln -sv $PACAPT /usr/local/bin/pacman || true
    PACAPT_INSTALLED=false
  fi
  sudo pacapt -Sy
}

arh_install()
{
  sudo pacapt -S --noconfirm  "${ARH_PACKAGE_NAME[@]}"
}
deb_install()
{
  sudo pacapt -S --noconfirm "${DEB_PACKAGE_NAME[@]}"
}
yum_install()
{
  sudo pacapt -S --noconfirm "${YUM_PACKAGE_NAME[@]}"
}
mac_install()
{
  brew update
  brew install "${MAC_PACKAGE_NAME[@]}"

  sudo pip3 install powerline-status
}
bsd_install()
{
  pacapt -S --noconfirm "${BSD_PACKAGE_NAME[@]}"
}

set_brew()
{
  if ! [ -x "$(command -v brew)" ]; then
    echo "Now, Install Brew." >&2

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    local BREW_PREFIX
    BREW_PREFIX=$(brew --prefix)
    export PATH=${BREW_PREFIX}/bin:${BREW_PREFIX}/sbin:$PATH
  fi

  brew install "${BRW_PACKAGE_NAME[@]}"
}

pip_install()
{
  if ! [ -x "$(command -v pip3)" ]; then
    curl https://bootstrap.pypa.io/get-pip.py | sudo python3
  fi
  sudo pip3 install "${PIP_PACKAGE_NAME[@]}"
}
etc_install()
{
  pip_install

  mkdir ~/.zplugin
  git clone https://github.com/zdharma/zinit.git ~/.zplugin/bin
  if ! [[ "$NO_FONT" == YES ]]; then
    "$BVZSH"/install_font.sh
  fi
}

if   [[ "$OSTYPE" == "linux-gnu" ]]; then
  RELEASE=$(cat /etc/*release)
  pacapt_install

  ##ARH Package
  if   echo "$RELEASE" | grep ^NAME    | grep Manjaro; then
    arh_install
  elif echo "$RELEASE" | grep ^NAME    | grep Chakra ; then
    arh_install
  elif echo "$RELEASE" | grep ^ID      | grep arch   ; then
    arh_install
  elif echo "$RELEASE" | grep ^ID_LIKE | grep arch   ; then
    arh_install

  ##Deb Package
  elif echo "$RELEASE" | grep ^NAME    | grep Ubuntu ; then
    ubuntu_ver=$(lsb_release -rs)
    if [[ ${ubuntu_ver:0:2} -lt 18 ]]; then
      DEB_PACKAGE_NAME=$( sed -e "s/ack/ack-grep/" <(echo "$DEB_PACKAGE_NAME") )
    fi
    deb_install
  elif echo "$RELEASE" | grep ^NAME    | grep Debian ; then
    deb_install
  elif echo "$RELEASE" | grep ^NAME    | grep Mint   ; then
    deb_install
  elif echo "$RELEASE" | grep ^NAME    | grep Knoppix; then
    deb_install
  elif echo "$RELEASE" | grep ^ID_LIKE | grep debian ; then
    deb_install

  ##Yum Package
  elif echo "$RELEASE" | grep ^NAME    | grep CentOS ; then
    yum_install
  elif echo "$RELEASE" | grep ^NAME    | grep Red    ; then
    yum_install
  elif echo "$RELEASE" | grep ^NAME    | grep Fedora ; then
    yum_install
  elif echo "$RELEASE" | grep ^ID_LIKE | grep rhel   ; then
    yum_install

  else
    echo "OS NOT DETECTED, try to flexible mode.."
    if   echo "$RELEASE" | grep "$ARH_RELEASE" > /dev/null 2>&1; then
      arh_install
    elif echo "$RELEASE" | grep "$DEB_RELEASE" > /dev/null 2>&1; then
      deb_install
    elif echo "$RELEASE" | grep "$YUM_RELEASE" > /dev/null 2>&1; then
      yum_install
    fi
  fi
elif [[ "$OSTYPE" == "darwin"*  ]]; then
  set_brew
  mac_install
elif [[ "$OSTYPE" == "FreeBSD"* ]]; then
  pacapt_install
  bsd_install
elif uname -a | grep FreeBSD      ; then
  pacapt_install
  bsd_install
else
  echo "OS NOT DETECTED, couldn't install packages."
  exit 1;
fi

etc_install

if [[ "$PACAPT_INSTALLED" == false ]]; then
  sudo rm -rf "$PACAPT"
fi

echo "--------------------"
echo "  Apply Settings"
echo ""

mkdir "$BVZSH"/cache
zshrc=~/.zshrc
zshenv=~/.zshenv
zlogin=~/.zlogin
zprofile=~/.zprofile
profile=~/.profile

set_file()
{
  local file=$1
  echo "-------"
  echo "Set $file !!"
  echo ""
  if [ -e "$file" ]; then
    echo "$file found."
    echo "Now Backup.."
    cp -v "$file" "$file".bak
    echo ""
  else
    echo "$file not found."
    touch "$file"
    echo "$file is created"
    echo ""
  fi
}
set_file $zshrc
set_file $zshenv
set_file $zlogin

echo "source $BVZSH/BlaCk-Void.zshrc"         >> $zshrc
echo "source $BVZSH/BlaCk-Void.zshenv"        >> $zshenv
echo "source $BVZSH/BlaCk-Void.zlogin"        >> $zlogin
if [ -e $profile ]; then
  < $profile tee -a $zprofile
fi

latest_update_date()
{
  BVZSH_PLUGIN_RECEIPT_F=${BVZSH_PLUGIN_RECEIPT_F:-.zsh_plugin_lastupdate}
  BVZSH_SYSTEM_RECEIPT_F=${BVZSH_SYSTEM_RECEIPT_F:-.zsh_system_lastupdate}

  date +%s > "${HOME}/$BVZSH_PLUGIN_RECEIPT_F"
  date +%s > "${HOME}/$BVZSH_SYSTEM_RECEIPT_F"

  echo "write latest update date"
}
latest_update_date

if ! [[ "$NO_DEFAULT" == YES ]]; then
  echo "-------"
  echo "ZSH as the default shell(need sudo permission)"
  chsh -s "$(which zsh)"
fi

echo "Please relogin session or restart terminal"
echo "The End!!"
echo ""

echo "command: zsh-help"
echo "for BlaCk-Void Zsh update"
