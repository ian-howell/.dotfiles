" vim: foldmethod=marker foldlevel=0

" Show the line number column
set number

" Keep the sign column open at all times
set signcolumn=yes

" Colorscheme {{{1
" ==============================================================================

" If setting the colorscheme fails, it will do so quietly. This is important
" when installing plugins with 'vim +PlugInstall +qall'
silent! colorscheme nord

" Focus {{{1
" ==============================================================================

" Highlight the current line, column, and the 80th column
setlocal cursorline
setlocal cursorcolumn
setlocal colorcolumn=80

" Make the colorcolumn a little less intrusive (default is white)
hi link ColorColumn CursorColumn

" Background colors for active vs inactive windows
set termguicolors
hi link ActiveWindow Normal
" InactiveWindow is a darker shade of the default nord background color
hi InactiveWindow guibg=#262a32

" Normally, I could just do this:
"   set winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow
" But since vim always has an "active" window, even if I've switched to a
" different tmux pane, I need to use autocmds to change the highlight groups
" based on focus.

" Change highlight group of active/inactive windows
function HandleFocusEnter()
  setlocal cursorline
  setlocal cursorcolumn
  setlocal colorcolumn=80
  setlocal winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow
endfunction

" Change highlight group of active/inactive windows
function HandleFocusLeave()
  setlocal nocursorline
  setlocal nocursorcolumn
  setlocal colorcolumn=
  setlocal winhighlight=Normal:InactiveWindow,NormalNC:InactiveWindow
endfunction

" Only highlight the active window
augroup highlight_follows_focus
  autocmd!
  autocmd BufEnter,WinEnter,FocusGained * call HandleFocusEnter()
  autocmd BufLeave,WinLeave,FocusLost * call HandleFocusLeave()
augroup END

" Statusline {{{1
" ==============================================================================

function FileModified()
  if &modified
    return "  ∆ "
  elseif !&modifiable
    return "  ✗ "
  endif
  return "    "
endfunction

" Left side looks like:
" $modified_status ‹$filename›
" TODO: git branch could be cool here
let s:left_statusline = ''
let s:left_statusline .= '%{FileModified()}'
let s:left_statusline .= ' ‹%f›'

" Right side looks like:
" L$lineNo C$colNo $percent $filetype
let s:right_statusline = ''
let s:right_statusline .= ' L%l'
let s:right_statusline .= ' C%c'
let s:right_statusline .= ' %P'
let s:right_statusline .= ' %y'

let &statusline = s:left_statusline . '%=' . s:right_statusline

" Invisible characters {{{1
" ==============================================================================

" Turn on printing of blank spaces, but don't show tabs, only trailing spaces.
set list listchars=tab:\ \ ,trail:·

" Highlight non-printable characters as "horrible orange" (ascii index <= 32)
" TODO: Figure out the gui color for this
highlight NonPrintableCharacters ctermfg=208 ctermbg=208 cterm=NONE
augroup emphasize_non_printable_characters
  autocmd BufEnter * match NonPrintableCharacters /\b(3[0-1]|[0-2]?[0-9])\b/
augroup END
