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


" ------ Sane Defaults
"  These are things that I believe should be on by default for all vim setups
filetype plugin indent on

" make backspace work as expected
set backspace=eol,start,indent

" Turn syntax highlighting on
syntax on

" Mouse mode (scroll, visual select, etc)
set mouse=a " a for all
" Send more characters for redraws
set ttyfast
" better speed with mouse selection within tmux
set ttymouse=xterm2

" search as you type
set incsearch

" Display line numbers
set nu

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

" Copy indent from current line when starting new line.
set autoindent

" Force 256 color mode even if vim can't autodetect it from your $TERM
set t_Co=256

if &term =~ '256color'
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also https://sunaku.github.io/vim-256color-bce.html
  set t_ut=
endif

" Automatically wrap at 80 characters for Markdown
autocmd BufRead,BufNewFile *.md,*.markdown setlocal textwidth=80

" Set better encryption if vim is new enough
" see https://dgl.cx/2014/10/vim-blowfish
if v:version > 704 || v:version == 704 && has("patch401")
  set cryptmethod=blowfish2
endif


" ------ Personal Preferences
"  These are things that I use that are purely personal preference

" Set leader key to comma
let mapleader=','

" This makes normally invisible whitespace visible.
" Specifically, trailing whitespace and hard tabs
set list listchars=trail:·,tab:»·

" I added these to help with slow syntax highlighting I was experiencing.
" Not sure if they're still necessary, but I don't see any harm in leaving
" them.
set foldmethod=manual
set nocursorcolumn
set nocursorline
syntax sync minlines=256

" don't highlight all instances when searching
" This is useful occasionally, but I just turn it on manually in those cases.
set nohls

" These set up 2 space tabs.
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" respect the 80 (eighty) column convention
set colorcolumn=80

" Colors
colorscheme xoria256

"  Higlights the current line
"http://stackoverflow.com/questions/8750792/vim-highlight-the-whole-current-line
set cursorline
" Its too slow in ruby, turn it off there.
au FileType ruby set nocursorline

" ------------ Plugin Specific Settings
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_enable_signs=1
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'

"  Mappings for Tabularize.
if exists(":Tabularize")
  nnoremap <Leader>a= :Tabularize /=<CR>
  vnoremap <Leader>a= :Tabularize /=<CR>
  nnoremap <Leader>a: :Tabularize /:\zs<CR>
  vnoremap <Leader>a: :Tabularize /:\zs<CR>
endif


" ignore all files for ctrlp in gitignore (and git dir)
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" Indent Guide
au VimEnter * :IndentGuidesEnable
let g:indent_guides_auto_colors = 0
" These values are specific to my color scheme, xoria256
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd ctermbg=236
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=238

" ------------ More advanced functions
"  These are things that I found online in various places that are more
"  significant changes than the above.

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
"
"  My main use for this is to remember where I left off editing a file.
"  eg, if I'm editing foo.cpp, then I close it, when I re-open foo.cpp, vim
"  will open up to the same line number
"  TODO this has a bug with opening multiple views into CWD (.)
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

" This is useful for writing long non-code pieces.
" It does a few things, the most useful is it will turn on word wrapping and
" remap j and k to go up and down visual lines instead of actual lines.
" See the help pages for the rest of these things.
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
