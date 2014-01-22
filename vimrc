" Vundle
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

" Bundles
"  Syntax
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-markdown'
Bundle 'vim-ruby/vim-ruby'
Bundle 'tpope/vim-rails'
Bundle 'kchmck/vim-coffee-script'
Bundle 'tpope/vim-rake'
Bundle 'tpope/vim-endwise'
Bundle 'jcfaria/Vim-R-plugin'
"  Syntax Checker
Bundle 'scrooloose/syntastic'
"  Theme
Bundle 'vim-scripts/xoria256.vim'
"  code complete 
if version >=703 && has("patch 538")
  Bundle 'Valloric/YouCompleteMe'
endif
"  Visual indent guides
Bundle 'nathanaelkane/vim-indent-guides'
"  Provides extra % matching (xml etc)
Bundle 'tsaleh/vim-matchit'
"  Select an indentation level
Bundle 'michaeljsmith/vim-indent-object'
"  Toggle Line Comments
Bundle 'scrooloose/nerdcommenter'
"  File Finder
Bundle 'kien/ctrlp.vim'
"  Toggles Comments
Bundle 'tomtom/tcomment_vim'
"  Matlab
Bundle 'sgeb/vim-matlab'
"  Git Wrapper
Bundle 'tpope/vim-fugitive'
"  Ruby Documentation in vim
Bundle 'danchoi/ri.vim'
"  Navigate vim and tmux splits interchangeably
Bundle 'christoomey/vim-tmux-navigator'

filetype plugin indent on

" make backspace work as expected
set backspace=eol,start,indent


" syntax
syntax on
set foldmethod=manual
set nocursorcolumn
set nocursorline
syntax sync minlines=256

" don't highlight all instances when searching
" CS computers set this by default...annoying
set nohls

" search as you type
set incsearch

" adds _ to the list of word separaters
"set iskeyword-=_


" Tabs
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent

" Set line numbers on
set nu

" the more I think on this the less I like it, leave commented out for now
" If you use this, ~/.vim/undodir needs to be created manually(!!!)
" Persistent undo
"set undofile
" Keep these in the .vim dir, otherwise 
" there will be undofiles created everywhere
"set undodir=~/.vim/undodir


"  vim splits
" easier mappings for switching panes
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" better default behavior for where new splits go
set splitbelow
set splitright

" correct :W to :w #typo
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
" correct :Q to :q #typo
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))

" space centers current line
nmap <space> zz

" maps jj to <esc> in insert mode
imap hh <esc>

" Colors
set t_Co=256
colorscheme xoria256

" Indent Guide
au VimEnter * :IndentGuidesEnable
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd ctermbg=236
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=238

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

