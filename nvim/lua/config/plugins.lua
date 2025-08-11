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