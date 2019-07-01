set -x

echo "Setting up essentials"
sudo apt-get -y update

# The following are library-type things. They're basically dependencies
sudo apt-get -y install libncurses5-dev libgnome2-dev libgnomeui-dev \
                libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev \
                libx11-dev libxpm-dev libxt-dev python-dev python3-dev \
                ruby-dev lua5.1 lua5.1-dev libperl-dev

# These are my programs
sudo apt-get install -y \
  compiz-plugins \
  compizconfig-settings-manager \
  ctags \
  curl \
  git \
  make \
  rxvt-unicode-256color \
  silversearcher-ag \
  tmux \
  tree \
  weechat \
  xclip \
  shellcheck \
  ;
set +x
