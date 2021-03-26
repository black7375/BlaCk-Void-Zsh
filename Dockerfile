# == Init ================================
FROM archlinux:latest
MAINTAINER alstjr375 <alstjr7375@daum.net>

# == User Setting ========================
RUN pacman -Syyu --noconfirm && pacman -S --noconfirm sudo git
RUN useradd -mG wheel dockeruser \
    && echo 'dockeruser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER dockeruser

# == Zsh Setting =========================
SHELL ["/bin/bash", "-c"]
ENV NO_FONT YES
ENV NO_DEFAULT YES
ENV AA bb
RUN git clone -b dev https://github.com/black7375/BlaCk-Void-Zsh.git ~/.zsh
RUN ~/.zsh/BlaCk-Void-Zsh.sh
RUN zsh -ic "@zinit-scheduler burst"
