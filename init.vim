"  _  _ ____ _    _    ____   _  _ _ _  _
"  |__| |___ |    |    |  |   |  | | |\/|
"  |  | |___ |___ |___ |__|    \/  | |  |
"
" This is the Vim(Neovim) initialization file, practically categorized.
" Bundle(plugin) dependent configs are splited into "init..vim".
"
" Rationale:
"
" - For the sake of review convenience, this file is not split.
" - Comments, especially for options, are written for keywords search.
"
" Author: Bohr Shaw <pubohr@gmail.com>

" Starting:" {{{

" To skip sourcing system-vimrc, use `vim -u init.foo.vim`.
" Don't `set all&` to try to override system-vimrc as it resets cmdline options.

if has('vim_starting')
  if !has('nvim')
    set nocompatible " make Vim behave in a more useful way
  endif

  if has('win32')
    " Wish to use a forward slash for path separator? But 'shellslash' is not
    " designed to be set alone. Plugins must explicitly cope with it. Wish a
    " 'internal_shellslash' be available!
    "
    " Plugins like 'fugitive' works regardless of this option. While more
    " plugins like 'gnupg', 'jedi' wouldn't function well when it's set.
    " Troublesomely, 'unite', 'vimproc' have problems when it's not set.
    set shellslash&
  endif

  let $MYVIMRC = empty($MYVIMRC) ?
        \ expand('<sfile>:p') : expand('~/.vim/init.vim')
  let $MYVIM = fnamemodify($MYVIMRC, ':p:h') " be portable
  " A directory for storing temporary files, whose location is outside of $MYVIM
  " as $MYVIM could be shared between OSs such as in the case of WSL.
  let $MYTMP = expand('~/.vimtmp/')

  " Remove empty directories in 'runtimepath' to make various seeking faster
  let &rtp = join(filter(split(&rtp, ','), 'isdirectory(v:val)'), ',')
  " Include files provided by system and packages
  if has('nvim')
    " Note: $VIM could be "/usr/local/share/nvim".
    let vimfiles = '/usr/share/vim/vimfiles'
    if isdirectory(vimfiles)
      let &rtp = join(insert(split(&rtp, ',\?\ze\V'.$VIMRUNTIME),
            \ vimfiles, 1), ',')
    endif
    unlet vimfiles
  endif
  " Cross-platform 'runtimepath'
  if has('win32') && !has('nvim')
    let &rtp = $MYVIM.','.&rtp.','.$MYVIM.'/after'
  endif

  if has('gui_running') || $termencoding ==? 'utf-8'
    set encoding=utf-8 " used inside Vim, allow mapping with the ALT key
  endif

  set timeout ttimeout " Nvim has different defaults
  " set timeoutlen=3000 " mapping delay
  set ttimeoutlen=10 " key code delay (instant escape from Insert mode)
  " Deal with meta-key mappings:" {{{
  if has('gui_running') || has('nvim')
    " These keys, if not mapped later, are meant to be captured by global
    " shortcuts, thus a no-op in Vim.
    " for c in map(range(33, 123) + range(125, 126), 'nr2char(v:val)')
    "   execute 'noremap! '.'<M-'.c.'>' '<Nop>'
    "   execute 'noremap! '.'<M-C-'.c.'>' '<Nop>'
    " endfor
    " noremap! <M-\|> <Nop>
    " noremap! <M-CR> <Nop>
    " Send keys like <M-b> as <Esc>b to a terminal.
    " if has('nvim')
    "   for c in map(range(33, 123) + range(125, 126), 'nr2char(v:val)')
    "     execute 'tnoremap '.'<M-'.c.'> <Esc>'.c
    "     execute 'tnoremap '.'<M-C-'.c.'> <Esc><C-'.c.'>'
    "   endfor
    "   tnoremap <M-\|> <Esc>\|
    "   tnoremap <M-CR> <Esc><CR>
    " endif
  else
    runtime autoload/keymeta.vim " mappable meta key in terminals
  endif " }}}

  " g:l, if true, means "Lightweight" indicating less bundles to be enabled.
  " It's true when the cmdline option '-l' is specified; when invoked with like
  " <C-x><C-e> for editing a shell command; etc.
  let g:l = get(g:, 'l', &lisp || (empty($VL) ? 0 : 1) ||
        \ argv(0) =~# '^\V'.(empty($TMPPREFIX) ? '/tmp/zsh' : $TMPPREFIX).'ecl'.
        \   '\|'.$TMP.'/bash-fc')
  set lisp& showmatch& " reset cmdline option '-l'

  if has('nvim')
    " Skip python check to reduce startup time
    let [g:python_host_skip_check, g:python3_host_skip_check] = [1, 1]
  endif

  let $MYVIMRCPRE = expand($MYVIM.'/init-.vim')
  if filereadable($MYVIMRCPRE)
    execute 'silent source' $MYVIMRCPRE
  endif

  " If on the Windows platform
  let s:windows = has('win32') ||
        \ readfile('/proc/version')[0] =~? 'microsoft' ||
        \ !empty($SSH_TTY)
endif

" }}}
" Meta:" {{{

" Commands for defining mappings in several modes
" Note: Adjust syntax/vim.vim if these command names change
command! -nargs=1 NXnoremap nnoremap <args><Bar> xnoremap <args>
command! -nargs=1 NXmap nmap <args><Bar>xmap <args>
command! -nargs=1 NOnoremap nnoremap <args><Bar> onoremap <args>
command! -nargs=1 NOmap nmap <args><Bar>omap <args>
command! -nargs=1 NXOnoremap nnoremap <args><Bar>xnoremap <args><Bar>onoremap <args>
command! -nargs=1 NXOmap nmap <args><Bar>xmap <args><Bar>omap <args>
" Allow chained commands, but also check for a " to start a comment
command! -bar -nargs=1 NXInoremap nnoremap <args><Bar> xnoremap <args><Bar>
      \ inoremap <args>

" let mapleader = "\r" " replace <Leader> in a map
let maplocalleader = "\t" " replace <LocalLeader> in a map
NXnoremap <Tab> <Nop>
let g:mapinsertleader = "\<C-g>" " this is personal convention

" Execute a remapped key in its un-remapped(vanilla) state.
" Note: Don't be confused with i_CTRL-V.
noremap <expr><M-\> nr2char(getchar())
noremap! <expr><M-\> nr2char(getchar())

" Execte a global mapping shadowed by the same local one
" Note: This is a design-not or an unprivileged back door. Better redo mappings.
nnoremap <silent>g\ :call map#global('n')<CR>
xnoremap <silent>g\ :<C-u>call map#global('x')<CR>

" Complete an abbreviation with suffix 'soxx'(Suo Xie) and expand it.
" Note: This is to restrict unexpected expansion of abbreviations.
noremap! <M-]> soxx<C-]>

" Echo a warning message. Note: A double-quote in <args> starts a comment.
command! -bar -nargs=1 Echow echohl WarningMsg | echo <args> | echohl None

" A command doing nothing while accepting args (for quick composition)
command! -nargs=* Nop :

" Pre-define autocmd groups for interactive use
augroup tmp | augroup t
augroup END

" }}}
" Normal:" {{{
" Correspond to Cmdline. (not Normal Mode)
" These mappings are mostly for the typing convenience.

inoremap <M-i> <Esc>
inoremap <M-o> <C-O>

nnoremap Y y$

nnoremap vv ^vg_
nnoremap vV vg_

NXnoremap "" "0
NXnoremap "<Space> "+
NXnoremap _ "_

" }}}
" Cmdline:" {{{

" Note ':' should not be mapped as it would be used in the rhs of a remap.
NXnoremap <Space> :
cnoremap <F5> <CR>:<Up>
cmap <M-m> <F5>
" Resolve local mapping conflicts with <Space> {{{
augroup init_optwin | autocmd!
  autocmd BufWinEnter option-window autocmd CursorMoved option-window
        \ execute 'nnoremap <silent><buffer><LocalLeader>r '.maparg("<Space>")|
        \ unmap <buffer><Space>|
        \ autocmd! CursorMoved option-window
augroup END "}}}

NXnoremap <M-Space> q:
NXnoremap <M-/> q/
" set cedit=<C-G>
cnoremap <M-Space> <C-F>
augroup init_cmdwin | autocmd!
  " Note: Fiddling with 'laststatus' to hide and show the statusline would mute
  " command output.
  autocmd CmdwinEnter *
        \ NXInoremap <buffer><M-q> <C-c><C-c>|
        \ NXInoremap <buffer><nowait><CR> <CR>|
        \ setlocal norelativenumber nocursorline scrolloff=0
  autocmd CmdwinLeave * set scrolloff=1
augroup END
set cmdwinheight=5

" A special buffer and window served as a custom cmdline-window
" Note: The history is unidirectionally synced from the cmdwin to cmdline.
nnoremap <silent><M-e> :call cmdwin#init()<CR>
cnoremap <silent><M-e> <C-r>=
      \v#setvar('[g:_cmdline, g:_cmdlinepos]', [getcmdline(), getcmdpos()])<CR>
      \<End><C-u>call cmdwin#line2win()<CR>

" Get the Entire current line
cnoremap <C-r><C-e> <C-r>=getline('.')<CR>
" Get the full path of a buffer with its number
inoremap <C-r><C-b> <C-r>=fnamemodify(bufname(), ':p:~')<S-Left><Left><Left><Left>
" Copy from the command line
cnoreabbrev <expr>c getcmdtype() == ':' && getcmdpos() == 2 ? 'copy' : 'c'
" Run the current command with a bang(!)
cnoremap <M-1> <C-\>ecmd#bang()<CR><CR>
" Run the last command with a bang
nnoremap @! :<Up><C-\>ecmd#bang()<CR><CR>

"}}}
" Motion:" {{{

set virtualedit=onemore " consistent cursor position on EOL
set whichwrap& " left/right motions across lines

" Line objects
xnoremap i<CR> 0og_
xnoremap I<CR> ^og_
onoremap <silent>i<CR> :<C-u>normal! 0vg_<CR>
onoremap <silent>I<CR> :<C-u>normal! ^vg_<CR>

" "o_-" is only useful in a character wise motion.
" Note: This behavior lacks of tests and I ran into a bug when `nmap zZ yvt=-`.
" onoremap - v-
" Go to the end of any previous line, depends on 'virtualedit'
onoremap <silent>_ :<C-u>execute 'normal!' v:count1.'k$l'<CR>

" `;` always forward, `,` always backward
" Note: These are overwritten in Sneak, but the semantics retains. "{{{
if 0 && exists('*getcharsearch') " Vim patch 7.4.813
  NXOnoremap <expr>; getcharsearch().forward ? ';' : ','
  NXOnoremap <expr>, getcharsearch().forward ? ',' : ';'
endif "}}}

" Display lines up/down (consecutive motions are quicker)
nnoremap <C-j> gj
nnoremap <C-k> gk

" Jump to the middle of the current written line as opposed to the window width
nnoremap <silent> gm :call cursor(0, virtcol('$')/2)<CR>|nnoremap gM gm

" `%` jump between characters in 'matchpairs'
" {{{
" set matchpairs+=<:> " < and > could appear in <=, ->, etc.
" Extended pair matching with the bundled plugin "matchit"
let g:loaded_matchit = 1 " disabled as `dV%` is unsupported, see matchit-v_%
if has('vim_starting') && !g:loaded_matchit
  if !has('nvim') " nvim put it in plugin/
    runtime macros/matchit.vim
  endif
  augroup init_matchit | autocmd!
    autocmd User Init sunmap %|sunmap [%|sunmap ]%|sunmap a%|sunmap g%
  augroup END
endif
" }}}

" Sections backword/forward
nmap <M-[> [[
nmap <M-]> ]]

" Navigate the change list
nnoremap <M-;> g;
nnoremap <M-,> g,
" Go to the second-newest or current position in the change list
nnoremap <silent>g. :try\|execute 'normal! g,g;'\|
      \ catch\|execute 'normal! g,'\|endtry<CR>

" Print the change list or mark list
cnoreabbrev <expr>cs getcmdtype() == ':' && getcmdpos() == 3 ? 'changes' : 'cs'
cnoreabbrev <expr>ms getcmdtype() == ':' && getcmdpos() == 3 ? 'marks' : 'ms'

" Navigate the jumper list
nnoremap <M-i> <C-I>
nnoremap <M-o> <C-O>

" Jump to the definition of the current tag, fail silently
nnoremap <silent><CR> :<C-u>try \| execute v:count1.'tag' expand('<cword>')
      \ \| catch \| endtry<CR>
xnoremap <silent><CR> "zy:<C-u>try \| execute v:count1.'tag' @z
      \ \| catch \| endtry<CR>
nnoremap <BS> <C-t>

" Auto-place the cursor when opening buffers or files
" " {{{
augroup init_cursor_restore | autocmd!
  " Don't move the cursor to the start of the line
  autocmd BufLeave * set nostartofline |
        \ autocmd CursorMoved * set startofline |
        \ autocmd! init_cursor_restore CursorMoved
  " Jump to the last position
  autocmd BufRead * silent! normal! g`"
augroup END
" }}}

" }}}
" Search:" {{{

set incsearch
set ignorecase smartcase " also apply to command completion

" Temporary highlight, will suspend after moving the cursor
NXOnoremap <expr>/ search#hl().'/'
NXOnoremap <expr>? search#hl().'?'

" The nmap is just for temporary search highlight.
" The xmap is to search literally with "\C\V".
"   Note: Keys to search with word boundary is swapped to be practical.
" The omap is a shortcut to "*Ncgn", etc.
NXOnoremap <expr>* search#star('*')
NXOnoremap <expr># search#star('#')
NXOnoremap <expr>g* search#star('g*')
NXOnoremap <expr>g# search#star('g#')
" Search case sensitively
nnoremap <expr>z* search#star('*', 'C')
nnoremap <expr>z# search#star('#', 'C')
nnoremap <expr>gz* search#star('g*', 'C')
nnoremap <expr>gz# search#star('g#', 'C')
" The cusor would not move (Or map "`*" as "`" is before "1".)
NXnoremap <expr>s*  search#star('*', 's')
NXnoremap <expr>gs* search#star('g*', 's')
NXnoremap <expr>s#  search#star('#', 's')
NXnoremap <expr>gs# search#star('g#', 's')

" Consistent direction when repeating a search
NXOnoremap <expr>n search#hl().(v:searchforward ? 'n' : 'N').'zv'
NXOnoremap <expr>N search#hl().(v:searchforward ? 'N' : 'n').'zv'

" Highlight
if !&hlsearch | set hlsearch | endif " related: :nohlsearch, v:hlsearch
" Suspend or (temporarily) resume highlight
nnoremap <silent>gl :<C-u>let g:hlsearch = 0 \|
      \ if v:hlsearch \|nohlsearch \|
      \ else \|call search#hl(0) \|set hlsearch \|endif<CR>
xmap gl <Esc>glgv
" Persist highlight
nnoremap <silent>gL :let g:hlsearch = 1 \|set hlsearch \|autocmd! search_hl<CR>
" For :s and :g
cnoremap <silent><M-j> <CR>:nohlsearch<CR>

" Show effects of :substitute incrementally
if 0 && exists('&inccommand')
  set inccommand=split
endif
" Substitute in a visual area
xnoremap sv :s/\%V
" Substitute in a visual area (eat the for-expanding-space)
" Hack: Use an expression to save a temporary value.
cnoreabbrev <expr>sv getcmdtype() == ':' && getcmdpos() =~ '[38]' ?
      \ 's/\%V'.setreg('z', nr2char(getchar(0)))[1:0].(@z == ' ' ? '' : @z) : 'sv'

" }}}
" GREP:" {{{

" Related: https://github.com/mhinz/vim-grepper/blob/master/autoload/grepper.vim

" Note: A single file may not be printed; thus /dev/null is added.
" -nocolor --nobreak are usally implicitly set when running non-interactively.
" `grep` is non-recursive by default and this inconsistency is preferable.
" Use short options as they would be shown on qf-statusline.
let g:greps = {
      \ 'grep': 'grep -n $* '.(has('win32') ? 'NUL' : '/dev/null'),
      \ 'rg': 'rg --vimgrep',
      \ 'ag': 'ag --vimgrep',
      \ 'pt': 'pt --column',
      \ 'ack': (executable('ack') ? 'ack' : 'ack-grep').' --column -H',
      \ }
let &grepprg = executable('ag') ? greps.ag :
      \ executable('rg') ? greps.rg :
      \ executable('pt') ? greps.pt :
      \ (executable('ack') || executable('ack-grep')) ? greps.ack :
      \ &grepprg
set grepformat^=%f:%l:%c:%m
set grepformat+=%f " '-g' search only file names

" Grep without affecting 'grepprg' and 'grepformat'.
" Examples: Ag pattern .; Ag =lgrepadd pattern %
command! -nargs=+ -complete=file Grep call grep#grep('grep', <q-args>)
command! -nargs=+ -complete=file Ag call grep#grep('ag', <q-args>)
command! -nargs=+ -complete=file Pt call grep#grep('pt', <q-args>)
command! -nargs=+ -complete=file Ack call grep#grep('ack', <q-args>)

" Grep all HELP docs with the best available greper (with a multiline pattern)
command! -nargs=+ -complete=command Help call grep#help(<q-args>)
" A shortcut to `:Help grep`
command! -nargs=+ -complete=command Helpgrep call grep#help('grep '.<q-args>)

command! -nargs=1 Bufgrep cexpr [] | bufdo vimgrepadd <args> %
" command! -nargs=1 Bufgrep cexpr [] | mark Z |
"       \ execute "bufdo silent! g/<args>/caddexpr ".
"       \   "expand('%').':'.line('.').':'.getline('.')" | normal `Z

" }}}
" QuickFix:" {{{

augroup init_qf | autocmd!
  " Note it would be a little slower if it's "ftplugin/qf.vim".
  autocmd FileType qf call qf#window()

  " Open the quickfix-window automatically
  autocmd QuickFixCmdPost [^l]* cwindow
  autocmd QuickFixCmdPost l* lwindow
  " Then avoid the hit-enter prompt showing duplicate info
  autocmd QuickFixCmdPost * call feedkeys('@_')
augroup END

" Clear the current quickfix list
command! -bar Cclear call setqflist([])

if !has('patch-7.4.858') "{{{
  " Execute a command in each buffer in the quickfix or location list
  command! -nargs=1 -complete=command Cfdo call qf#fdo(<q-args>)
  command! -nargs=1 -complete=command Lfdo call qf#fdo(<q-args>, 1)
endif "}}}

" }}}
" View:" {{{

" Scroll relative to cursor (@_ suppresses [count] for zt)
nnoremap <expr>zt v:count > 0 ? '@_zt'.v:count.'<c-y>' : 'zt'
nnoremap <expr>zb v:count > 0 ? '@_zb'.v:count.'<c-e>' : 'zb'

" The leader key for managing windows and tabs
NXmap <M-w> <C-W>

" Jump to {count}th next/previous window, able to jump back with <C-w>p
nnoremap <silent><C-w>j :<C-u>let _w = winnr() + v:count1 \|
      \ execute (_w > winnr('$') ? _w - winnr('$') : _w).'wincmd w'<CR>
nnoremap <silent><C-w>k :<C-u>let _w = winnr() - v:count1 \|
      \ execute (_w < 1 ? _w + winnr('$') : _w).'wincmd w'<CR>
for i in [2, 3, 4, 5]
  execute 'nmap <C-w>'.i.'j' i.'<C-w>j'
  execute 'nmap <C-w>'.i.'k' i.'<C-w>k'
endfor
nmap <M-j> <C-w>j
nmap <M-k> <C-w>k
" `i` to go to terminal mode
nmap <M-J> <C-w>ji
nmap <M-K> <C-w>ki
nnoremap <M-s> <C-w>s
nnoremap <M-v> <C-w>v
nnoremap <M-q> <C-W>q
inoremap <M-q> <Esc><C-W>q

nnoremap <silent><M-l> :<C-u>execute repeat('tabn\|', v:count1-1).'tabn'<CR>
nnoremap <M-h> gT
nnoremap <silent><C-w><M-l> :<C-u>execute 'tabmove+'.v:count1<CR>
nnoremap <silent><C-w><M-h> :<C-u>execute 'tabmove-'.v:count1<CR>
nnoremap <silent><M-Q> :windo quit<CR>
nmap <silent><C-w>Q <M-Q>
nnoremap <silent><C-w>C :lclose \| cclose<CR>
nmap <C-w><M-c> <C-w>C

" Like <C-w>T, but on the left
nnoremap <silent><C-w><M-t> <C-w>T:tabmove -1<CR>
" Split the current window to a new tab on the left. So that when it's closed I
" should return to the last active tab.
nnoremap <silent><M-t> :<C-u>tab sbuffer % \|
      \ if v:count == 0 \| tabmove -1 \|
      \ elseif v:count == 1 \| 0tabmove \|
      \ elseif v:count == 9 \| $tabmove \|
      \ endif<CR>
" Like above, but on the right.
nmap <M-T> 2<M-t>
" Maxmize the current window or restore the previously window layout
nnoremap <silent><C-w>O :call win#max()<CR>

" Exchange the current window with the previous one
nnoremap <C-w>X <C-w>W<C-w>x<C-w>w
" Exchange the current window with the {count}th window
" Note: This differs from <C-w>x in following ways:
" - The cursor would be on a different window.
" - Without a {count}, the first window is exchanged.
" - Mixed vertical and horizontal window splits are allowed.
nnoremap <silent><C-w>e :<C-u>execute 'buffer '.winbufnr(v:count1).'\|'
      \.v:count1.'wincmd w\|buffer '.winbufnr(0)<CR>
" Move the {count}th window above the current one.
nnoremap <silent><C-w>m :<C-u>let z_bufnr = winbufnr(v:count1) \|
      \ execute v:count1.'quit' '\|' 'sbuffer' z_bufnr<CR>
" Move the {count}th window below the current one.
nnoremap <silent><C-w>M :<C-u>let z_bufnr = winbufnr(v:count1) \|
      \ execute v:count1.'quit' '\|' 'bel sbuffer' z_bufnr<CR>
" Attach the current window bellow the last windows.
nnoremap <silent><C-w>a :execute 'close\|$wincmd w\|belowright sbuffer '.bufnr('')<CR>

cnoreabbrev <expr>v getcmdtype() == ':' && getcmdpos() == 2 ?
      \ 'vert'.v#setvar('g:_t', nr2char(getchar(0))).
      \   (_t == ' ' ? '' : "<BS><BS><BS>")._t : 'v'
cnoreabbrev <expr>t getcmdtype() == ':' && getcmdpos() == 2 ? 'tab' : 't'

" Full screen
nnoremap <silent><F11> :execute 'FullScreen' \|
      \ let g:_fullscreen = !get(g:, '_fullscreen') \|
      \ let &showtabline = g:_fullscreen ? 2 : 1<CR>
" In case <F11> is captured by the terminal
nmap <S-F11> <F11>
if has('unix')
  command! FullScreen call system('wmctrl -ir '.
        \ (has('nvim') ? $WINDOWID : v:windowid).' -b toggle,fullscreen') |
        \ execute "normal! \<C-l>"
endif

" View a buffer in two scroll-binded windows side by side
nnoremap <silent><C-w><C-f> :set noscrollbind\|belowright vsplit<CR><C-f>
      \:set scrollbind\|wincmd p\|set scrollbind<CR>
nnoremap <silent><C-w><C-b> :set noscrollbind\|vsplit<CR><C-b>
      \:set scrollbind\|wincmd p\|set scrollbind<CR>

" }}}
" Fold: "{{{

if has('vim_starting')
  " set foldlevel=2 " not advised as `zx` would not close other folds
endif

" Open the fold the cursor is in, recursively
nnoremap z<M-o> zczO

" Focus on a region(range of lines) by folding the rest (mnemonic: pick)
nnoremap <silent>zp :set operatorfunc=fold#pick<CR>g@
xnoremap <silent>zp :<C-u>call fold#pick()<CR>
nnoremap <silent>zq :call fold#restore()<CR>

" Edit a region in an isolated buffer (mnemonic: Part)
" A second invocation overrides the parted buffer.
" This is especially useful for embedded file types.
nnoremap <silent>zP :set operatorfunc=fold#part<CR>g@
xnoremap <silent>zP :call fold#part()<CR>
command! -range -nargs=* Part <line1>,<line2>call
      \ fold#part('', <q-args>) " support setting 'filetype'
" Finish the current parted editing. Use `:w` to stage changes periodically.
" Should avoid editing the complete buffer before a merging.
nnoremap <silent>zQ :call fold#join(1)<CR>

" Toggle fold methods
nnoremap <silent>cof :let &foldmethod = tolower(matchstr(
      \',mmanual,kmarker,iindent,ssyntax,eexpr,ddiff',
      \','.nr2char(getchar()).'\zs\a*\C'))\|set foldmethod<CR>
nmap <silent>zfm cof

" Avoid updating folds in Insert Mode, not needed as of Neovim 0.1.6
" augroup init_fold_lazily | autocmd!
"   autocmd InsertEnter * if !exists('w:vfdml') &&
"         \ &foldmethod != 'manual' && empty(&buftype) |
"         \ let w:vfdml=&foldmethod | set foldmethod=manual | endif
"   autocmd InsertLeave * if exists('w:vfdml') && empty(&buftype) |
"         \ let &foldmethod=w:vfdml | unlet w:vfdml |
"         \ execute 'silent! normal! zO' |endif
" augroup END

"}}}
" Buffer:" {{{

set hidden autoread " 'autowrite'
" set switchbuf=split " would make :Vsplit split two times

nnoremap <silent><M-b>d :bdelete<CR>
nnoremap <silent><M-b>w :bwipeout<CR>

" Delete the current buffer without closing its window
nnoremap <silent><M-b>x :Bdelete<CR>
nnoremap <silent><M-b>X :Bwipeout<CR>
command! -bang Bdelete execute 'silent'
      \ buflisted(0) ? 'buffer #' : 'bprevious' | silent! bdelete! #
command! -bang Bwipeout execute 'silent'
      \ buflisted(0) ? 'buffer #' : 'bprevious' | silent! bwipeout! #

cnoreabbrev <expr>vb getcmdtype() == ':' && getcmdpos() == 3 ? 'vert sb' : 'vb'
cnoreabbrev <expr>tb getcmdtype() == ':' && getcmdpos() == 3 ? 'tab sb' : 'tb'
cnoreabbrev <expr>ag getcmdtype() == ':' && getcmdpos() == 3 ? 'argu' : 'ag'

" Like :bufdo, but with a pattern matching buffers, a bang reverses the match.
" Example: `Bufdo /tmp bw!`. While `bw! /tmp<C-a>` is a native way.
command! -bang -nargs=1 Bufdo call
      \ call('buf#do', split(<f-args>, ' \ze\S\+$') + [<bang>0])

augroup binary | autocmd!
  autocmd BufReadPre  *.bin setlocal bin
  autocmd BufReadPost * if &bin | execute '%!xxd' | set filetype=xxd | endif
  autocmd BufWritePre * if &bin | execute '%!xxd -r' | endif
  autocmd BufWritePost * if &bin | execute '%!xxd' | set nomodified | endif
augroup END

" }}}
" File:" {{{

nnoremap <silent><M-f>w :noautocmd write<CR>
nnoremap <silent><M-f>u :noautocmd update<CR>
nnoremap <silent><M-u> :silent noautocmd update<CR>
nnoremap <silent><M-f>a :noautocmd wall<CR>
nnoremap <silent><M-f>A :let @z = winnr() \|
      \ execute 'windo noautocmd update' \| execute @z.'wincmd w'<CR>
" Quick save and exit, useful when editing the shell command line
inoremap <M-z> <Esc>ZZ
nnoremap <silent><M-f>e :edit<CR>
nnoremap <silent><M-f>E :edit!<CR>
cnoreabbrev <expr>tw getcmdtype() == ':' && getcmdpos() == 3 ? 'tabe' : 'tw'
cnoremap <M-h> <C-r>=expand('%:h')<CR>/
nnoremap <M-f>f :filetype detect<CR>
nnoremap <M-f>F :silent! unlet b:did_ftplugin b:did_after_ftplugin<Bar>
      \ let &l:filetype = &filetype<CR>
nnoremap <M-f>c :checktime<CR>
" Switch to the alternative or {count}th buffer
nnoremap <silent><M-a> :silent noautocmd keepjumps buffer
      \ <C-r>=v:count ? v:count : '#'<CR><CR>
" Like CTRL-W_^
nnoremap <silent><C-W><M-s> :sbuffer #<CR>
nnoremap <silent><C-W><M-v> :vert sbuffer #<CR>

" Find a file in 'path'
cnoreabbrev <expr>fi getcmdtype() == ':' && getcmdpos() == 3 ? 'fin' : 'fi'
cnoreabbrev <expr>vf getcmdtype() == ':' && getcmdpos() == 3 ? 'vert sf' : 'vf'
cnoreabbrev <expr>tf getcmdtype() == ':' && getcmdpos() == 3 ? 'tab sf' : 'tf'

" Directories to search by `gf, :find, cd, lcd etc.`
" (dir of the current file, current dir, etc.)
let &g:path = '~,'.$MYVIM.','.$MYVIM.'/after,'.$MYVIM.'/bundle'
set cdpath=,,.,~
if has('vim_starting') && 0 == argc() && has('gui_running') && !g:l
  cd $HOME
endif

" Open links' destination files
cnoremap <C-g>l <C-\>ecmd#link_targets()<CR><CR>

" Easy access to init files
cabbr <expr>vsoxx $MYVIMRC
cabbr <expr>bsoxx $MYBUNDLE
nnoremap <silent><M-f>i :<C-u>call buf#edit($MYVIMRC)<CR>
nnoremap <silent><M-f>b :<C-u>call buf#edit($MYBUNDLE)<CR>

" Make scratch buffers
augroup init_scratch | autocmd!
  autocmd BufNewFile _,_.*
        \ setlocal buftype=nofile nobuflisted bufhidden=hide noswapfile
augroup END

" Recognise a file's encoding in this order
set fileencodings=ucs-bom,utf-8,default,cp936,gb18030,big5,latin1

set fileformats=unix,dos,mac " end-of-line formats precedence
set fileformat=unix " only for the initial unnamed buffer

set nowritebackup " write to symbolic files safely on windows

" }}}
" Completion:" {{{

" Practical interface to various kinds of completions
" {{{
" Hacker: `a<BS>` to make the selected entry inserted.
inoremap <expr><Tab> pumvisible() ? '<C-n>' :
      \ getline('.')[col('.')-2] =~# '\S' ? '<C-x><C-p>a<BS><C-p>' : '<Tab>'
inoremap <expr><S-Tab> pumvisible() ? '<C-p>' : '<C-x><C-n>a<BS><C-n>'
" Remove built-in mappings
augroup init_cmdwin_completion | autocmd!
  autocmd CmdwinEnter [:>] silent! iunmap <buffer><Tab>
augroup END

inoremap <expr><M-n> pumvisible() ? ' <BS><C-n>' : '<C-n>'
inoremap <expr><M-p> pumvisible() ? ' <BS><C-p>' : '<C-p>'

" CTRL-X completion-sub-mode
map! <M-x> <C-x>
for s:c in split('lnpkti]fdvuos', '\zs')
  execute 'inoremap <C-X>'.s:c.' <C-X><C-'.s:c.'>'
endfor
" Mnemonic: diGraph
noremap! <C-X>g <C-k>
" Complete shell commands
inoremap <silent><C-x>c <C-r>=comp#shellcmd()<CR>

" Shortcuts
inoremap <M-e> <C-x><C-o>
noremap! <M-k> <C-k>
" }}}

" Completion behavior tweak
" {{{
" Insert mode
" 'menuone': Omni-completion may show additinal info in the popup menu.
" 'longest': Applied to all except for <Tab>.
" 'preview': Showing extra info is useful for learning a language.
set completeopt=menuone,longest,preview
set infercase " auto-adjust case
set complete-=i " don't scan included files when do <C-n> or <C-p>
set pumheight=15 " max number of items to show in the popup menu

" Command-line mode
set wildcharm=<Tab> " the key to trigger wildmode expansion in mappings
set wildmenu wildmode=longest:full,full
silent! set wildignorecase " ignore case when completing file names/directories
" }}}

" Auto-reverse letter case in insert mode
inoremap <silent><M-u> <C-R>=key#case(1)<CR>
inoremap <silent><M-U> <C-R>=key#case(2)<CR>
smap <M-u> <BS><M-u>
smap <M-U> <BS><M-U>

" Make a command(e.g. `:h ...`) split vertically or in a new tab.
cnoremap <M-w>v <C-\>e'vert '.getcmdline()<CR><CR>
cnoremap <M-w>t <C-\>e'tab '.getcmdline()<CR><CR>
cmap <M-CR> <C-\>e'tab '.getcmdline()<CR><CR>

" Expand a mixed case command name
cnoremap <M-l> <C-\>ecmd#expand()<CR><Tab>

" Abbreviations
noreabbrev bssoxx Bohr Shaw

" Type notated keys (:help key-notation)
noremap! <expr><M-v> key#notate()

" }}}
" Repeat:" {{{

" Concisely list the newest leafs in the tree of changes. Er... useless...
command! UndoList echo join(reverse(map(
      \ split(scriptease#capture('undolist'), '\n')[-8:],
      \ "substitute(v:val, '\\s\\+', ' ', 'g')")), ' |')

" Clear undo history (:w to clear the undo file if presented)
command! -bar UndoClear execute 'set undolevels=-1 |move -1 |'.
      \ 'let [&modified, &undolevels] = ['.&modified.', '.&undolevels.']'

" Repeat last change on each line in a visual selection
xnoremap . :normal! .<CR>

" Record and execute a recursive macro
nnoremap <silent>9q :call macro#recur<CR>
" Execute a macro repeatedly within a region
nnoremap <silent>@R :set operatorfunc=macro#repeat<CR>g@
xnoremap <silent>@ :<C-u>call macro#repeat()<CR>
" Execute a macro on each line within a region
nnoremap <expr>@L v:count1 == 1 ?
      \ ":set operatorfunc=macro#line<CR>g@" :
      \ ":call macro#line()<CR>"
xnoremap <silent>@L :call macro#line()<CR>
" Execute a macro without remapping
NXnoremap <expr> <silent> @N repeat(
      \ ':<C-U>normal! <C-R><C-R>'.nr2char(getchar()).'<CR>', v:count1)

" Keep the flags when repeating last substitution
NXnoremap & :&&<CR>

" Refine the last command
NXnoremap @<Space> @:
NXnoremap @; :verbose @:<CR>
NXnoremap @: :Verbose @:<CR>

" }}}
" Diff:" {{{

xnoremap <silent> do :execute &diff ? "'<,'>diffget" : ''<CR>
xnoremap <silent> dp :execute &diff ? "'<,'>diffput" : ''<CR>
nnoremap <silent> du :execute &diff ? 'diffupdate' : ''<CR>
" Switch off diff mode and close other diff panes
nnoremap dO :diffoff \| windo if &diff \| hide \| endif<CR>
" Diff with another file
command! -nargs=? -complete=buffer DiffWith call diff#with(<f-args>)

" }}}
" Spell:" {{{

let $MYSPELL = $MYVIM.'/spell'
if ! isdirectory($MYSPELL) " a junction point is not accessible in WSL
  let $MYSPELL =  $MYVIM.'/after/spell'
endif

" Enable spell checking for particular file types
augroup init_spell | autocmd!
  autocmd FileType gitcommit,markdown,txt setlocal spell
augroup END
if has('patch-7.4.088')
  set spelllang=en,cjk " skip spell check for East Asian characters
endif
set spellfile=$MYSPELL/en.utf-8.add
" Clean up spell files
command! SpellCleanup silent runtime spell/cleanadd.vim

" Dictionary files
let s:dictionary = $MYSPELL.'/dictionary-oald.txt'
if filereadable(s:dictionary)
  let &dictionary = s:dictionary
elseif !has('win32')
  set dictionary=/usr/share/dict/words
else
  set dictionary=spell " completion from spelling as an alternative
endif

" Thesaurus files
set thesaurus=$MYSPELL/thesaurus-mwcd.txt

"}}}
" Persistence:" {{{

if !isdirectory($MYTMP) | call mkdir($MYTMP) | endif

" - Remember UPPER_CASE global variables
" - Max number of files in which marks are remembered (:oldfiles)
" - Paths for which no marks will be remembered
" - Max number of lines saved for each register
" - Maximum size of an item contents in KiB
" - viminfo(shada) file name
let &viminfo = "!,'1000,r".$TMP.',<1000,s100,'.
      \ 'n'.$MYTMP.'viminfo'.(has('nvim')?'.shada':'')
let _viminfo = &viminfo " for easy restoration

" Exclude options and mappings and be portable
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize,slash,unix
set viewoptions=folds,cursor,slash,unix

let &swapfile = g:l ? 0 : 1 " use a swapfile for the buffer
set undofile " undo history across sessions

" Set default paths of temporary files
let opts = {'directory': 'swap//', 'undodir': 'undo', 'backupdir': 'backup'}
for [opt, val] in items(opts)
  let dir = $MYTMP.val
  if !isdirectory(dir) | silent! call mkdir(dir) | endif
  execute 'set' opt.'^='.dir
endfor
set viewdir=$MYTMP/view

" }}}
" Readline:" {{{

" Readline style insertion adjusted for Vim
" - https://github.com/tpope/vim-rsi
" - https://github.com/bruno-/vim-husk

" Character wise
execute 'inoremap <C-f>' (has('patch-7.4.849') ? '<C-g>U' : '').'<Right>'
execute 'inoremap <C-b>' (has('patch-7.4.849') ? '<C-g>U' : '').'<Left>'
cnoremap <expr><C-f> getcmdpos() > strlen(getcmdline()) ? "<C-f>" : "<Right>"
cnoremap <C-b> <Left>
inoremap <expr> <C-D> col('.') > strlen(getline('.')) ? "<C-D>" : "<Del>"
cnoremap <expr> <C-D> getcmdpos() > strlen(getcmdline()) ? "<C-D>" : "<Del>"
" Transpose two characters around the cursor
cmap <script><C-t> <SID>transposition<SID>transpose
noremap! <expr><SID>transposition getcmdpos() > strlen(getcmdline()) ?
      \ "\<Left>" : getcmdpos()>1 ? '' : "\<Right>"
noremap! <expr><SID>transpose "\<BS>\<Right>"
      \ . matchstr(getcmdline()[0 : getcmdpos()-2], '.$')

" Word wise in Insert Mode
inoremap <M-f> <S-Right>
inoremap <M-b> <S-Left>
inoremap <M-F> <C-\><C-o>W
inoremap <M-B> <C-\><C-o>B
inoremap <C-BS> <C-\><C-o>"-db
inoremap <M-d>  <C-\><C-o>"-de
inoremap <C-w>  <C-\><C-o>"-dB
inoremap <M-D>  <C-\><C-o>"-dE
" To not split undo, invode built-in <C-w> and <C-u>. But be aware they stops
" once at the start position of insert.
inoremap <M-BS> <C-w>

" Word wise in Cmdline Mode
" Compared to in Insert Mode, they behave like in Shells so that less motions
" are needed to go to a specific position.
cnoremap <expr><M-f> readline#word("\<Right>")
cnoremap <expr><M-b> readline#word("\<Left>")
cnoremap <M-F> <S-Right>
cnoremap <M-B> <S-Left>
" Delete till a non-keyword
cnoremap <expr><M-BS> readline#word("\<BS>")
cnoremap <expr><M-d> readline#word("\<Del>")
" Delete till a space
cnoremap <expr><C-w> readline#word("\<BS>", 1)
cnoremap <expr><M-D> readline#word("\<Del>", 1)

" In-line wise
inoremap <C-A> <C-O>^
cnoremap <C-A> <Home>
cnoremap <C-x>a <C-a>
inoremap <C-e> <End>
inoremap <C-g><C-e> <C-e>
inoremap <expr><C-u> "<C-\><C-o>d".
      \(search('^\s*\%#', 'bnc', line('.')) > 0 ? '0' : '^')
cnoremap <expr><C-u> readline#head()
inoremap <C-k> <C-\><C-o>D
cnoremap <expr><C-k> readline#tail()

inoremap <expr><C-y> pumvisible() ? "<C-y>" : "<C-r>-"
cnoremap <C-y> <C-r>-
inoremap <C-g><C-y> <C-y>
inoremap <C-g><C-b> <C-y>

cnoremap <M-p> <Up>
cnoremap <M-n> <Down>

" }}}
" Appearance:" {{{

" Make it easy to spot the cursor, especially for Gnome-terminal whose cursor
" color is not distinguishable.
set cursorline " 'cursorcolumn'
set guicursor+=a:blinkon0 " don't blink the cursor
if has('multi_byte_ime')
  highlight CursorIM guifg=NONE guibg=green
endif
let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1

set relativenumber " 'number'
set numberwidth=3 " narrowed
set colorcolumn=+1 " highlight column after 'textwidth'

set showcmd " show partial typings of a mapping or command
" Show matching pairs like (), [], etc.
" {{{
" set showmatch matchtime=1 " highlighting in plugin/matchparen.vim is better
augroup init_matchparen | autocmd!
  autocmd ColorScheme * hi MatchParen cterm=underline ctermbg=NONE ctermfg=NONE
        \ gui=underline guibg=NONE guifg=NONE
augroup END
" Enable or disable it due to the cost of frequently executed autocmds
nnoremap <expr>c\m ':'.(exists('g:loaded_matchparen') ? 'NoMatchParen' : 'DoMatchParen')."<CR>"
" }}}
" List special or abnormal characters
" {{{
set list " show non-normal spaces, tabs etc.
if &encoding ==# 'utf-8' || &termencoding ==# 'utf-8'
  " Special unicode characters/symbols:
  " ¬ ¶ ⏎ ↲ ↪ ␣ ¨⠉⠒⠤⣀ ⣿ │ ░ ▒ ⇥ → ← ⇉ ⇇ ❯ ❮ » « ↓ ↑
  " ◉ ○ ● • · ■ □ ¤ ▫ ♦ ◆ ◇ ▶ ► ▲ ▸ ✚ ★ ✸ ✿ ✜ ☯ ☢ ❀ ✨ ♥ ♣ ♠
  let s:lcs = split(s:windows ? '· · » « ·' : '· ␣ ❯ ❮ ␣')
  let &showbreak = s:windows ? '→' : '╰' " └ ∟ ╰ ╘ ╙ τ Ŀ
  set fillchars=vert:│,fold:-,diff:-
else
  let s:lcs = ['>', '-', '>', '<', '+']
endif
execute 'set listchars=tab:'.s:lcs[0].'\ ,trail:'.s:lcs[1]
      \ .',extends:'.s:lcs[2].',precedes:'.s:lcs[3].',nbsp:'.s:lcs[4]
" Avoid showing trailing whitespace when in insert mode
augroup init_listchars | autocmd!
  execute 'autocmd InsertEnter * set listchars-=trail:'.s:lcs[1]
  execute 'autocmd InsertLeave * set listchars+=trail:'.s:lcs[1]
augroup END
" }}}
silent! set breakindent linebreak " don't wrap lines at the screen end

" Set background color based on day or night
if has('vim_starting') "{{{
  let s:hour = strftime('%H')
  let &background = s:hour < 17 && s:hour > 6 ?
        \ 'light' : 'dark'
endif "}}}

" Font and window size
if has('vim_starting') && has('gui_running') "{{{
  " Note: also set in ginit.vim
  let &guifont = has('win32') ? 'Consolas:h10' : 'Consolas 10'
  set linespace=0
  set lines=40 columns=88
  if !g:l " maximize the window
    if has('win32')
      augroup init_max_vim | autocmd!
        autocmd GUIEnter * simalt ~x
      augroup END
    else
      set lines=400 columns=300
    endif
  endif
endif "}}}

" Setup and forget
set display+=lastline
set guiheadroom=0 " occupy more screen space on X11

" Highlight strings inside C comments.
let c_comment_strings=1

" }}}
" Helpline:" {{{

" This file is written with the confidence that it's sourced here.
" I move the implementation details out to make this init file clearer.
source $MYVIM/autoload/helpline.vim

let g:statusline = {} " flags to be inserted into 'statusline'
set statusline=%!helpline#statusline()
set fillchars+=stl::,stlnc:: " characters to fill the statuslines
set noshowmode " mode message hides normal messages and is redundant
set laststatus=2 " always display the status line

" Use CTRL-G, G_CTRL-G to see file and cursor information manually
set ruler " not effective when 'statusline' is set
set rulerformat=%50(%=%m%r%<%f%Y\ %c,%l/%L,%P%)

let g:tabline = {} " flags to be inserted into 'tabline'
set tabline=%!helpline#tabline()
let &showtabline = 1
nnoremap cot :let &showtabline = &showtabline == 1 ? 2 : 1<CR>

if exists('$TMUX')
  " autocmd init FocusLost,VimLeavePre * set titlestring=
else
  set title " may not be able to be restored
endif

augroup init_color | autocmd!
  autocmd ColorScheme * call color#highlight()
augroup END

" }}}
" Terminal:"{{{

if !has('gui_running') && has('vim_starting')
  " 24bit colors
  if has('patch-7.4.1799') && !s:windows && $TERM !~ 'rxvt'
    set termguicolors
  endif
  " Assume 256 colors
  if &term =~ '\v(xterm|screen)$' | let &term .= '-256color' | endif
  " Disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " See also http://snk.tuxfamily.org/log/vim-256color-bce.html
  if &term =~ '256col' | set t_ut= | endif
  " Allow color schemes do bright colors without forcing bold.
  if &t_Co == 8 && &term !~ '^linux' | set t_Co=16 | endif
  if !has('nvim')
    " Make `!ls` in `vim` sensible.
    augroup init_terminal | autocmd!
      autocmd VimEnter * call term#altscreen(0)
      autocmd VimLeave * call term#altscreen()
    augroup END
    noremap <silent><C-z> :<C-u>call term#suspend()<CR>
  endif
endif
" Disable error beep and screen flash
" autocmd init GUIEnter * set vb t_vb=

if has('nvim') " nvim's built-in terminal
  tnoremap <M-i> <C-\><C-N>
  tnoremap <M-I> <C-\><C-N>:
  tnoremap <M-V> <C-\><C-N>pi
  " In case the terminal didn't bind this key to paste, but <C-v> would be
  " shadowed when Neovim doesn't distinguish between these two keys.
  " tnoremap <C-S-v> <C-\><C-N>"+pi

  tnoremap <expr><M-w> winnr('$') == 1 ? "\<Esc>w" : "\<C-\>\<C-n>\<C-w>"
  tnoremap <expr><M-j> winnr('$') == 1 ? "\<Esc>j" : "\<C-\>\<C-n>\<C-w>w"
  tnoremap <expr><M-k> winnr('$') == 1 ? "\<Esc>k" : "\<C-\>\<C-n>\<C-w>W"
  tmap <M-J> <M-j>i
  tmap <M-K> <M-k>i
  tmap     <expr><M-a> "\<C-\>\<C-n>\<M-a>"

  tnoremap <S-PageUp> <C-\><C-n><C-b>
  tnoremap <S-PageDown> <C-\><C-n><C-f>
  tnoremap <C-PageUp> <C-\><C-n><C-b>
  tnoremap <C-PageDown> <C-\><C-n><C-f>

  " Insert a surrounding pair of (), [], etc.
  tnoremap <expr><M-s> b#surround#()

  cnoreabbrev <expr>st getcmdtype() == ':' && getcmdpos() == 3 ? 'new\|te' : 'st'
  cnoreabbrev <expr>vt getcmdtype() == ':' && getcmdpos() == 3 ? 'vne\|te' : 'vt'
  cnoreabbrev <expr>tt getcmdtype() == ':' && getcmdpos() == 3 ? 'tab new\|te' : 'tt'

  let g:terminal_scrollback_buffer_size = 5000
  augroup init_term | autocmd!
    " Use `so` and related mappings to auto-enter terminal mode.
    " autocmd BufWinEnter,WinEnter term://* startinsert
    " Prevent from entering Insert Mode in a non-terminal buffer, when e.g.
    " a session is being restored in which `startinsert` is delayed.
    autocmd BufLeave term://* stopinsert
    autocmd TermOpen * setlocal nolist
    autocmd TermClose *#* call feedkeys("\<Plug>", 'n')
  augroup END
endif

"}}}
" Shell:"{{{
" Note: This section deals with the terminal text, not necessarily a shell.

if has('nvim')
  command! -count=1 -nargs=? S call term#shell(<count>, <q-args>)
  " mnemonic: SheO
  nnoremap <silent>so :<C-u><C-r>=v:count1<CR>S<CR>
  nmap <silent>sO :<C-u>keepalt split _ \| <C-r>=v:count1<CR>S<CR>
  nmap <silent>s<M-o> :<C-u>keepalt vsplit _ \| <C-r>=v:count1<CR>S<CR>
  nnoremap s<Space> :<C-u><C-r>=v:count ? v:count : ''<CR>S<Space><C-v><C-u>

  nnoremap <silent>S :<C-u>set operatorfunc=term#send<CR>g@
  nmap Ss SVl
  xnoremap <silent>S :<C-u>call term#send(visualmode())<CR>
endif

"}}}
" Bundles:" {{{

if has('vim_starting')
  runtime init..vim " bundle configuration
  let $MYVIMRCAFTER = expand($MYVIM.'/init+.vim')
  if filereadable($MYVIMRCAFTER)
    execute 'silent source' $MYVIMRCAFTER
  endif
  call bundle#done() " inject bundle paths to 'rtp'
endif

" }}}
" Misc:" {{{

if has('vim_starting')
  set autoindent " indent at the same level of the previous line
  set shiftwidth=2 " number of spaces to use for each step of (auto)indent
  set shiftround " round indent to multiple of 'shiftwidth'
  set tabstop=4 " 4 is common if 'noexpandtab'
  set softtabstop=2 " number of spaces used when press <Tab> or <BS>
  set expandtab " expand a tab to spaces
  set smarttab " <Tab> in front of a line inserts blanks according to 'shiftwidth'
endif
set mouse=nvi " exclude cmdline mode as I was disturbed
nnoremap <silent>com :let &mouse = &mouse =~ 'n' ? 'vi' : 'nvi'<CR>
" Sync visual mode selection with the selection register(*) in supported GUI
execute has('gui_gtk')||has('gui_motif')||has('gui_athena') ? 'set go+=a' : ''
" set clipboard+=unnamed " sync the selection register with the unnamed register
set scrolloff=1 " also set in CmdwinLeave
set sidescrolloff=5 " minimal number of screen columns to keep around the cursor
set backspace=indent,eol,start " backspace through anything in insert mode
set nrformats-=octal " 01 is treated as decimal
set lazyredraw " don't redraw the screen while executing macros, etc.
set shortmess=aoOtTI " avoid all the hit-enter prompts caused by file messages
if has('patch-7.4.1570')
  set shortmess+=F
endif
set guioptions=M " skip sourcing menu.vim, before enabling filetype/syntax
set guioptions+=c " use a console dialog for confirmation instead of a pop-up
" set guioptions+=a " visual selection syncs to the X11 primary selection
set confirm " prompt for an action instead of fail immediately
set winminheight=0 " the minimal height of a window
set history=10000 " maximum number of commands and search patterns to keep
set synmaxcol=999 " ignore further syntax items to avoid slow redrawing
silent! set cryptmethod=blowfish cryptmethod=blowfish2 " medium strong
silent! set nolangremap " or 'langnoremap', for 'langmap'
if 0 && has('win32') " disabled due to non-decent performance
  set renderoptions=type:directx
endif
" Make 'cw' consistent with 'dw'
" onoremap <silent> w :execute 'normal! '.v:count1.'w'<CR>

silent! set formatoptions+=rojmM " deal with comments and multi-bytes
set nojoinspaces " not two spaces between joined sentences
" Join lines without any character or with specified characters in between
command! -range -nargs=? -bang J execute
      \ 'keepp <line1>,'.(<line1> == <line2> ? <line2> : <line2>-1).
      \ 's/\s*\n\s*/'.escape(<bang>0 ? <q-args> : ' '.<q-args>, '/\&~')
nnoremap <silent>sJ :J!<CR>
" Remove trailing white spaces
command! -range=% Trim let _p=getpos('.')|
      \keepj keepp <line1>,<line2>s/\s\+$//| call setpos('.',_p)
" Remove duplicate lines:" {{{
" Remove duplicate, consecutive lines (:sort /.\_^/ u)
command! -range=% Uniqc <line1>,<line2>g/\v^(.*)\n\1$/d
" Remove duplicate, nonconsecutive and nonempty lines (g/\v^(.+)$\_.{-}^\1$/d)
command! -range=% Uniqn <line1>,<line2>g/^./
      \ if search('^\V'.escape(getline('.'),'\').'\$', 'bW') |
      \ delete | endif <NL> silent! normal! ``
" }}}
" Mystify texts
command! Mystify call crypt#mystify()
" Reverse the selected text
command! -range Reverse execute "normal! `<dv`>" | set revins |
      \ execute 'normal! i<C-R>"' | set norevins
" Statistics:" {{{
" Count anything in a range of lines
command! -range=% -nargs=? Count echo stat#count
      \(<q-args>, <line1>, <line2>) | normal ``
" Calculate words frequency
command! -range=% WordFrequency echo stat#word_frequency(<line1>, <line2>)
" Calculate the total lines of source code minus blank lines and comment lines.
command! -range=% SLOC echo stat#count
      \('^[^' . &cms[0] . ']', <line1>, <line2>) | normal ``
" Print the ASCII table in a split window
command! -nargs=? ASCII call ascii#print(<f-args>)
" }}}
" Write HELP docs
command! HelpWrite setlocal buftype= buflisted modifiable noreadonly |
      \ mapclear <buffer> | mapclear! <buffer> |
      \ silent! unlet b:did_ftplugin b:did_after_ftplugin | filetype detect |
      \ setlocal conceallevel=0 spell
" Toggle automation of state toggle of IME(Fcitx)
nnoremap <silent>c<Leader>i :call ime#auto()<CR>

if has('vim_starting')
  " Must be after setting 'rtp'
  filetype plugin indent on
  syntax enable
endif

" }}}

" vim:fdm=marker:
