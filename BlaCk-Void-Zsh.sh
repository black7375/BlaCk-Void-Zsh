echo "----------------------------------------"
echo "         BlaCk-Void Zsh Setup"
echo "----------------------------------------\n"
BVZSH=$( cd "$(dirname "$0")" ; pwd )

echo "--------------------"
echo "  Downloads\n"
sudo apt-get install zsh zshdb autojump powerline curl python3-dev python3-pip shellcheck
sudo pip3 install thefuck
curl -L git.io/antigen > $BVZSH/antigen.zsh
git clone https://github.com/paoloantinori/hhighlighter.git $BVZSH/hhighlighter
wget -P $BVZSH https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
if [ -d "/home/linuxbrew/.linuxbrew/bin" ] ; then
  export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
fi
brew install fzf ripgrep
$(brew --prefix)/opt/fzf/install

echo "--------------------"
echo "  Fonts Settings\n"
git clone https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts && ./install.sh
cd ..

echo "--------------------"
echo "  Apply Settings\n"
file=~/.zshrc
if [ -e $file ]
then
  echo "$file found."
  echo "Now Backup.."
  cp -v ~/.zshrc ~/.zshrc.bak
else
  echo "$file not found."
fi
sudo chsh -s /usr/bin/zsh # chsh $USER -s $(which zsh);

echo "source $BVZSH/BlaCk-Void.zshrc" >> ~/.zshrc
#cp -v BlaCk-Void.zshrc  ~/.zshrc
echo "Please relogin session or restart terminal"
echo "The End!!\n\n"
echo "command: zsh-help"
echo "for BlaCk-Void Zsh update"
