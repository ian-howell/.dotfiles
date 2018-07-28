
set incsearch                        "Lookahead as search pattern is specified

set tabstop=4          "Tabs are equal to 4 spaces
set shiftwidth=4       "Indent/outdent by 4 columns
set shiftround         "Indents always land on a multiple of shiftwidth
set smarttab           "Backspace deletes a shiftwidth's worth of spaces
" set expandtab          "Turns tabs into spaces
set noexpandtab        "Turns spaces into spaces
set autoindent         "Keep the same indentation level when inserting a new line

"== Lines =="
set nowrap             "Don't word wrap
set number             "Show the cursor's current line
set scrolloff=2        "Scroll when 2 lines from top/bottom
set sidescroll=1                           "Set horizontal scroll speed

set splitright       "Put vertical splits on the right rather than the left
set splitbelow       "Put horizontal splits on the bottom rather than the top

"Mapping for more convenient 'window mode'
nnoremap <space>w <C-w>

"Shortcut from insert to normal mode
inoremap jk <ESC>
inoremap j: <ESC>
inoremap k: <ESC>
"Shortcut from command to normal mode
cnoremap jk <C-c>
"Because I'm apparently really bad at keyboards...
inoremap Jk <ESC>
cnoremap Jk <C-c>
inoremap JK <ESC>
cnoremap JK <C-c>
inoremap jK <ESC>
cnoremap jK <C-c>

"Fast bracketing (repeatable)
inoremap {{ {<CR>}<UP><END>

"Yank to EOL like it should
nnoremap Y y$

"Always show the status line
set laststatus=2

"Setup custom colors
hi User1 ctermbg=NONE cterm=bold
hi User2 ctermbg=grey ctermfg=black

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

set statusline=                            "Start empty
set statusline+=%2*                        "Change color
set statusline+=%{Modified()}              "Mark whether the file is modified, unmodified, or unmobifiable
set statusline+=\ ‹%f›                     "File name
set statusline+=%=                         "Switch to the right side
set statusline+=\ %3.c                     "Current column
set statusline+=\ %P                       "Percentage through file
set statusline+=\ %y                       "Filetype

"Finally, turn off the titlebar
set notitle

command! W w
command! Q q
command! QA qa
command! Qa qa
command! W w
command! WQ wq
command! Wq wq
command! WQa wqa
command! Wqa wqa

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
nnoremap <space>bn :bnext<cr>
nnoremap <space>bp :bprevious<cr>
nnoremap <space>bf :bfirst<cr>
nnoremap <space>bl :blast<cr>
"
"Shortcut to find tabs
nnoremap <space>tt :tabf *
nnoremap <space>tn :tabnext<cr>
nnoremap <space>tp :tabprevious<cr>
nnoremap <space>tf :tabfirst<cr>
nnoremap <space>tl :tablast<cr>


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

"Sane backspace
set backspace=indent,eol,start
"Don't use swp files
set noswapfile
"Get out of visual mode faster
set ttimeoutlen=0
