" fmt#Format takes the name of an executable and a string of flags
" If the executable can't be found, it generates an error
" If the executable does not generate anything on stdout, no further action is
" taken, and this action will not be added to the undolist
" Otherwise, the buffer is updated to reflect the changed file on disk
function! fmt#Format(executable, flags)
    " Check that goimports is available
    if !executable(a:executable)
        echoerr "Could not find " . a:executable . ", please install it"
        return
    endif

    " Save the buffer to file
    write

    " Update the file. This can't be async - I don't want to make any more
    " actions until the file is rewritten
    " The -l flag prints the names of files that were modified
    if (system(a:executable . " " . a:flags . " " . expand('%')) == "")
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


