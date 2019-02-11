set tabstop=4
set noexpandtab

" vim-go messes with 'errorformat', preventing AsyncRun from populating
" the qf window
nnoremap <space>/ :silent grep  \| botright copen \| redraw!<left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left>
nnoremap <space>* :silent grep <cword> \| botright copen \| redraw!<CR>
