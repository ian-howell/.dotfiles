if exists('g:loaded_ale')
  "Slow down ALE
  let g:ale_lint_delay = 800

  "Always show the gutter
  let g:ale_sign_column_always = 1

  let g:ale_sign_column_always = 1

  "Turn flake8 errors into warnings
  let g:ale_type_map = {'flake8': {'ES': 'WS', 'E': 'W'}}

  "Python linters
  let g:ale_python_flake8_executable = 'python3'
  let g:ale_python_flake8_options = '-m flake8'

  "234 is the same color as the sign column's background
  highlight ALEErrorSign ctermbg=234 ctermfg=red
  highlight ALEWarningSign ctermbg=234 ctermfg=yellow
endif
