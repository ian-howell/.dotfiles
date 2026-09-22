```
cd "$HOME"
git clone https://github.com/ian-howell/.dotfiles
cd .dotfiles
git remote set-url origin git@github.com:ian-howell/.dotfiles
./setup.sh
```

### Delta theme

Delta uses the Tokyo Night Moon palette to match Neovim. Its syntax theme lives in
`links/bat/themes/tokyonight_moon.tmTheme`; delta reads bat's compiled theme cache.
Setup rebuilds this cache after linking the dotfiles. After editing the theme, run:

```sh
bat cache --build
```
