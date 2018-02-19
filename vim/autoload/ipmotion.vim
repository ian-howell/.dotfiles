function ipmotion#MyNextParagraph()
  let myline = search('^\s*$', 'W')
  if myline <= 0
    execute 'normal! G$'
  else
    execute 'normal! '.myline.'G0'
  endif
endfunction

function ipmotion#MyPrevParagraph()
  let myline = search('^\s*$', 'bW')
  if myline <= 0
    execute 'normal! gg0'
  else
    execute 'normal! '.myline.'G0'
  endif
endfunction
