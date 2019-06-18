setlocal noexpandtab
setlocal shiftwidth=8

if !exists("g:go_loaded_install")
  finish
endif

" vim-go messes with 'errorformat', preventing AsyncRun from populating
" the qf window. I don't use those features anyway, so I'll get rid of it
setlocal errorformat&

nnoremap <silent> <buffer> ,gi :GoImports<CR>:GoFmt<CR>
nmap <silent> <buffer> ,gd <Plug>(go-def-vertical)
let g:go_fmt_autosave = 0
let g:go_mod_fmt_autosave = 0
let g:go_auto_sameids = 1
let g:go_fmt_options = {'gofmt': '-s'}
let g:go_fmt_experimental = 1
