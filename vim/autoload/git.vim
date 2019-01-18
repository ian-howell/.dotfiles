function! git#IsGitRepo()
  let root = system('git rev-parse')
  return !v:shell_error
endfunction
