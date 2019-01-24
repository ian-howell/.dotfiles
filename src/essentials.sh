set -x

echo "Setting up essentials"
sudo apt-get -qq -y update
sudo apt-get -qq -y install \
  libncurses5-dev \
  libgnome2-dev \
  libgnomeui-dev \
  libgtk2.0-dev \
  libatk1.0-dev \
  libbonoboui2-dev \
  libcairo2-dev \
  libx11-dev \
  libxpm-dev \
  libxt-dev \
  python-dev \
  python3-dev \
  ruby-dev \
  lua5.1 \
  lua5.1-dev \
  libperl-dev \
  git \
  curl \
  make \
  ctags \
  silversearcher-ag \
  tree \
  xclip \
  tmux
set +x
