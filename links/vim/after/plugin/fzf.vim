if !exists('g:loaded_fzf')
  finish
endif

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

if git#IsGitRepo()
  let fzfSource = 'git ls-files -co --exclude-standard'
else
  let fzfSource = 'fd . --type f --type l'
endif

" So this is smart - f* will use git files if in a git repo, and fd files otherwise
nnoremap <silent> <space>ff :call fzf#run({'source': fzfSource, 'sink': 'edit', 'window': 'botright split'})<cr>
nnoremap <silent> <space>fv :call fzf#run({'source': fzfSource, 'sink': 'vsplit', 'window': 'botright split'})<cr>
nnoremap <silent> <space>fs :call fzf#run({'source': fzfSource, 'sink': 'split', 'window': 'botright split'})<cr>

" Shortcut to find buffers
nnoremap <silent> <space>bb :call fzf#run({'source': map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'), 'sink': 'edit', 'window': 'botright split'})<cr>
nnoremap <silent> <space>bs :call fzf#run({'source': map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'), 'sink': 'sbuffer', 'window': 'botright split'})<cr>
nnoremap <silent> <space>bv :call fzf#run({'source': map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'), 'sink': 'vert sbuffer', 'window': 'botright split'})<cr>

" TODO: Implement fzf.vim's Ag function

" The following hides the statusline
augroup fzf
  autocmd!
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup END
