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

"Custom git branch flag
function! statusline#GitBranch()
  if !git#IsGitRepo() || !&modifiable
    return ""
  endif
  let branch = FugitiveHead()
  if len(branch)
    return " «" . branch . "»"
  endif
  return " «detached HEAD»"
endfunction
