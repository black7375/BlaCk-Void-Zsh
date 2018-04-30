echo "BlaCk-Void Zsh PreInstalls.. \n"
sudo apt-get install zsh zshdb autojump powerline curl python3-dev python3-pip
sudo pip3 install thefuck

echo "--------------------"
echo "BlaCk-Void Zsh Setup"
echo "--------------------\n"
curl -L git.io/antigen > antigen.zsh
git clone https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts && ./install.sh
cd ..

file=~/.zshrc
if [ -e $file ]
then
  echo "$file found."
  echo "Now Backup.."
  mv -v ~/.zshrc ~/.zshrc.backup
else
  echo "$file not found."
fi
chsh -s /usr/bin/zsh # chsh $USER -s $(which zsh)
cp -v BlaCk-Void.zshrc  ~/.zshrc

echo "Please relogin session or restart terminal"
echo "The End!!"
