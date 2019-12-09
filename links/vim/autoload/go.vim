function! go#GoImports()
    " Check that goimports is available
    if !executable('goimports')
        echoerr "Could not find goimports, please install it"
        return
    endif

    " Save the buffer to file
    write

    " Update the file. This can't be async - I don't want to make any more
    " actions until the file is rewritten
    " The '-w' flag makes goimports overwrite the file if there were issues
    " The '-d' flag causes goimports to output if there were issues
    if (system('goimports -d -w ' . expand('%')) == "")
        " If no issues, unrecord this action and stop
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

