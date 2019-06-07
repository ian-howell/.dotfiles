setlocal noexpandtab
setlocal shiftwidth=8

" vim-go messes with 'errorformat', preventing AsyncRun from populating
" the qf window. I don't use those features anyway, so I'll get rid of it
setlocal errorformat&

nnoremap <silent> <buffer> ,gf :GoFmt<CR>
nnoremap <silent> <buffer> ,gi :GoImports<CR>
nmap <silent> <buffer> ,gd <Plug>(go-def-vertical)
let g:go_fmt_autosave = 0
let g:go_mod_fmt_autosave = 0
let g:go_auto_sameids = 1
let g:go_fmt_options = {'gofmt': '-s'}
