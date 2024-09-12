function! buffers#EditWithoutLosingSyntax()
    let this_buffer = bufnr("%")
    bufdo set eventignore= | if &buftype != "nofile" && expand("%") != '' | edit! | endif
    execute "b" . this_buffer
endfunction

function! buffers#Pclose()
    for i in range(1, winnr('$'))
        let bnum = winbufnr(i)
        if getbufvar(bnum, '&buftype') == 'nofile'
            execute "bdelete" . bnum
        endif
    endfor
endfunction
