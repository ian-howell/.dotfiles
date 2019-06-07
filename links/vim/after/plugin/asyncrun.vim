if !(exists('g:asyncrun_support'))
  finish
endif

" Fast access to asyncronous background jobs
nnoremap <space>! :AsyncRun<space>
nnoremap <space>/ :AsyncRun! -post=botright\ copen -program=grep<space>
nnoremap <space>* :AsyncRun! -post=botright\ copen -program=grep <cword><CR>
