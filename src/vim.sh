set -x
function build_vim ()
{
    echo "Setting up Vim"

    vim_exists=$(command -v vim)
    if [ ! -z "$vim_exists" ]; then
        vim_version=$(vim --version | head -n1 | cut -d' ' -f5 | cut -d'.' -f1)
        if [ "$vim_version" -ge "8" ]; then
            # Vim exists and is at least version 8
            return
        fi

        # Vim exists, but is version 7.4 or lower. Remove it
        sudo apt-get -qq remove vim vim-runtime gvim
    fi

    VIM_ARTIFACTS=$ARTIFACTS_DIR/vim_artifacts
    mkdir -p $VIM_ARTIFACTS

    # Get vim source
    git clone https://github.com/vim/vim.git $VIM_ARTIFACTS/vim

    # Build and configure
    cd $VIM_ARTIFACTS/vim
    ./configure --with-features=huge \
                --enable-multibyte \
                --enable-rubyinterp=yes \
                --enable-python3interp=yes \
                --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
                --enable-perlinterp=yes \
                --enable-luainterp=yes \
                --enable-gui=gtk2 \
                --enable-cscope \
               --prefix=/usr/local
    make VIMRUNTIMEDIR=/usr/local/share/vim/vim81
    sudo make install

    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
    sudo update-alternatives --set editor /usr/bin/vim
    sudo update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
    sudo update-alternatives --set vi /usr/bin/vim

    cd $MAIN_DIR
}
build_vim
vim +PlugInstall +qall
set +x
