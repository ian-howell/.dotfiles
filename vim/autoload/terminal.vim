function! terminal#recycle(cmd)
    for i in range(1, winnr('$'))
        let bnum = winbufnr(i)
        if getbufvar(bnum, '&buftype') == 'terminal'
            call jobsend(b:terminal_job_id, "hello world")
            " execute i . "wincmd w"
            " normal i a:cmd
            return
        endif
    endfor
    botright terminal a:cmd
endfunction
