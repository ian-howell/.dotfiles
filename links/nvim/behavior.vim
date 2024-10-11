" vim: foldmethod=marker foldlevel=0
"
" Keymappings {{{1
" ==============================================================================

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

" Search {{{1
" ==============================================================================
"
" Lookahead as search pattern is specified
set incsearch

nnoremap <silent> <space>hl :set hlsearch!<cr>

" Defines an operator that will search for the specified text.
function SetSearch( type )
  let saveZ = @z

  if a:type == 'line'
    '[,']yank z
  elseif a:type == 'block'
    " This is not likely as it can only happen from visual mode, for which the
    " mapping isn't defined anyway
    execute "normal! `[\<c-v>`]\"zy"
  else
    normal! `[v`]"zy
  endif

  " Escape out special characters as well as convert spaces so more than one can
  " be matched.
  let value = substitute( escape( @z, '$*^[]~\/.' ), '\_s\+', '\\_s\\+', 'g' )

  let @/ = value
  let @z = saveZ

  " Add it to the search history.
  call histadd( '/', value )

  set hls
endfunction
nnoremap ,/ :set opfunc=SetSearch<cr>g@"

" Indentation {{{1
" ==============================================================================

" Number of spaces to use for each step of (auto)indent
set shiftwidth=4

" Round indent to multiple of 'shiftwidth'.  Applies to > and <
set shiftround

" A TAB in front of a line inserts blanks according to 'shiftwidth'. A <BS> will
" delete a 'shiftwidth' worth of space at the start of the line
set smarttab

" Use spaces when the TAB key is pressed in insert mode. Spaces are used in
" indents with the '>' and '<' commands and when 'autoindent' is on
set expandtab

" Copy indent from current line when starting a new line
set autoindent
