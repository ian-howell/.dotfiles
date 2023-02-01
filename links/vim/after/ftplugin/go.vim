setlocal noexpandtab
setlocal shiftwidth=8

nnoremap <silent> <buffer> ,gi :call fmt#Format('goimports', '-d -w')<cr>
nnoremap <silent> <buffer> ,gdv :vsplit<cr>:GoDef<cr>
nnoremap <silent> <buffer> ,gds :split<cr>:GoDef<cr>
let g:go_doc_popup_window = 1
let g:go_list_type="quickfix"
