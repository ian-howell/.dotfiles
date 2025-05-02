#===[ python
alias ut="python -m unittest"
alias pprint="python -m json.tool"

#===[ Git aliases

# Open Lazygit
alias lg="lazygit"

# This is my most used git command
alias g="git status"

# Add commands
alias ga="git add"
alias gaa="git add -A"
alias gap="git add -p"

# Branch commands
alias gb="git branch"
alias gbc="git switch -c"
alias gbs-="git switch -"
alias gbs="git switch"
alias gbsm="git switch main"

# Commit commands
alias gc="git commit"
alias gca="git commit --amend --no-edit"
alias gcae="git commit --amend"
alias gcm="git commit -m"

# Diff commands
alias gd="git diff"
alias gds="git diff --staged"
alias gdn="git diff --name-only"
# SINGLE QUOTES ARE IMPORTANT HERE! Otherwise, the merge-base command is run when my startup scripts are run
alias gdm='git diff $(git merge-base main HEAD)'
alias gdmn='git diff --name-only $(git merge-base main HEAD)'
alias gdo="git odiff"
alias gdv="git vimdiff"

# File listing commands
alias gf="(git ls-files -o --exclude-standard; git ls-files -m) | uniq" # list untracked and modified files
alias gfm="(git ls-files -o --exclude-standard; git diff --name-only --diff-filter=d main) | uniq" # list untracked and modified files, but only those that are different from main

# Pull (get) commands
alias gg="git fetch"
alias ggm="git fetch && git merge && git submodule update --init --recursive"
alias ggr="git fetch && git rebase && git submodule update --init --recursive"

# Log commands
alias gl="git log"
alias glo="git log --color=always --oneline --decorate --max-count=10"
alias gla="git log --graph --oneline --decorate --all"

# Push commands
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gph="git push origin HEAD"
alias gphf="git push origin HEAD --force-with-lease"

# Rebase commands
alias gr="git rebase"
alias grc="git rebase --continue"
alias grm="git rebase main"
alias grs="git rebase --skip"

# Stash commands
alias gs="git stash"
alias gsa="git stash --all"
alias gsl="git stash list"
alias gsp="git stash pop"
alias gsu="git stash -u"

# Restore (undo) commands
alias gu="git restore"
alias gup="git restore -p"
alias gus="git restore --staged"

#===[ ls
# Add color
alias ls="ls --color=auto"

#===[ vim
alias vim="nvim"

alias :q=exit
alias :wq=exit
alias :qa=exit
alias :wqa=exit
alias :e=true

# view, but with forced yaml syntax
alias viewyaml="view +set\ ft=yaml -"

#===[ grep
# Ignore binaries/directories
alias grep="grep -Idskip --color=auto"
alias grpe='grep'

#===[ tmux
# force tmux to use 256 colors (to make vim pretty)
alias tmux="tmux -2"

# Shortcut to my session manager
alias t="tmux-sessionizer"

#===[ valgrind
alias valrgind=valgrind
alias valigrnd=valgrind
alias val=valgrind

#===[ Miscellaneous
# Safety first
alias mv="mv -i"
alias cp="cp -i"

# Open in default without needing that dumb hyphen
alias dopen="xdg-open"

# Shortcut to trim whitespace from output
alias trim="awk '{\$1=\$1};1;'"

# This is the same as uniq, but it works on streaming data
alias uniqstream="awk '!seen[\$0]++'"

# List all of the recently visited directories
alias dirs="dirs -lpv"

alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias top='top -d 5 -c'

# Repeat last command. I frequently use ctrl-p to go to last command and run it, but frequently miss ctrl...
alias p="r"

# Docker - This may eventually warrant its own section
alias dkps="docker ps -a --format \"table {{.Command}}\t{{.Status}}\t{{.Names}}\""

# A faster watch
alias poll="watch -n0.1"

# Check internet speed
alias checkspeed="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -"

#===[ Kubernetes
alias k='kubectl'

alias kg='kubectl get'
alias kgpo='kubectl get pods'
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

alias ka='kubectl apply -f'
alias krm='kubectl delete'

alias klo='kubectl logs'
alias klof='kubectl logs -f'

alias kd='kubectl describe'

alias kustomzie="kustomize"
alias kustom="kustomize"
