"Build or run a project
function! build#Build()
    if &filetype == "python"
        AsyncRun python3 %
    elseif &filetype == "cpp" || &filetype == "c"
        AsyncRun -program=make
    elseif &filetype == "tex"
        AsyncRun pdflatex -output-directory '%:h' '%'
    endif
endfunction
