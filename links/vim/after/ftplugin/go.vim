setlocal noexpandtab
setlocal shiftwidth=8

" vim-go messes with 'errorformat', preventing AsyncRun from populating
" the qf window. I don't use those features anyway, so I'll get rid of it
setlocal errorformat&
