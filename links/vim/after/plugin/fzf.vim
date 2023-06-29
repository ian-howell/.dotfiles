if !exists('g:loaded_fzf')
  finish
endif

" Remove all the cruft
delcommand FZF
delcommand FzfBTags
delcommand FzfBuffers
delcommand FzfColors
delcommand FzfFiles
delcommand FzfFiletypes
delcommand FzfGitFiles
delcommand FzfGFiles
delcommand FzfHelptags
delcommand FzfLocate
delcommand FzfMaps
delcommand FzfMarks
delcommand FzfRg
delcommand FzfSnippets
delcommand FzfTags
delcommand FzfWindows

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

let gitSource = 'bash -c '.shellescape('comm -3 <(git ls-files --other --exclude-standard --cached | sort) <(git ls-files --deleted --exclude-standard | sort)')
let fileSource = 'fd . --type f --type l'
let allSource = fileSource . ' --hidden --no-ignore'
if git#IsGitRepo()
  " This is madness...
  " The comm command will list all the files tracked by git, excluding any deleted files.
  " However, fzf insists on using sh rather than bash, and the 'command <(other_command)' syntax (Process Substitution)
  " is not POSIX compliant, and doesn't work in sh. So this command will tell sh to run the 'comm' command using bash
  let fzfSource = gitSource

else
  let fzfSource = fileSource
endif

" So this is smart - f* will use git files if in a git repo, and fd files otherwise
nnoremap <silent> <space>ff :call fzf#run(fzf#wrap({'source': fzfSource, 'sink': 'edit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>fv :call fzf#run(fzf#wrap({'source': fzfSource, 'sink': 'vsplit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>fs :call fzf#run(fzf#wrap({'source': fzfSource, 'sink': 'split', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>

nnoremap <silent> <space>FF :call fzf#run(fzf#wrap({'source': allSource, 'sink': 'edit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>FV :call fzf#run(fzf#wrap({'source': allSource, 'sink': 'vsplit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>FS :call fzf#run(fzf#wrap({'source': allSource, 'sink': 'split', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>

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
