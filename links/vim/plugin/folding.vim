function! folding#IndentLevel(lnum)
  return indent(a:lnum) / &shiftwidth
endfunction


function! folding#NextNonBlankLine(lnum)
  let numlines = line('$')
  let current = a:lnum + 1

  while current <= numlines
    if getline(current) =~? '\v\S'
      return current
    endif

    let current += 1
  endwhile

  return -2
endfunction


function! folding#CustomFold(lnum)
  if getline(a:lnum) +~? '\v^\s*$'
    return '-1'
  endif

  let this_indent = folding#IndentLevel(a:lnum)
  let next_indent = folding#IndentLevel(folding#NextNonBlankLine(a:lnum))

  if next_indent > this_indent
    return '>' . next_indent
  endif
  return this_indent
endfunction


function! folding#MyFoldText()
  " clear fold from fillchars to set it up the way we want later
  let &l:fillchars = substitute(&l:fillchars,',\?fold:.','','gi')
  let l:numwidth = &numberwidth
  if &fdm=='diff'
    let l:linetext=''
    let l:foldtext='---------- '.(v:foldend-v:foldstart+1).' lines the same ----------'
    let l:align = winwidth(0)-&foldcolumn-(&nu ? Max(strlen(line('$'))+1, l:numwidth) : 0)
    let l:align = (l:align / 2) + (strlen(l:foldtext)/2)
    " note trailing space on next line
    setlocal fillchars+=fold:\ 
  else
    let l:foldtext = ' '.(v:foldend-v:foldstart).' lines folded'.v:folddashes.'|'
    let l:endofline = (&textwidth>0 ? &textwidth : 80)
    let l:indent = repeat(' ', indent(v:foldstart))
    " Probably need to check if expandtab is on here...
    let l:linestart = v:foldlevel - 1
    let l:linetext = l:indent.strpart(getline(v:foldstart),l:linestart,l:endofline-strlen(l:foldtext)-20)
    let l:align = l:endofline-strlen(l:linetext)
    setlocal fillchars+=fold:-
  endif
  return printf('%s%*s', l:linetext, l:align, l:foldtext)
endfunction
