"Custom modified flag
function! statusline#Modified()
  if &modified
    return "  ∆ "
  elseif !&modifiable
    return "  ✗ "
  else
    return "    "
  endif
endfunction

