#!/bin/bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/.dotfiles
############################

########## Variables

dir=$HOME/.dotfiles                    # dotfiles directory
olddir=$HOME/.dotfiles_old             # old dotfiles backup directory
files="profile bashrc sh_aliases vim vimrc inputrc gitconfig funcs zshrc"    # list of files/folders to symlink in homedir
##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in $HOME ..."
if [ ! -e $olddir ]; then
   mkdir -p $olddir
fi

# change to the dotfiles directory
echo "Changing to the $dir directory ..."
cd $dir

# Delete oldfiles, move any existing dotfiles in homedir to dotfiles_old
# directory, then create symlinks from the homedir to any files in the
# $HOME/dotfiles directory specified in $files
if [ -d $olddir ]; then
    rm -rf $olddir
fi
echo "Moving any existing dotfiles from $HOME to $olddir"
for file in $files; do
    if [ -h $HOME/.$file ]; then
        rm $HOME/.$file
    elif [ -e $HOME/.$file ]; then
        mv -f $HOME/.$file $olddir
    fi
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file $HOME/.$file
done

# Create the vim directories
echo "Creating vim backup directory ..."
if [ -e vim/undo ]; then
    mkdir -p vim/undo
fi

echo "done"
