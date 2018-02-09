#!/bin/bash
############################
# This script downloads and sets up an environment
############################

########## Variables

ARTIFACT_DIR=$HOME/setup_artifacts

DOTFILES=$HOME/.dotfiles
VIM_ARTIFACTS=$ARTIFACT_DIR/vim_artifacts
COMPIZ_CONFIG_DIR=$HOME/.config/compiz-1/compizconfig/

##########

# Check that we are root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "Setting up essentials"
apt-get -y update
apt-get -y install libncurses5-dev libgnome2-dev libgnomeui-dev \
    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
    libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
    python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev git curl make ctags

# Create a directory to hold the artifacts from the setup process
if [ ! -e $ARTIFACT_DIR ]; then
    mkdir $ARTIFACT_DIR
fi
cd $ARTIFACT_DIR

echo "Setting up Vim"

vim_exists=$(command -v vim)

if [[ $vim_exists -eq 0 ]]; then
    apt-get remove vim vim-runtime gvim
fi

if [ ! -e $VIM_ARTIFACTS ]; then
    mkdir $VIM_ARTIFACTS
fi
cd $VIM_ARTIFACTS
# Get vim source
if [ -e vim ]; then
    rm -fr vim
fi
git clone https://github.com/vim/vim.git

# Build and configure
cd vim/src
make
make install

update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
update-alternatives --set editor /usr/bin/vim
update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
update-alternatives --set vi /usr/bin/vim

# Get and configure Vim-Plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
cd $ARTIFACT_DIR

# Set up my dotfiles
if [ ! -e $DOTFILES ]; then
    git clone https://github.com/ian-howell/.dotfiles.git $DOTFILES
fi
cd $DOTFILES
source setup_dotfiles.sh

# Get compiz
echo "Getting Compiz"
apt-get -y install compiz
mkdir -p $COMPIZ_CONFIG_DIR
cp $DOTFILES/compiz_profile.bak $COMPIZ_CONFIG_DIR/Default.ini
