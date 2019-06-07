if !exists('g:loaded_fugitive')
  finish
endif

nnoremap <silent> <space>gst :Gstatus<CR>
nnoremap <silent> <space>glo :Glog -10<CR>
nnoremap <silent> <space>gdi :Gvdiff<CR>
nnoremap <silent> <space>gad :Gwrite<CR>
nnoremap <silent> <space>gre :Gread<CR>
nnoremap <silent> <space>gco :Gcommit<CR>
nnoremap <silent> <space>ged :Gedit<CR>
