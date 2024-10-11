" Notes on vimscript style:
"
" Typically, vimscript (and blankspace) should be Pythonic.
"
" In general, use plugin-names-like-this, FunctionNamesLikeThis,
" CommandNamesLikeThis, augroup_names_like_this, variable_names_like_this.

source ~/.config/nvim/helperfunctions.vim
source ~/.config/nvim/pluginconfigs/plugins.vim
source ~/.config/nvim/behavior.vim

"===[ Colors
syntax enable

" This is such a hack: set the colorscheme to torte, then set it to apprentice.
" If setting it to apprentice fails, it will do so quietly. This is important
" when installing plugins with 'vim +PlugInstall +qall'
colorscheme torte
silent! colorscheme apprentice

"Show all non-printable characters (ascii index <= 32)
highlight NonPrintableCharacters ctermfg=208 ctermbg=208 cterm=NONE
augroup emphasize_non_printable_characters
  autocmd BufEnter * match NonPrintableCharacters /\b(3[0-1]|[0-2]?[0-9])\b/
augroup END

"===[ Search behaviour
set incsearch                        "Lookahead as search pattern is specified

" TODO: I think I want to delete this
"Pulled from :help 'incsearch' - highlight all matches while searching
augroup vimrc_incsearch_highlight
    autocmd!
    autocmd CmdlineEnter /,\? :set hlsearch
    autocmd CmdlineLeave /,\? :set nohlsearch
augroup END

nnoremap <space>hl :set hlsearch! hlsearch?<cr>

" Defines an operator that will search for the specified text.
function SetSearch( type )
  let saveZ = @z

  if a:type == 'line'
    '[,']yank z
  elseif a:type == 'block'
    " This is not likely as it can only happen from visual mode, for which the mapping isn't defined anyway
    execute "normal! `[\<c-v>`]\"zy"
  else
    normal! `[v`]"zy
  endif

  " Escape out special characters as well as convert spaces so more than one can be matched.
  let value = substitute( escape( @z, '$*^[]~\/.' ), '\_s\+', '\\_s\\+', 'g' )

  let @/ = value
  let @z = saveZ

  " Add it to the search history.
  call histadd( '/', value )

  set hls
endfunction
nnoremap ,/ :set opfunc=SetSearch<cr>g@

"===[ Tab behaviour
set shiftwidth=4       "Indent/outdent by 4 columns
set shiftround         "Indents always land on a multiple of shiftwidth
set smarttab           "Backspace deletes a shiftwidth's worth of spaces
set expandtab          "Turns tabs into spaces
set autoindent         "Keep the same indentation level when inserting a new line

"===[ Line and column display settings
"== Lines =="
set nowrap             "Don't word wrap
set breakindent        "However, if I *do* turn on wrap, I'd like to keep the same level of indentation
set number             "Show the cursor's current line

"Highlight the current line, column, and the 80th column
setlocal cursorline
setlocal cursorcolumn
setlocal colorcolumn=80
hi CursorLine ctermbg=236
hi CursorColumn ctermbg=236

" Background colors for active vs inactive windows
" Note that "black" means the same as "transparent"
" TODO: notermguicolors is fine for now, but it's probably pretty limiting...
set notermguicolors
hi link ActiveWindow Normal
hi InactiveWindow ctermbg=black

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

"Only highlight the active window
augroup highlight_follows_focus
  autocmd!
  autocmd WinEnter,FocusGained * call HandleFocusEnter()
  autocmd WinLeave,FocusLost * call HandleFocusLeave()
augroup END


"== Columns =="
" sidescroll has some sort of issue with ALE, in which a line with an error or warning fails to render when
" scrolling. I'm leaving it commented out here so I don't accidentally turn it back on in the future
" set sidescroll=1            "Set horizontal scroll speed
set textwidth=80            "gq will wrap text at 80, same as colorcolumn
set formatoptions=cqlMj     "In order: wrap comments automatically, allow 'gq' to work on comments,
                            "don't break long lines in insert mode, don't insert space when 'J'oining,
                            "remove comment leaders when 'J'oining lines
set signcolumn=yes          "Keep the sign column open at all times
set nostartofline           "Prevent the cursor fom changing columns when jumping

"===[ Windows and splitting
set splitright       "Put vertical splits on the right rather than the left
set splitbelow       "Put horizontal splits on the bottom rather than the top

"===[ Mouse
"Make sure the mouse is off, even in gui environments
set mouse=
"Mappings to make the scrollwheel work as expected
noremap <ScrollWheelUp> 2<C-Y>
noremap <ScrollWheelDown> 2<C-E>
noremap <C-ScrollWheelUp> 5zh
noremap <C-ScrollWheelDown> 5zl
"Unmap all the useless mouse actions
noremap <LeftMouse> <nop>
noremap <RightMouse> <nop>
"but we can use this for convenient window swapping
noremap <C-LeftMouse> <LeftMouse>


"===[ Statusline

"Custom modified flag
function FileModified()
  if &modified
    return "  ∆ "
  elseif !&modifiable
    return "  ✗ "
  else
    return "    "
  endif
endfunction

" TODO: This isn't used, but it's kinda neat. Let's work it in somehow
"Custom git branch flag
function GitBranch()
  if !IsGitRepo() || !&modifiable
    return ""
  endif
  let branch = FugitiveHead()
  if len(branch)
    return " «" . branch . "»"
  endif
  return " «detached HEAD»"
endfunction

"Always show the status line
set laststatus=2

set statusline=                            "Start empty
set statusline+=%{FileModified()}   "Mark whether the file is modified, unmodified, or unmodifiable
set statusline+=\ ‹%f›                     "File name
set statusline+=%=                         "Switch to the right side
set statusline+=\ L%l                      "Current line
set statusline+=\ C%c                      "Current column
set statusline+=\ %P                       "Percentage through file
set statusline+=\ %y                       "Filetype

"Finally, turn off the titlebar
set notitle

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

let g:my_listchars_toggle = 0
function ToggleIndentationLines()
  if g:my_listchars_toggle == 1
    set listchars=tab:\ \ ,trail:·
  else
    "Set tabs to a straight line followed by blanks and trailing spaces to dots
    set listchars=tab:│\ ,trail:·
  endif
  let g:my_listchars_toggle = !g:my_listchars_toggle
endfunction
command TIL call ToggleIndentationLines()

"Remove the background highlighting from the above special characters
highlight clear SpecialKey

"===[ Tags
set tags=./tags;,tags;
nnoremap <space>tj :tjump /
nnoremap <space>tp :ptjump /

"===[ Persistant Undos
set undofile
" TODO: fix this
set undodir=$HOME/.vim/undo

"===[ File navigation
"Allow changed buffers to be hidden
set hidden

"Recursively search current directory
set path=.,,**

nnoremap <silent> <space>bn :bnext<cr>
nnoremap <silent> <space>bp :bprevious<cr>
nnoremap <silent> <space>bf :bfirst<cr>
nnoremap <silent> <space>bl :blast<cr>

"This does bufdo e without losing highlighting
"TODO: This is slow af. Use asyncrun
"TODO: actually, we're using neovim now. We probably don't need this at all
function EditWithoutLosingSyntax()
    let this_buffer = bufnr("%")
    bufdo set eventignore= | if &buftype != "nofile" && expand("%") != '' | edit | endif
    execute "b" . this_buffer
endfunction
nnoremap <silent> <space>be :call EditWithoutLosingSyntax()<cr>

augroup recall_position
  autocmd!
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid, when inside an event handler
  " (happens when dropping a file on gvim) and for a commit message (it's
  " likely a different one than last time).
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif
augroup END

"===[ Grep customization
if executable('ag')
  let &grepprg='ag'
endif

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
set wildignore+=*.o,*.so
set wildignore+=*.d
set wildignore+=*.aux,*.out,*.pdf
set wildignore+=*.pyc,__pycache__
set wildignore+=*.tar,*.gz,*.zip,*.bzip,*.bz2
set wildignore+=tags
set wildignore+=/home/**/*venv*/**
set wildignore+=*.class
set wildignore+=*.png,*.jpg,*.bmp,*.gif
set wildignore+=*.html  " Comment this out for html, obviously
set wildignore+=*.doctree
set wildignore+=%*

"===[ Diffs
set diffopt+=algorithm:histogram,indent-heuristic

"Remove the dashes from DiffDelete. Mind the trailing space
set fillchars+=diff:\

"===[ Unsorted
"Sane backspace
set backspace=indent,eol,start
"Don't use swp files
set noswapfile
"Get out of visual mode faster
set ttimeoutlen=0
" Update faster. This is used for a handful of plugins (like git-gutter)
set updatetime=750
" Only redraw the screen when needed - this works for macros and mappings
set lazyredraw
" Sharing is caring - romainl: https://gist.github.com/romainl/1cad2606f7b00088dda3bb511af50d53
command! -range=% IX  <line1>,<line2>w !curl -F 'f:1=<-' ix.io | tr -d '\n' | xclip -i -selection clipboard
" Clipboard hacks - By default, vim clears out the system and X clipboards
" upon closing. This fixes that
augroup clipboard_retention
  autocmd!
  autocmd VimLeave * call system("xclip -i -selection primary", getreg('*'))
  autocmd VimLeave * call system("xclip -i -selection clipboard", getreg('+'))
augroup END
" Allow tons of tabs. This is useful for git-vimdiff
set tabpagemax=99

" TODO: This is a vim setting - figure out the neovim equivalent
" set completeopt=menu,menuone,popup

" Don't mess with the EOL characters at the end of a file
set nofixendofline

set modeline
