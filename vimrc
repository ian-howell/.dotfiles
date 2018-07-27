"===[ Plugins
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

Plug 'fatih/vim-go'
Plug 'zchee/deoplete-go'

Plug 'christoomey/vim-tmux-navigator'

if has('python3')
    " Plug 'artur-shaik/vim-javacomplete2'
    Plug 'shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#enable_ignore_case = 1
    let g:deoplete#enable_smart_case = 1
    let g:deoplete#enable_fuzzy_completion = 1
    let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})
    let g:deoplete#omni#input_patterns.java = [
                \'[^. \t0-9]\.\w*',
                \'[^. \t0-9]\->\w*',
                \'[^. \t0-9]\::\w*',
                \'\s[A-Z][a-z]',
                \'^\s*@[A-Z][a-z]'
                \]
    inoremap <expr><C-h> deolete#mappings#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"
endif

if v:version >= 800
    Plug 'skywind3000/asyncrun.vim'

    " Plug 'w0rp/ale'
    "Custom signs for gutter
    " let g:ale_sign_error = "✗"
    " let g:ale_sign_warning = "▲"
endif

call plug#end()

"For filestype specific things (like syntax highlighting)
filetype plugin indent on
"For more matching. See :h matchit
runtime macros/matchit.vim
"End Plugins
"===]
"===[ Colors
syntax enable
colorscheme apprentice
"===]
"===[ Search behaviour
set incsearch                        "Lookahead as search pattern is specified
"Pulled from :help 'incsearch' - highlight all matchs while searching
augroup vimrc-incsearch-highlight
    autocmd!
    autocmd CmdlineEnter /,\? :set hlsearch
    autocmd CmdlineLeave /,\? :set nohlsearch
augroup END
"===]
"===[ Tab behaviour
set tabstop=4          "Tabs are equal to 4 spaces
set shiftwidth=4       "Indent/outdent by 4 columns
set shiftround         "Indents always land on a multiple of shiftwidth
set smarttab           "Backspace deletes a shiftwidth's worth of spaces
set expandtab          "Turns tabs into spaces
" set noexpandtab        "Turns spaces into spaces
set autoindent         "Keep the same indentation level when inserting a new line
"===]
"===[ Line and column display settings
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
set signcolumn=yes                           "Keep the sign column open at all times
"===]
"===[ Windows and splitting
set splitright       "Put vertical splits on the right rather than the left
set splitbelow       "Put horizontal splits on the bottom rather than the top

"Mapping for more convenient 'window mode'
nnoremap <space>w <C-w>

nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
nnoremap <silent> <c-\> :TmuxNavigatePrevious<cr>
"===]
"===[ Miscellaneous key mappings
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

"Quickly source vimrc
nnoremap <space>s :source ~/.vimrc<CR>

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

nnoremap <F5> :call build#Build()<CR>

"Remove all trailing whitespace from a file
nnoremap <space>ws :%s/\s\+$//<CR>``

"Sane paragraph boundaries
nnoremap <silent> { :<C-u>call ipmotion#MyPrevParagraph()<CR>
nnoremap <silent> } :<C-u>call ipmotion#MyNextParagraph()<CR>
xnoremap <silent> { :<C-u>exe "normal! gv"<Bar>call ipmotion#MyPrevParagraph()<CR>
xnoremap <silent> } :<C-u>exe "normal! gv"<Bar>call ipmotion#MyNextParagraph()<CR>

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

"Turn the mouse on
set mouse=n
"Mappings to make the scrollwheel work as expected
noremap <ScrollWheelUp> 2<C-Y>
noremap <ScrollWheelDown> 2<C-E>
noremap <C-ScrollWheelUp> 5zh
noremap <C-ScrollWheelDown> 5zl
"Unmap all the useless mouse actions
noremap <LeftMouse> <nop>
noremap <RightMouse> <nop>
noremap <2-LeftMouse> <nop>
noremap <2-RightMouse> <nop>
noremap <3-LeftMouse> <nop>
noremap <3-RightMouse> <nop>
inoremap <LeftMouse> <nop>
inoremap <RightMouse> <nop>
inoremap <2-LeftMouse> <nop>
inoremap <2-RightMouse> <nop>
inoremap <3-LeftMouse> <nop>
inoremap <3-RightMouse> <nop>
"but we can use this for convenient window swapping
noremap <space>w<LeftMouse> <LeftMouse>

"Tab complete with tab key
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"

nnoremap <space>x :r !ascii -ts <c-r><c-w> \| cut -f2 -d'x' \| cut -f1 -d' ' \| tr -d '\n'<cr>
"===]
"===[ Statusline
"Always show the status line
set laststatus=2

"Setup custom colors
hi User1 ctermbg=NONE cterm=bold
hi User2 ctermbg=grey ctermfg=black

set statusline=                            "Start empty
set statusline+=%2*                        "Change color
set statusline+=%{statusline#Modified()}   "Mark whether the file is modified, unmodified, or unmobifiable
set statusline+=\ ‹%f›                     "File name
set statusline+=%=                         "Switch to the right side
set statusline+=\ %3.c                     "Current column
set statusline+=\ %P                       "Percentage through file
set statusline+=\ %y                       "Filetype

"Finally, turn off the titlebar
set notitle
"===]
"===[ Fix misspellings on the fly
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
"===]
"===[ Folds
set foldmethod=syntax            "Create folds on syntax
set foldlevel=999                "Start vim with all folds open
set foldtext=folding#MyFoldText()
"===]
"===[ Show undesirable hidden characters
"Show hidden characters
if &modifiable
  set list
endif
" Actually, don't
" set nolist
"Set tabs to a straight line followed by blanks and trailing spaces to dots
set listchars=tab:│\ ,trail:·
"Remove the background highlighting from the above special characters
highlight clear SpecialKey
"===]
"===[ Tags
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
"===]
"===[ Persistant Undos ]==="
set undofile
set undodir=$HOME/.vim/undo
"===]
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
"===]
"===[ Grep customization ]==="
let &grepprg='grep -nrsHI --exclude=tags --exclude-dir=\*venv\* --exclude-dir=.git'
nnoremap <space>/ :AsyncRun! -post=botright\ copen -program=grep<space>
nnoremap <space>* :AsyncRun! -post=botright\ copen -program=grep <cword><CR>
"===]
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

"Automatically open the quickfix list
"TODO: Fix this
let g:qf_auto_open_quickfix = 1
"===]
"===[ Skeleton files
augroup skeletons
  autocmd!
  autocmd BufNewFile main.* silent! execute '0r ~/.vim/skeletons/skeleton-main.' . expand("<afile>:e")
  autocmd BufNewFile *.* silent! execute '0r ~/.vim/skeletons/skeleton.' . expand("<afile>:e")

  autocmd BufNewFile * %substitute#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
augroup END
"===]
"===[ Wildmenu
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
" set wildignore+=*.html  " Comment this out for html, obviously
set wildignore+=TEST-*,org.onap.*.txt
set wildignore+=%*
"===]
"===[ Unsorted
"Sane backspace
set backspace=indent,eol,start
"Don't use swp files
set noswapfile
"Get out of visual mode faster
set ttimeoutlen=0
set modelines=1
"===]
" vim:foldmethod=marker:foldlevel=0:foldmarker====[,===]
