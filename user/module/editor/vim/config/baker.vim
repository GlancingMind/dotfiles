" =====================
" vim-baker config

let g:Baker_CompleteDirectories = 0

" =====================
" mappings

"complete makefile and target if there is only one match
"<C-L> match first entry if only one present
"<C-D> show possible completions
"NOTE: <c-m> is the same as <CR>; some terminals don't send diffrent keycodes
nnoremap    <c-m>       :Baker! <C-L><C-D>
nnoremap    <leader><c-m>       :Baker <C-L><C-D>
