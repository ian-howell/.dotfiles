if !(exists('g:asyncrun_support'))
  finish
endif

" Fast access to asyncronous background jobs
nnoremap <space>! :AsyncRun<space>
nnoremap <space>/ :AsyncRun! -post=botright\ copen -program=grep --ignore-dir "vendor"<space>
nnoremap <space>* :AsyncRun! -post=botright\ copen -program=grep --ignore-dir "vendor" <cword> -ws<CR>
