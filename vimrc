" Plugins
call plug#begin()

Plug 'romainl/apprentice'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'einfachtoll/didyoumean'
Plug 'wellle/targets.vim'

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'romainl/vim-qf'

Plug 'jsfaint/gen_tags.vim'

if v:version >= 800
    Plug 'skywind3000/asyncrun.vim'

    Plug 'w0rp/ale'
    "Custom signs for gutter
    let g:ale_sign_error = "✗"
    let g:ale_sign_warning = "▲"
endif

call plug#end()

"For filestype specific things (like syntax highlighting)
filetype plugin indent on
"For more matching. See :h matchit
runtime macros/matchit.vim
"End Plugins


"===[ Sane backspace ]==="
set backspace=indent,eol,start


"===[ Colors ]==="
syntax enable
colorscheme apprentice


"===[ Search behaviour ]==="
set incsearch                        "Lookahead as search pattern is specified


"===[ Tab behaviour ]==="
set tabstop=4          "Tabs are equal to 2 spaces
set shiftwidth=4       "Indent/outdent by 2 columns
set shiftround         "Indents always land on a multiple of shiftwidth
set smarttab           "Backspace deletes a shiftwidth's worth of spaces
set expandtab          "Turns tabs into spaces
set autoindent         "Keep the same indentation level when inserting a new line


"===[ Line and column display settings ]==="
"== Lines =="
set nowrap             "Don't word wrap
set relativenumber     "Give a relative number of lines from the cursor
set number             "Show the cursor's current line
set scrolloff=2        "Scroll when 2 lines from top/bottom

"Only turn on relative numbers in the active window
augroup active_relative_number
    autocmd!
    autocmd WinEnter * setlocal number relativenumber
    autocmd WinLeave * setlocal norelativenumber
augroup END

"Highlight the current line
set cursorline
"Only highlight the active window
augroup highlight_follows_focus
    autocmd!
    autocmd WinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
augroup END

"== Columns =="
set sidescroll=1                           "Set horizontal scroll speed
set colorcolumn=80


"=== [ Windows and splitting ]==="
set splitright       "Put vertical splits on the right rather than the left
set splitbelow       "Put horizontal splits on the bottom rather than the top

"Mapping for more convenient 'window mode'
nnoremap <space>w <C-w>


"===[ Miscellaneous key mappings ]==="
inoremap jk <ESC>|              "Shortcut from insert to normal mode
cnoremap jk <C-c>|              "Shortcut from command to normal mode
"Because I'm apparently really bad at keyboards...
inoremap Jk <ESC>
cnoremap Jk <C-c>
inoremap JK <ESC>
cnoremap JK <C-c>
inoremap jK <ESC>
cnoremap jK <C-c>

nnoremap <space>s :source ~/.vimrc<CR>|     "Quickly source vimrc

"Fast bracketing (repeatable)
inoremap {{ {<CR>}<UP><END>

"Yank to EOL like it should
nnoremap Y y$
"Copy to system clipboard
nnoremap <space>y "+y
xnoremap <space>y "+y
"Paste from system clipboard
nnoremap <space>p "+p
nnoremap <space>P "+P
xnoremap <space>p "+p

"Disable help screen on F1
inoremap <F1> <ESC>
nnoremap <F1> <Esc>

inoremap <buffer> </ </<C-x><C-o>|           "Auto-close html tags

"Build or run a project
function! Build()
    if &filetype == "python"
        :AsyncRun python3 %
    elseif &filetype == "cpp" || &filetype == "c"
        :AsyncRun -program=make
    elseif &filetype == "tex"
        :AsyncRun pdflatex -output-directory '%:h' '%'
    endif
endfunction
nnoremap <F5> :call Build()<CR>

"Remove all trailing whitespace from a file
nnoremap <space>ws :%s/\s\+$//<CR>``

"fugitive.vim mappings
nnoremap <space>gst :Gstatus<CR>
nnoremap <space>glo :Glog -10<CR>
nnoremap <space>gdi :Gvdiff<CR>
nnoremap <space>gad :Gwrite<CR>
nnoremap <space>gre :Gread<CR>
nnoremap <space>gco :Gcommit<CR>
nnoremap <space>ged :Gedit<CR>

"Mappings for working with diffs in visual mode
xnoremap <space>do :diffget<CR>
xnoremap <space>dp :diffput<CR>


"===[ Statusline ]==="
"Always show the status line
set laststatus=2

"Custom modified flag
function! Modified()
  if &modified
    return "  ∆ "
  elseif !&modifiable
    return "  ✗ "
  else
    return "    "
  endif
endfunction

"Setup custom colors
hi User1 ctermbg=NONE cterm=bold
hi User2 ctermbg=black

set statusline=                 "Start empty
set statusline+=%2*             "Change color
set statusline+=%{Modified()}   "Mark whether the file is modified, unmodified, or unmobifiable
set statusline+=%1*             "Change color
set statusline+=\ ‹%f›        "File name
set statusline+=%=              "Switch to the right side
set statusline+=%2*             "Change color
set statusline+=\ %3.c          "Current column
set statusline+=\ %P            "Percentage through file
set statusline+=\ %y            "Filetype


"===[ Fix misspellings on the fly ]==="
iabbrev          retrun           return
iabbrev           pritn           print
iabbrev         incldue           include
iabbrev         inculde           include
iabbrev         inlcude           include
iabbrev              ;t           't

command! W w
command! Q q
command! QA qa
command! Qa qa
command! W w
command! WQ wq
command! Wq wq
command! WQa wqa
command! Wqa wqa


"===[ Folds ]==="
set foldmethod=indent            "Create folds on indentation
set foldlevel=999                "Start vim with all folds open


"===[ Show undesirable hidden characters ]==="
"Show hidden characters
if &modifiable
  set list
endif
"Set tabs to a straight line followed by blanks and trailing spaces to dots
set listchars=tab:│\ ,trail:·
"Remove the background highlighting from the above special characters
highlight clear SpecialKey


"===[ Tags ]==="
set tags=./tags;,tags;
" Disable gtags support
let g:loaded_gentags#gtags = 1
" Generate tags automatically (if using git)
let g:gen_tags#ctags_auto_gen = 1
" Use git/tags_dir if using git
let g:gen_tags#use_cache_dir = 0
nnoremap <space>tt :GenCtags<CR>
nnoremap <space>tj :tjump /
nnoremap <space>tp :ptjump /


"===[ Persistant Undos ]==="
set undofile
set undodir=$HOME/.vim/undo


"===[ File navigation ]==="
"Allow changed buffers to be hidden
set hidden

"Recursively search current directory
set path=.,,**

"Shortcut to find files
nnoremap <space>ff :find *
nnoremap <space>fs :sfind *
nnoremap <space>fv :vert sfind *

"Shortcut to find buffers
nnoremap <space>bb :buffer *
nnoremap <space>bs :sbuffer *
nnoremap <space>bv :vert sbuffer *


"===[ Grep customization ]==="
let &grepprg='grep -nrsHI --exclude=tags --exclude-dir=\*venv\* --exclude-dir=.git'
nnoremap <space>/ :AsyncRun! -post=botright\ copen -program=grep<space>
nnoremap <space>* :AsyncRun! -post=botright\ copen -program=grep <cword><CR>


"===[ Quickfix and Location window Shortcuts ]==="
nmap <space>qn <Plug>qf_qf_next
nmap <space>qp <Plug>qf_qf_previous
nmap <space>qq <Plug>qf_qf_switch
nmap <space>qt <Plug>qf_qf_stay_toggle

nmap <space>ln <Plug>qf_loc_next
nmap <space>lp <Plug>qf_loc_previous
nmap <space>lq <Plug>qf_loc_switch
nmap <space>lt <Plug>qf_loc_stay_toggle

"The following setting provides these commands from the quickfix and location windows
" s - open entry in a new horizontal window
" v - open entry in a new vertical window
" t - open entry in a new tab
" o - open entry and come back
" O - open entry and close the location/quickfix window
" p - open entry in a preview window
let g:qf_mapping_ack_style = 1


"===[ Skeleton files ]==="
augroup skeletons
  autocmd!
  autocmd BufNewFile main.* silent! execute '0r ~/.vim/skeletons/skeleton-main.' . expand("<afile>:e")
  autocmd BufNewFile *.* silent! execute '0r ~/.vim/skeletons/skeleton.' . expand("<afile>:e")

  autocmd BufNewFile * %substitute#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
augroup END


"===[ Wildmenu ]==="
set wildmenu
set wildmode=full
set wildignore+=*.o,*.so
set wildignore+=*.d
set wildignore+=*.aux,*.out,*.pdf
set wildignore+=*.pyc,__pycache__
set wildignore+=*.tar,*.gz,*.zip,*.bzip,*.bz2
set wildignore+=tags
set wildignore+=/home/**/*venv*/**
set wildignore+=*.class
set wildignore+=*.png,*.jpg,*.bmp,*.gif
set wildignore+=%*


"===[ Unsorted ]==="
"Don't use swp files
set noswapfile
