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

" Show balloons on hover
let g:ale_set_balloons = 1

set omnifunc=ale#completion#OmniFunc

let g:ale_linters = {
      \ 'go': [
        \ 'golangci-lint',
        \ 'go build',
        \ 'gopls',
        \],
      \}

" Turn linting errors into warnings
let g:ale_type_map = {
      \ 'flake8': {'ES': 'WS', 'E': 'W'},
      \ 'golangci-lint': {'ES': 'WS', 'E': 'W'},
      \}

" let ale know that we're using python3
let g:ale_python_flake8_executable = 'python3'
let g:ale_python_flake8_options = '-m flake8'

" I'm making a point of white-listing linters
let g:ale_go_golangci_lint_options = '--disable-all
      \ --enable deadcode
      \ --enable errcheck
      \ --enable gosimple
      \ --enable govet
      \ --enable ineffassign
      \ --enable staticcheck
      \ --enable typecheck
      \ --enable unused
      \ --enable varcheck'
