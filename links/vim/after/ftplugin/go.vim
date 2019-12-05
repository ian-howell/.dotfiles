setlocal noexpandtab
setlocal shiftwidth=8

nnoremap <silent> <buffer> ,gi :call go#GoImports()<cr>

if exists('g:loaded_ale')
  nnoremap <silent> <buffer> gd :ALEGoToDefinition<cr>
  nnoremap <silent> <buffer> <c-]> :ALEGoToDefinition<cr>
  nnoremap <silent> <buffer> ,gdv :ALEGoToDefinitionInVSplit<cr>
  nnoremap <silent> <buffer> ,gds :ALEGoToDefinitionInSplit<cr>

  nnoremap <silent> <buffer> ,gf :ALEFindReferences<cr>

  nnoremap <silent> <buffer> K :ALEHover<cr>
endif
