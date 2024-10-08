" Quickly source vimrc
nnoremap <silent> <space>s :source $MYVIMRC<CR>

" Fast, repeatable bracketing
inoremap {{ {<CR>}<UP><END>
inoremap (( (<CR>)<UP><END>
inoremap [[ [<CR>]<UP><END>

" Easier access to system clipboard
map <space>' "+
" Since the above seems to be so flaky and system-dependent, here's another
" quick trick for pasting
nnoremap <silent> <space>pp :set paste<CR>i
" But I don't want to get stuck in paste mode; that's annoying
autocmd InsertLeave * set nopaste

" Remove all trailing blankspaces from a file
function StripTrailingBlankSpaces()
  let l:winview = winsaveview()
  silent! %s/\(\s\|\)\+$//e
  call winrestview(l:winview)
endfunction
nnoremap <silent> <space>ws :call StripTrailingBlankSpaces()<CR>

" Remove all non-printable characters from a file
nnoremap  <space>np :%s/[^!-~ \n\t]//g<CR>

" Jump between function definitions. Taken from :help section
map [[ ?{<CR>w99[{
map ][ /}<CR>b99]}
map ]] j0[[%/{<CR>
map [] k$][%?}<CR>

" Select newly pasted text
nnoremap gV `[v`]

" I frequently try to save while still in insert mode. It's pretty annoying,
" because I usually get all the way to the Enter key before noticing, meaning
" that my cursor drops to the next line and autoindent takes over, and
" recovering is annoying. These mappings serve as a fantastic crutch.
inoremap :w<cr> <esc>:w<cr>
inoremap :wq<cr> <esc>:wq<cr>
inoremap :W<cr> <esc>:w<cr>
inoremap :Wq<cr> <esc>:wq<cr>
inoremap :WQ<cr> <esc>:wq<cr>

" Insert a seperator line
nnoremap <space>= 80i=<esc>

" Zoom in on a specific window, tmux-style
nnoremap <c-w>z ma:tabedit %<cr>`a

" Turn off the help on F1
map <f1> <nop>

" Disable Ex mode
nnoremap Q <nop>
