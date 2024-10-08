function IsGitRepo()
  silent let root = system('git rev-parse')
  return !v:shell_error
endfunction
