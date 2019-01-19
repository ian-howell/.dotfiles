set wildignore+=*.txt,*.rst,*.log
set wildignore+=*.html,*.css,*.js

" Add a breakpoint
nnoremap ,pb maOimport pdb; pdb.set_trace()<ESC>`a

set foldmethod=indent
set foldnestmax=2
