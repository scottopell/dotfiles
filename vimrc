" Vundle
set nocompatible
filetype off

call plug#begin('~/.vim/plugged')

" Bundles
"  Syntax
Plug 'tpope/vim-haml'
Plug 'tpope/vim-markdown'
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'kchmck/vim-coffee-script'
Plug 'tpope/vim-rake', { 'for': 'ruby' }
"  Auto-adds ruby 'end' with def
Plug 'tpope/vim-endwise', { 'for': 'ruby' }
"  Syntax Checker
Plug 'scrooloose/syntastic'
"  Theme
Plug 'vim-scripts/xoria256.vim'
"  Code Completion
if version >=703 && has("patch 538")
  Plug 'Valloric/YouCompleteMe', { 'do': './install.py  --clang-completer' }
  Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
endif
"  Visual indent guides
Plug 'nathanaelkane/vim-indent-guides'
"  Provides extra % matching (xml etc)
Plug 'tmhedberg/matchit'
"  Select an indentation level
Plug 'scottopell/vim-indent-object'
"  File Finder
Plug 'ctrlpvim/ctrlp.vim'
"  Git Wrapper
Plug 'tpope/vim-fugitive'
"  Navigate vim and tmux splits interchangeably
Plug 'christoomey/vim-tmux-navigator'
"  git gutter
Plug 'airblade/vim-gitgutter'
"  Auto-adds delimeters in many languages
Plug 'Raimondi/delimitMate'
"  Allows for easy alignment/formatting of code to line up vertically
Plug 'godlygeek/tabular'
"  Expands vim's css highlighting with css3 features
Plug 'hail2u/vim-css3-syntax',  { 'for': 'css' }
"  Commenter
Plug 'scrooloose/nerdcommenter'
"  Tab nav bar editor
Plug 'mkitt/tabline.vim'
"  Syntax for typescript
Plug 'leafgarland/typescript-vim'
"  Rust!
Plug 'rust-lang/rust.vim'
"  Elixir!
Plug 'elixir-lang/vim-elixir'
"  ES6, mostly for ` strings
Plug 'isRuslan/vim-es6'
"  GO
Plug 'fatih/vim-go'

call plug#end()

filetype plugin indent on

" Set leader key to comma
let mapleader=','

" make backspace work as expected
set backspace=eol,start,indent

" ListChars
set list listchars=trail:·,tab:»·

" syntax
syntax on
set foldmethod=manual
set nocursorcolumn
set nocursorline
syntax sync minlines=256


" Mouse mode (scroll, visual select, etc)
set mouse=a " a for all
" Send more characters for redraws
set ttyfast
" better speed with mouse selection within tmux
set ttymouse=xterm2

"let g:syntastic_check_on_open = 1
let g:syntastic_javascript_checkers = ['eslint']

let g:syntastic_enable_signs=1
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'

"let g:syntastic_enable_balloons = 1

" don't highlight all instances when searching
" CS computers set this by default...annoying
set nohls

" search as you type
set incsearch

" adds _ to the list of word separaters
"set iskeyword-=_

" ignore all files for ctrlp in gitignore (and git dir)
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

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

" Automatically wrap at 80 characters for Markdown
autocmd BufRead,BufNewFile *.md,*.markdown setlocal textwidth=80

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
  nnoremap <Leader>a= :Tabularize /=<CR>
  vnoremap <Leader>a= :Tabularize /=<CR>
  nnoremap <Leader>a: :Tabularize /:\zs<CR>
  vnoremap <Leader>a: :Tabularize /:\zs<CR>
endif

func! WordProcessorMode()
    setlocal formatoptions=t1
    setlocal textwidth=80
    map j gj
    map k gk
    setlocal smartindent
    setlocal spell spelllang=en_us
    set complete+=kspell
    setlocal noexpandtab
endfu
com! WP call WordProcessorMode()

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

"  Higlights the current line
"http://stackoverflow.com/questions/8750792/vim-highlight-the-whole-current-line
set cursorline

"  Custom Mappings
" uppercases the last word
"inoremap <leader>u <esc>vbUwa
"nnoremap <leader>u viwUw
" open vimrc in vert split
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
" source vimrc
nnoremap <leader>sv :source $MYVIMRC<cr>
