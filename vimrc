" Vundle
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/vundle'

" Bundles
"  Syntax
Plugin 'tpope/vim-haml'
Plugin 'tpope/vim-markdown'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-rails'
Plugin 'kchmck/vim-coffee-script'
Plugin 'tpope/vim-rake'
"  Auto-adds ruby 'end' with def
Plugin 'tpope/vim-endwise'
"  Syntax Checker
Plugin 'scrooloose/syntastic'
"  Theme
Plugin 'vim-scripts/xoria256.vim'
"  Code Completion
if version >=703 && has("patch 538")
  Plugin 'Valloric/YouCompleteMe'
endif
"  Visual indent guides
Plugin 'nathanaelkane/vim-indent-guides'
"  Provides extra % matching (xml etc)
Plugin 'tmhedberg/matchit'
"  Select an indentation level
Plugin 'scottopell/vim-indent-object'
"  File Finder
Plugin 'kien/ctrlp.vim'
"  Git Wrapper
Plugin 'tpope/vim-fugitive'
"  Navigate vim and tmux splits interchangeably
Plugin 'christoomey/vim-tmux-navigator'
"  git gutter
Plugin 'airblade/vim-gitgutter'
"  Auto-adds delimeters in many languages
Plugin 'Raimondi/delimitMate'
"  Allows for easy alignment/formatting of code to line up vertically
Plugin 'godlygeek/tabular'
"  Expands vim's css highlighting with css3 features
Plugin 'hail2u/vim-css3-syntax'

call vundle#end()

filetype plugin indent on

" Set leader key to comma
let mapleader=','

" make backspace work as expected
set backspace=eol,start,indent

" ListChars
set list lcs=trail:·,tab:»·

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

" usefull in diffs with difftool(vimdiff) potentially many files to edit
cnoreabbrev qq qall

" respect the 80 (eighty) column convention
set colorcolumn=80

" space centers current line
nmap <space> zz

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

"  Mappings for Tabularize.
if exists(":Tabularize")
  nmap <Leader>a= :Tabularize /=<CR>
  vmap <Leader>a= :Tabularize /=<CR>
  nmap <Leader>a: :Tabularize /:\zs<CR>
  vmap <Leader>a: :Tabularize /:\zs<CR>
endif

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

