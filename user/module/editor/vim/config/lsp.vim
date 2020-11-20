" =====================
" vim lsp config

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <Plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)

    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

"if executable('reason-language-server')
   au User lsp_setup call lsp#register_server({
           \ 'name': 'reasonml-ls',
           \ 'cmd': {server_info->[&shell, &shellcmdflag, '/nix/store/bibqckvyw73rhhc9rv70kanbw8fh6w6l-reason-language-server-1.7.11/bin/reason-language-server']},
           \ 'allowlist': ['reason'],
           \ })
"endif
