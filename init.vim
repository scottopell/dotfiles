call plug#begin()

" Theme
Plug 'lifepillar/vim-gruvbox8'
"  Visual Indent Guides
Plug 'nathanaelkane/vim-indent-guides'
"  Replacement for matchparen and matchit (extra % matching)
Plug 'andymass/vim-matchup'
" Select an indentation level
Plug 'scottopell/vim-indent-object'
" FZF
Plug 'junegunn/fzf'
" TODO - need both of these?
Plug 'junegunn/fzf.vim'
" Navigate vim and tmux splits interchangeably
Plug 'christoomey/vim-tmux-navigator'
"  Allows for easy alignment/formatting of code to line up vertically
Plug 'godlygeek/tabular'
"  Tab nav bar editor
Plug 'mkitt/tabline.vim'
" Syntax for typescript
Plug 'HerringtonDarkholme/yats.vim'
" Provides :OpenGithub which opens the remote with current HEAD as SHA
Plug 'k0kubun/vim-open-github'
" Better defaults for browsing dir trees
Plug 'tpope/vim-vinegar'
" Directory Browser
Plug 'justinmk/vim-dirvish'
" Save last cursor position
Plug 'farmergreg/vim-lastplace'
" LSP configs
Plug 'neovim/nvim-lspconfig'
" File Finder
Plug 'nvim-telescope/telescope.nvim'
" Dependency of above
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
" Rust
Plug 'rust-lang/rust.vim'

call plug#end()

" Mouse mode (scroll, visual select, etc)
set mouse=a " a for all

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


" Always show statusline
set laststatus=2

" Custom statusline
set statusline=[%n]\ %f%m\ \ col\ %c\ \|\ %b\ 0x%B

" Colors
set background=dark
colorscheme gruvbox8

" Automatically wrap at 80 characters for Markdown
autocmd BufRead,BufNewFile *.md,*.markdown setlocal textwidth=80

" Details for all these options
" https://web.archive.org/web/*/http://tedlogan.com/techblog3.html
function! SetTabWidth(width)
  " How many chars to render a tab character as
  let &tabstop=a:width

  " This one is subtle/confusing. Read about it at the above link
  let &softtabstop=a:width

  " How many columns to use when indenting with >> << operations
  let &shiftwidth=a:width

  " Hitting tab will insert N spaces
  let &expandtab = 1
endfunction


"  My default tabs are 4 spaces.
call SetTabWidth(4)

" Set leader key to comma
let mapleader=','

" This makes normally invisible whitespace visible.
" Specifically, trailing whitespace and hard tabs
set list listchars=trail:·,tab:»·

" don't highlight all instances when searching
" This is useful occasionally, but I just turn it on manually in those cases.
set nohls

" Enable async paren matching -- MUST HAVE
let g:matchup_matchparen_deferred = 1

" Enable rust autofmt
let g:rustfmt_autosave = 1

" fzf.vim
nnoremap <silent> <C-p> <cmd>Telescope find_files<cr>
" Need to over-write dirvish's built-in ctrl-p mapping
autocmd FileType dirvish nnoremap <buffer><silent> <C-p> <cmd>Telescope find_files<cr>

" WIP - it currently searches for 'word' instead of word
" Goal: search for word under cursor
nnoremap <silent> <leader>g :Rg <C-r>=expand('<cword>') <cr> <cr>

" Clear last highlight pattern on Enter
nnoremap <silent> <CR> :let @/ = "" <CR> <CR>

fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

autocmd BufWritePre * :call TrimWhitespace()

" TODO - copy out lsp configs that are desired and setup key mappings

autocmd BufRead,BufNewFile *.log set nowrap
autocmd BufRead,BufNewFile *.log set hls

" In terminal-mode, map ESC to exit terminal-mode
tnoremap <Esc> <C-\><C-n>

