lua << EOF
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Theme
  { "lifepillar/vim-gruvbox8" },

  -- Visual Indent Guides
  { "nathanaelkane/vim-indent-guides" },

  -- Replacement for matchparen and matchit (extra % matching)
  { "andymass/vim-matchup", event = "VeryLazy" },

  -- Select an indentation level
  { "scottopell/vim-indent-object" },

  -- FZF
  { "junegunn/fzf", build = ":call fzf#install()" },
  { "junegunn/fzf.vim", dependencies = { "junegunn/fzf" } },

  -- Navigate vim and tmux splits interchangeably
  { "christoomey/vim-tmux-navigator" },

  -- Allows for easy alignment/formatting of code to line up vertically
  { "godlygeek/tabular", cmd = "Tabularize" },

  -- Tab nav bar editor
  { "mkitt/tabline.vim" },

  -- Syntax for typescript
  { "HerringtonDarkholme/yats.vim", ft = { "typescript", "typescriptreact" } },

  -- Provides :OpenGithubFile which opens the remote with current HEAD as SHA
  { "tyru/open-browser-github.vim", cmd = "OpenGithubFile", dependencies = { "tyru/open-browser.vim" } },
  { "tyru/open-browser.vim" },

  -- Directory Browser
  { "justinmk/vim-dirvish" },

  -- Save last cursor position
  { "farmergreg/vim-lastplace" },

  -- LSP configs
  { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },

  -- File Finder
  { "nvim-telescope/telescope.nvim", cmd = "Telescope", keys = "<C-p>", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-lua/plenary.nvim" },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", event = { "BufReadPost", "BufNewFile" } },

  -- Rust
  { "rust-lang/rust.vim", ft = "rust" },

  -- Go
  { "fatih/vim-go", ft = "go", build = ":GoUpdateBinaries" },

  -- Convert between snake case, camelcase, pascalcase, etc
  { "johmsalas/text-case.nvim", event = "VeryLazy" },
})
EOF

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
set statusline=[%n]\ %f%m\ %=\ \ col\ %c\ \|\ %b\ 0x%B\ \|\ %2p%%

" Colors
set background=light
colorscheme gruvbox8

" Automatically wrap at 80 characters for Markdown
autocmd BufRead,BufNewFile *.md,*.markdown setlocal textwidth=80
" Detect lots of file extensions as markdown
au BufNewFile,BufRead *.markdown,*.mdown,*.mkd,*.mkdn,*.mdwn,*.md  set ft=markdown


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

" Except for yaml
autocmd FileType yaml call SetTabWidth(2)

" Git config files should use tabs
autocmd BufRead,BufNewFile gitconfig set filetype=gitconfig
autocmd FileType gitconfig setlocal noexpandtab tabstop=8 softtabstop=8 shiftwidth=8

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

" 'goimports' is a tool that both formats and fixes imports (removes unused
" ref, adds refs as needed)
let g:go_fmt_command = "goimports"

if luaeval('jit and string.find(jit.version, "LuaJIT")')
    " telescope
    nnoremap <silent> <C-p> <cmd>Telescope find_files<cr>
    " Need to over-write dirvish's built-in ctrl-p mapping
    autocmd FileType dirvish nnoremap <buffer><silent> <C-p> <cmd>Telescope find_files<cr>
else
    " Remove me when either debian packages arm64 with luajit
    " or when telescope stops relying on luajit specific features
    " see https://github.com/nvim-telescope/telescope.nvim/issues/1174

    " FZF
    nnoremap <silent> <C-p> <cmd>FZF<cr>
    " Need to over-write dirvish's built-in ctrl-p mapping
    autocmd FileType dirvish nnoremap <buffer><silent> <C-p> <cmd>FZF<cr>
endif


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

lua << EOF
local nvim_lsp = require'lspconfig'

local on_attach = function(client)
    -- TODO - this is broken, remove and replace with a different completion,
    -- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
    -- require'completion'.on_attach(client)
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n' , 'gD'         , '<cmd>lua vim.lsp.buf.declaration()<CR>'     , opts)
  buf_set_keymap('n' , 'gd'         , '<cmd>lua vim.lsp.buf.definition()<CR>'      , opts)
  buf_set_keymap('n' , 'gr'         , '<cmd>lua vim.lsp.buf.references()<CR>'      , opts)
  buf_set_keymap('n' , 'K'          , '<cmd>lua vim.lsp.buf.hover()<CR>'           , opts)
  buf_set_keymap('n' , 'gi'         , '<cmd>lua vim.lsp.buf.implementation()<CR>'  , opts)
  buf_set_keymap('n' , '<leader>D'  , '<cmd>lua vim.lsp.buf.type_definition()<CR>' , opts)
  buf_set_keymap('n' , '<leader>rn' , '<cmd>lua vim.lsp.buf.rename()<CR>'          , opts)
  buf_set_keymap('n' , '<leader>ca' , '<cmd>lua vim.lsp.buf.code_action()<CR>'     , opts)
  buf_set_keymap('n' , '<leader>e'  , '<cmd>lua vim.diagnostic.open_float()<CR>'   , opts)
  buf_set_keymap('n' , '[d'         , '<cmd>lua vim.diagnostic.goto_prev()<CR>'    , opts)
  buf_set_keymap('n' , ']d'         , '<cmd>lua vim.diagnostic.goto_next()<CR>'    , opts)
  buf_set_keymap('n' , '<leader>q'  , '<cmd>lua vim.diagnostic.setloclist()<CR>'   , opts)
  buf_set_keymap('n' , '<leader>f'  , '<cmd>lua vim.lsp.buf.formatting()<CR>'      , opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'rust_analyzer', 'ts_ls', 'gopls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- Treesitter configuration
local status, treesitter = pcall(require, 'nvim-treesitter.configs')
if status then
  treesitter.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "lua", "vim", "vimdoc", "query", "go", "rst", "rust", "typescript", "javascript", "yaml", "powershell" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  }
else
  vim.notify("nvim-treesitter not installed. Run :PlugInstall to enable syntax highlighting.", vim.log.levels.WARN)
end

EOF

autocmd BufRead,BufNewFile *.log set nowrap
autocmd BufRead,BufNewFile *.log set hls

" In terminal-mode, map ESC to exit terminal-mode
tnoremap <Esc> <C-\><C-n>

" Highlight current row in active pane
augroup BgHighlight
    autocmd!
    autocmd WinEnter * set cul
    autocmd WinLeave * set nocul
augroup END
