setlocal noexpandtab
setlocal shiftwidth=8

nnoremap <silent> <buffer> ,gdd :GoDef<cr>
nnoremap <silent> <buffer> ,gdv :vs <bar> :GoDef<cr>
nnoremap <silent> <buffer> ,gds :sp <bar> :GoDef<cr>

nnoremap <buffer> ,gi :GoImplements<cr>
nnoremap <buffer> ,gR :GoReferrers<cr>
nnoremap <buffer> ,gr :GoRename<cr><c-f>B

" FZF over all function and type declarations in the current directory.
nnoremap <buffer> ,dd :GoDeclsDir<cr>
nnoremap <buffer> ,dv :vs <bar> GoDeclsDir<cr>
nnoremap <buffer> ,ds :sp <bar> GoDeclsDir<cr>

let g:go_doc_popup_window = 1
let g:go_list_type="quickfix"
