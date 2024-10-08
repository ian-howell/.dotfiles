"===[ Plugins
call plug#begin('~/.config/nvim/plugged')

" Colorschemes
Plug 'romainl/Apprentice'

function! ApprenticeOverrides() abort
    hi DiffAdd ctermbg=238 ctermfg=NONE cterm=NONE guibg=#444444 guifg=NONE gui=NONE
    hi DiffChange ctermbg=250 ctermfg=238 cterm=reverse guibg=#bcbcbc guifg=#444444 gui=reverse
    hi DiffDelete ctermbg=52 ctermfg=52 cterm=NONE guibg=#5f0000 guifg=NONE gui=NONE
    hi DiffText ctermbg=235 ctermfg=110 cterm=reverse guibg=#262626 guifg=#8fafd7 gui=reverse
endfunction

augroup apprentice_overrides
    autocmd!
    autocmd ColorScheme apprentice call ApprenticeOverrides()
augroup END

" Things that should be built in
Plug 'tpope/vim-surround'
" This isn't working with vim-go
" Plug 'tpope/vim-repeat'

" TODO: This appears to be deprecated by :help commenting
Plug 'tpope/vim-commentary'
Plug 'wellle/targets.vim'
Plug 'wellle/context.vim'

" Git
Plug 'tpope/vim-fugitive'
nnoremap <silent> <space>gst :Gstatus<CR>
nnoremap <silent> <space>glo :Glog -10<CR>
nnoremap <silent> <space>gdi :Gvdiff<CR>
nnoremap <silent> <space>gad :Gwrite<CR>
nnoremap <silent> <space>gre :Gread<CR>
nnoremap <silent> <space>gco :Gcommit<CR>
nnoremap <silent> <space>ged :Gedit<CR>




Plug 'airblade/vim-gitgutter'

" Assorted
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Prefix all of the fzf commands to make them easier to 'browse'
let g:fzf_command_prefix = "Fzf"
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" TODO: I don't know who wrote this*, but it's psychotic. Please fix it.
" *it was me, I wrote it
let git_source = 'bash -c '.shellescape('comm -3 <(git ls-files --other --exclude-standard --cached | sort) <(git ls-files --deleted --exclude-standard | sort)')
let file_source = 'fd . --type f --type l'
let all_source = file_source . ' --hidden --no-ignore'
if IsGitRepo()
  " This is madness...
  " The comm command will list all the files tracked by git, excluding any deleted files.
  " However, fzf insists on using sh rather than bash, and the 'command <(other_command)' syntax (Process Substitution)
  " is not POSIX compliant, and doesn't work in sh. So this command will tell sh to run the 'comm' command using bash
  let fzf_source = git_source
else
  let fzf_source = file_source
endif

" So this is smart - f* will use git files if in a git repo, and fd files otherwise
nnoremap <silent> <space>ff :call fzf#run(fzf#wrap({'source': fzf_source, 'sink': 'edit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>fv :call fzf#run(fzf#wrap({'source': fzf_source, 'sink': 'vsplit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>fs :call fzf#run(fzf#wrap({'source': fzf_source, 'sink': 'split', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>

nnoremap <silent> <space>FF :call fzf#run(fzf#wrap({'source': all_source, 'sink': 'edit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>FV :call fzf#run(fzf#wrap({'source': all_source, 'sink': 'vsplit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>FS :call fzf#run(fzf#wrap({'source': all_source, 'sink': 'split', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>

" Shortcut to find buffers
nnoremap <silent> <space>bb :call fzf#run(fzf#wrap({'source': map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'), 'sink': 'edit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>bs :call fzf#run(fzf#wrap({'source': map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'), 'sink': 'sbuffer', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>bv :call fzf#run(fzf#wrap({'source': map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'), 'sink': 'vert sbuffer', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>

" Git shortcuts
nnoremap <space>gcc :FzfCommits<cr>
nnoremap <space>gcb :FzfBCommits<cr>
nnoremap <space><space>gst :call fzf#vim#gitfiles('?')<cr>

" Search/history shortcuts
nnoremap <space><space>/ :FzfAg<cr>
nnoremap q: :call fzf#vim#command_history()<cr>
nnoremap q/ :call fzf#vim#search_history()<cr>

" assorted shortcuts
nnoremap <space>ll :FzfLines<cr>
nnoremap <space>lb :FzfBLines<cr>
nnoremap <space>: :FzfCommands<cr>

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)





Plug 'jabirali/vim-tmux-yank'

Plug 'christoomey/vim-tmux-navigator'
nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
nnoremap <silent> <c-\> :TmuxNavigatePrevious<cr>


Plug 'skywind3000/asyncrun.vim'
" Fast access to asyncronous background jobs
nnoremap <space>! :AsyncRun<space>
nnoremap <space>/ :AsyncRun! -post=botright\ copen -program=grep --ignore-dir "vendor"<space>
nnoremap <space>* :AsyncRun! -post=botright\ copen -program=grep --ignore-dir "vendor" <cword> -ws<CR>







" TODO: check how much of this is still needed with neovim's LSP support
Plug 'dense-analysis/ale'
"Always show the gutter
let g:ale_sign_column_always = 1

"Stop linting 'on the fly' in insert mode
let g:ale_lint_on_text_changed = 'normal'
"I'd rather lint when we leave insert mode
let g:ale_lint_on_insert_leave = 1

"Custom signs for gutter
" TODO: Figure these out
" let g:ale_sign_error = "❌"
" let g:ale_sign_warning = "⚠️"
" let g:ale_sign_info = "ℹ️"
let g:ale_sign_error = "✗"
let g:ale_sign_warning = "∆"
let g:ale_sign_info = "ⅰ"

highlight ALEErrorSign ctermfg=red
highlight ALEWarningSign ctermfg=yellow
highlight ALEInfoSign ctermfg=cyan

" Show popups on hover
let g:ale_floating_preview = 1
" Since vim's default uses nice unicode characters when possible, you can trick
" ale into using that default with
let g:ale_floating_window_border = repeat([''], 6)

set omnifunc=ale#completion#OmniFunc

let g:ale_linters = {
      \ 'go': [
        \ 'golangci-lint',
        \ 'go build',
        \ 'gopls',
        \],
      \}

" I don't really care to lint yaml
let g:ale_linters_ignore = {'yaml': ['yamllint']}

" Turn linting errors into warnings
let g:ale_type_map = {
      \ 'flake8': {'ES': 'WS', 'E': 'W'},
      \ 'golangci-lint': {'ES': 'WS', 'E': 'W'},
      \}

" let ale know that we're using python3
let g:ale_python_flake8_executable = 'python3'
let g:ale_python_flake8_options = '-m flake8'

let g:ale_go_golangci_lint_package = 1
let g:ale_go_golangci_lint_options = '--config ~/.golangci.yaml'

let g:ale_sh_shellcheck_exclusions = 'SC1090'




" TODO: check how much of this is still needed with neovim's LSP support
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
let g:go_fmt_fail_silently = 1

packadd cfilter
nnoremap <space>q/ :Cfilter //<Left>
nnoremap <space>q! :Cfilter! //<Left>
nnoremap <space>qx :Cfilter! /mock\\|test/<cr>

" TODO: I doubt I need any of vim-qf with neovim
" I need to revisit whether I need vim-qf anymore now that cfilter exists, but I have a retro in 5 minutes, so
" that'll be future Ian's problem
Plug 'romainl/vim-qf'

nmap <space>qn <Plug>(qf_qf_next)
nmap <space>qp <Plug>(qf_qf_previous)
nmap <space>qq <Plug>(qf_qf_switch)

nmap <space>ln <Plug>(qf_loc_next)
nmap <space>lp <Plug>(qf_loc_previous)
nmap <space>lq <Plug>(qf_loc_switch)
nmap <space>lt <Plug>(qf_loc_toggle)

"The following setting provides these commands from the quickfix and location windows
" s - open entry in a new horizontal window
" v - open entry in a new vertical window
" t - open entry in a new tab
" o - open entry and come back
" O - open entry and close the location/quickfix window
" p - open entry in a preview window
let g:qf_mapping_ack_style = 1

let g:qf_auto_open_quickfix = 0

" This doesn't quite work the way I like it
" nmap <space>qt <Plug>(qf_qf_toggle)
" Use my own instead




Plug 'github/copilot.vim'
" The following 2 lines need to stay together; Combinded, they replace 'Tab' with <c-e> to accept a suggestion
imap <silent><script><expr> <C-E> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

imap <C-J> <Plug>(copilot-next)
imap <C-K> <Plug>(copilot-previous)
imap <C-L> <Plug>(copilot-accept-word)

" Enable copilot for all filetypes
let b:copilot_enabled = v:true

call plug#end()

"For more matching. See :h matchit
runtime macros/matchit.vim

