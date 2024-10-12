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

"===[ Line and column display settings
"== Lines =="
set number             "Show the cursor's current line

" Keep the sign column open at all times
set signcolumn=yes

"===[ Windows and splitting
set splitright       "Put vertical splits on the right rather than the left
set splitbelow       "Put horizontal splits on the bottom rather than the top

"===[ Fix misspellings on the fly
iabbrev          retrun           return
iabbrev           pritn           print
iabbrev           Pritn           Print
iabbrev         Pritnln           Println
iabbrev         printf9           printf(
iabbrev        fprintf9           fprintf(
iabbrev         Printf9           Printf(
iabbrev        Fprintf9           Fprintf(
iabbrev         incldue           include
iabbrev         inculde           include
iabbrev         inlcude           include
iabbrev              ;t           't
iabbrev            ymal           yaml

command! W w
command! Q q
command! QA qa
command! Qa qa
command! W w
command! WQ wq
command! Wq wq
command! WQa wqa
command! Wqa wqa

"===[ Folds
set foldmethod=syntax            "Create folds on syntax
set foldlevel=999                "Start vim with all folds open

"===[ Show undesirable hidden characters
"Show hidden characters
if &modifiable
  set list
endif

set listchars=tab:\ \ ,trail:·

"Show all non-printable characters (ascii index <= 32)
highlight NonPrintableCharacters ctermfg=208 ctermbg=208 cterm=NONE
augroup emphasize_non_printable_characters
  autocmd BufEnter * match NonPrintableCharacters /\b(3[0-1]|[0-2]?[0-9])\b/
augroup END

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

"===[ Quickfix and Location window Shortcuts
" TODO: I think this can be simplified? Look into getqflist()
function ToggleQuickfix()
  for i in range(1, winnr('$'))
    let bnum = winbufnr(i)
    if getbufvar(bnum, '&buftype') == 'quickfix'
      cclose
      return
    endif
  endfor
  botright copen
endfunction
nmap <silent> <space>qt :call ToggleQuickfix()<cr>

" Quickly close all quickfix and location lists
" TODO: I think this might be overkill?
function Pclose()
  for i in range(1, winnr('$'))
    let bnum = winbufnr(i)
    if getbufvar(bnum, '&buftype') == 'nofile'
      execute "bdelete" . bnum
    endif
  endfor
endfunction
nmap <silent> <space>qc :windo lclose \| cclose \| call Pclose()<cr>

"===[ Wildmenu
set wildmenu
set wildmode=longest:full,full
set wildoptions=fuzzy,pum

"===[ Unsorted

" Sharing is caring - romainl: https://gist.github.com/romainl/1cad2606f7b00088dda3bb511af50d53
command! -range=% IX  <line1>,<line2>w !curl -F 'f:1=<-' ix.io | tr -d '\n' | xclip -i -selection clipboard

set modeline
