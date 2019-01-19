set -x
install_zsh() {
  if [ ! -n "$ZSH" ]; then
    ZSH=~/.oh-my-zsh
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  zsh_exists=$(command -v zsh)
  if [ -z "$zsh_exists" ]; then
      sudo apt-get -qq -y install zsh
  fi

  echo "Cloning Oh My Zsh..."
  env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "$ZSH" || {
    echo "Error: git clone of oh-my-zsh repo failed"
    return
  }

  # If this user's login shell is not already "zsh", attempt to switch.
  TEST_CURRENT_SHELL=$(basename "$SHELL")
  if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
    if hash chsh >/dev/null 2>&1; then
      echo "Time to change your default shell to zsh!"
      chsh -s $(grep /zsh$ /etc/shells | tail -1)
    else
      # This is a hack...
      bash_loc=$(which bash)
      zsh_loc=$(which zsh)
      sudo sed -i -e "s,$HOME:$bash_loc,$HOME:$zsh_loc," /etc/passwd
    fi
  fi
  echo 'zsh installed :)'
}
install_zsh
set +x
