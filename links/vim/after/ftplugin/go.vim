setlocal noexpandtab
setlocal shiftwidth=8

nnoremap <silent> <buffer> gdv :vsplit<cr>:GoDef<cr>
nnoremap <silent> <buffer> gds :split<cr>:GoDef<cr>

nnoremap <buffer> ,gi :GoImplements<cr>
nnoremap <buffer> ,gR :GoReferrers<cr>
nnoremap <buffer> ,gr :GoRename<cr><c-f>B
" FZF over all function and type declarations in the current directory.
nnoremap <buffer> ,gt :GoDeclsDir<cr>

let g:go_doc_popup_window = 1
let g:go_list_type="quickfix"
