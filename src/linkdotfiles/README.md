# linkdotfiles

linkdotfiles creates symlinks based on a YAML config.

## Configuration

The config file lives at `~/.dotfiles/linkdotfiles.yaml` and has this shape:

```yaml
links:
  - file: ~/.dotfiles/links/gitconfig
    link: ~/.gitconfig
```

Each link requires absolute paths for `file` and `link` (home expansion
with `~` and `$HOME` is supported).
