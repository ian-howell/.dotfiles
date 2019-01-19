#!/bin/bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/.dotfiles
############################

########## Variables
#set -x

links_dir=$HOME/.dotfiles/links                    # dotfiles directory
olddir=$HOME/.backup_dotfiles          # old dotfiles backup directory
##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in $HOME ..."
rm -rf $olddir
mkdir -p $olddir

# Delete old links, move any existing dotfiles in $HOME to $olddir
# directory, then create symlinks from $HOME to any files in the
# $links_dir directory
echo "Moving any existing dotfiles from $HOME to $olddir"
for path in $links_dir/*; do
    file=$(basename $path)
    if [ -h $HOME/.$file ]; then
        rm $HOME/.$file
    elif [ -e $HOME/.$file ]; then
        mv -f $HOME/.$file $olddir
    fi
    echo "Creating symlink to $file in home directory."
    ln -s $links_dir/$file $HOME/.$file
done

# Create the vim directories
echo "Creating vim undo directory ..."
mkdir -p $HOME/.vim/undo 2> /dev/null

echo "done"
set +x
