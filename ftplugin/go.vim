if exists("b:did_ftplugin")
  finish
endif

" See existing mappings and commands in:
" $MYVIM/bundle/vim-go/ftplugin/go/mappings.vim
" $MYVIM/bundle/vim-go/ftplugin/go/commands.vim

nmap     <buffer><expr>Rr ":GoRun".(g:go_jump_to_error ? '' : '!')." %<CR>"
nmap     <buffer><expr>RR ":GoRun".(g:go_jump_to_error ? '' : '!')."<CR>"
nmap     <buffer>Rb       <Plug>(go-build)

nnoremap <buffer>Rf :GoFmt<CR>
nnoremap <buffer>Ri :GoImports<CR>
nmap     <buffer>Rg <Plug>(go-generate)

nmap     <buffer>RI <Plug>(go-install)

nmap <buffer>Rt                    <Plug>(go-test)
nmap <buffer><LocalLeader>t<Space> <Plug>(go-test)
nmap <buffer><LocalLeader>tf       <Plug>(go-test-func)
nmap <buffer><LocalLeader>tc       <Plug>(go-test-compile)
nmap <buffer><LocalLeader>tr       <Plug>(go-coverage)

nmap     <buffer><LocalLeader>i     <Plug>(go-info)
nmap     <buffer><LocalLeader>d     <Plug>(go-describe)
nmap     <buffer><LocalLeader>n     <Plug>(go-rename)
nmap     <buffer><LocalLeader>r     <Plug>(go-referrers)
xnoremap <buffer><LocalLeader>f     :GoFreevars<CR>
nmap     <buffer><LocalLeader>m     <Plug>(go-implements)
nmap     <buffer><LocalLeader>cl    <Plug>(go-callers)
nmap     <buffer><LocalLeader>ce    <Plug>(go-callees)
nmap     <buffer><LocalLeader>cs    <Plug>(go-callstack)
nmap     <buffer><LocalLeader><M-f> <Plug>(go-files)
nmap     <buffer><LocalLeader><M-d> <Plug>(go-deps)
nmap     <buffer><LocalLeader>p     <Plug>(go-channelpeers)

nmap     <buffer><LocalLeader>L     <Plug>(go-metalinter)
nnoremap <buffer><LocalLeader>l     :GoLint<CR>
nmap     <buffer><LocalLeader>v     <Plug>(go-vet)

setlocal shiftwidth=4 tabstop=4 softtabstop=4 noexpandtab