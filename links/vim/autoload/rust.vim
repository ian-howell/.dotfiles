function! rust#RustFormat()
    " Check that goimports is available
    if !executable('rustfmt')
        echoerr "Could not find rustfmt, please install it"
        return
    endif

    " Save the buffer to file
    write

    " Update the file. This can't be async - I don't want to make any more
    " actions until the file is rewritten
    " The -l flag prints the names of files that were modified
    if (system('rustfmt -l ' . expand('%')) == "")
        " If no files were modified, unrecord this action and stop
        undojoin
        return
    endif

    " Save the current view
    let l:winview = winsaveview()

    " Update the buffer from the file
    edit

    " Restore the view
    call winrestview(l:winview)

endfunction

