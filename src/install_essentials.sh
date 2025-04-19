#!/bin/bash

# Make sure we're getting the latest version of git
sudo add-apt-repository ppa:git-core/ppa -y

sudo apt-get -y -q update

# The following are library-type things. They're basically dependencies
sudo apt-get install -y -q \
  libncurses-dev \
  libgtk2.0-dev \
  libatk1.0-dev \
  libcairo2-dev \
  libx11-dev \
  libxpm-dev \
  libxt-dev \
  python3-dev \
  python3.10-venv \
  ruby-dev \
  lua5.1 \
  liblua5.1-0-dev \
  libperl-dev \
  ;

# These are my programs
sudo apt-get install -y -q \
  curl \
  git \
  make \
  silversearcher-ag \
  tmux \
  tree \
  xclip \
  shellcheck \
  bat \
  jq \
  ripgrep \
  ;

sudo ln -s /usr/bin/batcat /usr/bin/bat
