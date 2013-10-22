" Description: Vim configuration for the default version.
" Author: Bohr Shaw <pubohr@gmail.com>

" Note:
" In order to reduce the startup time, you can do profiling with this command:
" vim --startuptime startup_profiling

" Core configuration
source ~/.vim/vimrc.core

" Bundle configuration
source ~/.vim/vimrc.bundle

" Set these after rtp setup, but as early as possible to reduce startup time.
filetype plugin indent on
syntax enable

" Choose a color scheme
if has('gui_running') || &t_Co == 256
  color solarized
else
  color terminater
endif

" vim:ft=vim tw=78 et sw=2 nowrap:
