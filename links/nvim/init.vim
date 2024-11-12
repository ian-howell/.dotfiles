" Notes on vimscript style:
"
" Typically, vimscript (and blankspace) should be Pythonic.
"
" In general, use plugin-names-like-this, FunctionNamesLikeThis,
" CommandNamesLikeThis, augroup_names_like_this, variable_names_like_this.

source ~/.config/nvim/helperfunctions.vim
source ~/.config/nvim/pluginconfigs/plugins.vim
source ~/.config/nvim/behavior.vim
source ~/.config/nvim/appearance.vim
source ~/.config/nvim/autocorrect.vim

" This does bufdo e without losing highlighting
" TODO: Replace this with :h autoread
function EditWithoutLosingSyntax()
    let this_buffer = bufnr("%")
    bufdo set eventignore= | if &buftype != "nofile" && expand("%") != '' | edit | endif
    execute "b" . this_buffer
endfunction
nnoremap <silent> <space>be :call EditWithoutLosingSyntax()<cr>
