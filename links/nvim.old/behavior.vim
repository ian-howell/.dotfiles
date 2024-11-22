" vim: foldmethod=marker foldlevel=0

" Turn on modelines so that the thing at the top of the file works
set modeline

" Put vertical splits on the right rather than the left
set splitright
" Put horizontal splits on the bottom rather than the top
set splitbelow

" Make the undo tree persist across vim instances
set undofile

" Sharing is caring - romainl: https://gist.github.com/romainl/1cad2606f7b00088dda3bb511af50d53
command! -range=% IX  <line1>,<line2>w !curl -F 'f:1=<-' ix.io | tr -d '\n' | xclip -i -selection clipboard

" Keymappings {{{1
" ==============================================================================

" Quickly source vimrc
nnoremap <silent> <space>s :source $MYVIMRC<CR>

nnoremap <space>- :split<CR>
nnoremap <space>\ :vsplit<CR>

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

" Columns {{{1
" ==============================================================================

" Don't word wrap
set nowrap

" Every wrapped line will continue visually indented (same amount of space as
" the beginning of that line), thus preserving horizontal blocks of text.
set breakindent

" The minimal number of columns to scroll horizontally.
set sidescroll=1

" Maximum width of text that is being inserted. A longer line will be broken
" after white space to get this width. A zero value disables this.
set textwidth=80

" This is a sequence of letters which describes how automatic formatting is to
" be done.
" The following are set here, but note that other values may be added by an
" ftplugin:
"
" c     Auto-wrap comments using 'textwidth', inserting the current comment
"       leader automatically.
"
" q     Allow formatting of comments with "gq".
"       Note that formatting will not change blank lines or lines containing
"       only the comment leader.  A new paragraph starts after such a line,
"       or when the comment leader changes.
"
" n     When formatting text, recognize numbered lists.  The indent of the text
"       after the number is used for the next line.  The default is to find a
"       number, optionally followed by '.', ':', ')', ']' or '}'.
"
" l     Long lines are not broken in insert mode: When a line was longer than
"       'textwidth' when the insert command started, Vim does not automatically
"       format it
"
" j     Where it makes sense, remove a comment leader when joining lines
set formatoptions=cqnlj

" Don't mess with the EOL characters at the end of a file
set nofixendofline

" Quickfix and Location list windows {{{1
" ==============================================================================

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

" Recall last position in a file 1{{{
"===============================================================================

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
