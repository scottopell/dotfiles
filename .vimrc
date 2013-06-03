syntax on
set nocursorcolumn
set nocursorline
syntax sync minlines=256

" Vundle
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
filetype plugin indent on
"Bundle 'gmarik/Vundle'

" Bundles
Bundle 'SuperTab'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-rake'
Bundle 'tpope/vim-endwise'
Bundle 'Raimondi/delimitMate'
Bundle 'vim-scripts/xoria256.vim'

" make backspace work as expected
set backspace=eol,start,indent

" Tabs
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent

" Set line numbers on
set nu

" space centers current line
nmap <space> zz

" Colors
set t_Co=256
colorscheme xoria256

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo
function! ResCur()
	if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

