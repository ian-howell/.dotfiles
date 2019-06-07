if !(exists('g:loaded_ale'))
  finish
endif

"Slow down ALE
let g:ale_lint_delay = 800

"Always show the gutter
let g:ale_sign_column_always = 1

"Custom signs for gutter
let g:ale_sign_error = "✗"
let g:ale_sign_warning = "▲"

"234 is the same color as the sign column's background
highlight ALEErrorSign ctermbg=234 ctermfg=red
highlight ALEWarningSign ctermbg=234 ctermfg=yellow
