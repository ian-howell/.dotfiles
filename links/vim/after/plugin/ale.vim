if !(exists('g:loaded_ale'))
  finish
endif

"Always show the gutter
let g:ale_sign_column_always = 1

"Stop linting 'on the fly' in insert mode
let g:ale_lint_on_text_changed = 'normal'
"I'd rather lint when we leave insert mode
let g:ale_lint_on_insert_leave = 1

"Custom signs for gutter
let g:ale_sign_error = "✗"
let g:ale_sign_warning = "▲"

"234 is the same color as the sign column's background
highlight ALEErrorSign ctermbg=234 ctermfg=red
highlight ALEWarningSign ctermbg=234 ctermfg=yellow
