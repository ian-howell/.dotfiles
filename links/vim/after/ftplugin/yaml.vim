set shiftwidth=2

" So this is a bit weird - I want to unmap {{ for yaml files, but the unmap
" command causes an error (E31) when opening a second yaml file. So instead of
" unmapping, I'll just remap it back to itself
inoremap <buffer> {{ {{
