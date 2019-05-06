function! buffers#EditAllBuffersAndComeBackWithoutLosingHighlighting()
    let this_buffer = bufnr("%")
    bufdo set eventignore= | if &buftype != "nofile" && expand("%") != '' | edit | endif
    execute "b" . this_buffer
endfunction

nnoremap <Plug>(Refresh) :call buffers#EditAllBuffersAndComeBackWithoutLosingHighlighting()<CR>
