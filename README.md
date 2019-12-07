```
sudo apt-get install curl
curl -s https://raw.githubusercontent.com/ian-howell/.dotfiles/master/src/install_git | bash
cd "$HOME"
git clone https://github.com/ian-howell/.dotfiles
cd .dotfiles
git remote set-url origin git@github.com:ian-howell/.dotfiles
source source_me
```
