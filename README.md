 
# BlaCk Void Zsh

Awesome Zsh Setting.

Tested on Kubuntu 18.04

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [BlaCk Void Zsh](#black-void-zsh)
    - [Feature](#feature)
        - [Terminal Image Viewer](#terminal-image-viewer)
        - [Weather](#weather)
    - [Apply](#apply)
        - [Ubuntu](#ubuntu)
        - [Others](#others)
    - [Theme](#theme)
    - [Plugins](#plugins)

<!-- markdown-toc end -->

## Feature
* Preview

![Zsh](https://i.pinimg.com/originals/88/b4/db/88b4dbbd42b2c75afe2f3b9a27fc3747.png)

### Terminal Image Viewer
![img-zsh](https://i.pinimg.com/originals/1c/7c/c4/1c7cc4e4f88376d6900f7c420baf6d50.png)
Show image like preview.  
You can use with command `img`

Useage:  
`img FILE_NAME TIME`(TIME default 2s)

img Feature  
Supported: Konsole, Xterm, Urxvt, Terminology, Yakuake, Terminal.app  
Unsupported: Terminator, Hyper, Tilix, gnome terminal, Guake, LXterminal, Putty  
Todo Check: iTerm3

for unsupported Terminals  
use [tiv](https://github.com/radare/tiv) or [fim](https://www.nongnu.org/fbi-improved/)

### Weather
![weather](https://i.pinimg.com/originals/02/7c/fd/027cfd9d099d2ddc42d9bb411d9de592.png)

Useage:  
`weather`  
or  
`weather LOCALE LANGUAGE(option)`

Default Language: Your system's language

## Apply

### Ubuntu

``` shell
git clone https://github.com/black7375/BlaCk-Void-Zsh.git ~/
bash ~/BlaCk-Void-Zsh/BlaCk-Void-Zsh.sh
```

When you want to use with awesome tmux, Check [BlaCk-Void-Tmux](https://github.com/black7375/BlaCk-Void-Tmux/blob/master/README.md).

### Others

**Requirements**

* zsh, powerline support font, fzf[integrated], ripgrep, ack(for [h](https://github.com/paoloantinori/hhighlighter))

**Install**

* Git Clone  
  ``` shell
  git clone https://github.com/black7375/BlaCk-Void-Zsh.git ~/ && cd BlaCk-Void-Zsh
  ```

* antigen  
  ``` shell
  curl -L git.io/antigen > antigen.zsh
  ```

* nerdfont  
  ``` shell
  git clone https://github.com/ryanoasis/nerd-fonts.git
  cd nerd-fonts && ./install.sh
  cd ..
  ```

* Add to .zshrc  

Source File[Recommend]  
  `echo "source BlaCk-Void.zshrc" >> ~/.zshrc`

or Link  
  `ln -svf BlaCk-Void.zshrc ~/.zshrc`

or Copy  
  `cp -v BlaCk-Void.zshrc  ~/.zshrc`


* Zsh Shell Set  
  `sudo chsh -s /usr/bin/zsh`

## Theme

* [Powerlevel9k](https://github.com/bhilburn/powerlevel9k)

## Plugins

**Plugin Manager**

* [Antigen](https://github.com/zsh-users/antigen)

**Default Repo (robbyrussell's oh-my-zsh).**

* [Autojump](https://github.com/wting/autojump):
  Enables autojump if installed with homebrew, macports or debian/ubuntu package.
* [Command Not Found](https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/command-not-found/command-not-found.plugin.zsh):
  Only for Ubuntu and openSUSE: If a command is not recognized in the $PATH, this will use Ubuntu's command-not-found package to find it or suggest spelling mistakes:
* [Git](https://github.com/robbyrussell/oh-my-zsh/wiki/Plugin:git):
  Adds a lot of git aliases and functions for pulling for dealing with the current branch.
* [Lein](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/lein):
  lein - auto-completion for [leiningen](https://github.com/technomancy/leiningen), build tool for clojure
* [Pip](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/pip):
  pip - completion plugin for the pip command
* [Sudo](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/sudo):
  ESC twice: Puts sudo in front of the current command, or the last one if the command line is empty.
* [Thefuck](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/thefuck):
  The Fuck plugin — magnificent app which corrects your previous console command.
* Tmux(https://github.com/tmux/tmux)
* Tmuxinator(https://github.com/achiu/terminitor):
  Completions for tmuxinator.
* [Urltools](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/urltools)
* [Z](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/z):
  yet another autojump

**Custom Repo**

* [Zsh 256 Color](https://github.com/chrissicool/zsh-256color)
* [Alias Tips](https://github.com/djui/alias-tips)
* [Zsh Autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
* [Zsh Autopair](https://github.com/hlissner/zsh-autopair)
* [Autoupdate Antigen](https://github.com/unixorn/autoupdate-antigen.zshplugin)
* [Zsh Completions](https://github.com/zsh-users/zsh-completions)
* [Enhancd](https://github.com/b4b4r07/enhancd)
* [Fast Syntax Highlighting](https://github.com/zdharma/fast-syntax-highlighting)
* [Forgit](https://github.com/wfxr/forgit)
* [Fzf Widgets](https://github.com/ytet5uy4/fzf-widgets)
* [Zsh Git Smart Commands](https://github.com/seletskiy/zsh-git-smart-commands)
* [Git Store](https://github.com/smallhadroncollider-deprecated/antigen-git-store)
* [Zsh History Substring Search](https://github.com/zsh-users/zsh-history-substring-search)
* [Zsh Interactive Cd](https://github.com/changyuheng/zsh-interactive-cd)
* [k](https://github.com/supercrabtree/k)
* [up](https://github.com/peterhurford/up.zsh)
