if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

if executable('shellcheck')
  let &l:makeprg = 'shellcheck --format=gcc --shell='.
        \ (bufname('') =~# '\<\.\?profile' ? 'sh' : 'bash').' %'
endif
setlocal shiftwidth=2 tabstop=2 softtabstop=2
