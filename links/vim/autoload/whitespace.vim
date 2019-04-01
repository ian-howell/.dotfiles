function! whitespace#StripTrailingWhiteSpace()
    let l:winview = winsaveview()
    silent! %s/\s\+$//e
    call winrestview(l:winview)
endfunction
