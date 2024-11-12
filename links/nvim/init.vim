" Notes on vimscript style:
"
" Typically, vimscript (and blankspace) should be Pythonic.
"
" In general, use plugin-names-like-this, FunctionNamesLikeThis,
" CommandNamesLikeThis, augroup_names_like_this, variable_names_like_this.

source ~/.config/nvim/helperfunctions.vim
source ~/.config/nvim/pluginconfigs/plugins.vim
source ~/.config/nvim/behavior.vim
source ~/.config/nvim/appearance.vim
source ~/.config/nvim/autocorrect.vim

"===[ Line and column display settings
"== Lines =="
set number             "Show the cursor's current line

" Keep the sign column open at all times
set signcolumn=yes

"===[ Windows and splitting
set splitright       "Put vertical splits on the right rather than the left
set splitbelow       "Put horizontal splits on the bottom rather than the top

"===[ Persistant Undos
set undofile

"===[ File navigation

"This does bufdo e without losing highlighting
"TODO: This is slow af. Use asyncrun
"TODO: actually, we're using neovim now. We probably don't need this at all
function EditWithoutLosingSyntax()
    let this_buffer = bufnr("%")
    bufdo set eventignore= | if &buftype != "nofile" && expand("%") != '' | edit | endif
    execute "b" . this_buffer
endfunction
nnoremap <silent> <space>be :call EditWithoutLosingSyntax()<cr>

" When editing a file, always jump to the last known cursor position (if it's
" valid). Ignores commit messages (it's likely a different one than last time).
function! RecallLastPosition()
  if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    exe "normal! g`\""
  endif
endfunction

augroup recall_position
  autocmd!
  autocmd BufReadPost * call RecallLastPosition()
augroup END

"===[ Unsorted

" Sharing is caring - romainl: https://gist.github.com/romainl/1cad2606f7b00088dda3bb511af50d53
command! -range=% IX  <line1>,<line2>w !curl -F 'f:1=<-' ix.io | tr -d '\n' | xclip -i -selection clipboard

set modeline
