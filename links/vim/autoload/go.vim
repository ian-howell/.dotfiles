function! go#GoImports()
    " Check that goimports is available
    if !executable('goimports')
        echoerr "Could not find goimports, please install it"
        return
    endif

    " Save the buffer to file
    write

    " First, check if there are any issues
    if (system('goimports -d ' . expand('%')) == "")
        " If not, unrecord this action and stop
        undojoin
        return
    endif

    " Save the current view
    let l:winview = winsaveview()

    " Update the file. Use AsyncRun if possible
    if exists('g:asyncrun_support')
        AsyncRun goimports -w %
    else
        silent !goimports -w %
        silent redraw!
    endif

    " Update the buffer from the file
    edit

    " Restore the view
    call winrestview(l:winview)
endfunction

