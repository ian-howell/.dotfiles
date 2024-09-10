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
