require("lazy").setup({
  -- Theme
  { "lifepillar/vim-gruvbox8" },      -- gruvbox8
  { "embark-theme/vim", name = "embark", branch = "main" }, -- embark
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 }, -- tokyonight / -storm / -moon / -day
  "EdenEast/nightfox.nvim", -- carbonfox, nightfox, etc.
  "navarasu/onedark.nvim",      -- onedark
  "rebelot/kanagawa.nvim",      -- kanagawa-wave / -dragon / -lotus
  "nyoom-engineering/oxocarbon.nvim", -- oxocarbon
  "ellisonleao/gruvbox.nvim",   -- gruvbox
  "shaunsingh/nord.nvim",       -- nord

  -- Visual Indent Guides
  { "nathanaelkane/vim-indent-guides" },

  -- Treesitter-based text objects and navigation
  { "nvim-treesitter/nvim-treesitter-textobjects", dependencies = { "nvim-treesitter/nvim-treesitter" } },

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
  { "nvim-telescope/telescope.nvim", event = "VimEnter", dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim"
  } },
  { "nvim-lua/plenary.nvim" },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", event = { "BufReadPost", "BufNewFile" } },

  -- Rust
  { "rust-lang/rust.vim", ft = "rust" },

  -- Go
  { "fatih/vim-go", ft = "go", build = ":GoUpdateBinaries" },

  -- Convert between snake case, camelcase, pascalcase, etc
  { "johmsalas/text-case.nvim", event = "VeryLazy" },

  -- Scroll above top of screen for better tall monitor viewing
  {
    "nullromo/go-up.nvim",
    opts = {},
    config = function(_, opts)
        local goUp = require("go-up")
        goUp.setup(opts)
    end
  },

  -- Start screen dashboard
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')


      -- ASCII art header
      dashboard.section.header.val = {
        "█▄░█ ▄▀█ █░█ █ █▀▄▀█",
        "█░▀█ █▀█ ▀▄▀ █ █░▀░█"
      }

      -- Info section with path, git, and tips
      local info_section = {
        type = "text",
        val = function()
          local cwd = vim.fn.getcwd()
          local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
          if branch == "" then branch = "not a git repo" end

          -- Tips that rotate randomly
          local tips = {
            "💡 Tip: <leader>gpl → <leader>grs → select lines → <leader>gca → :w → <leader>grf",
            "💡 Tip: Use <leader>sw to search word under cursor with Telescope",
            "💡 Tip: <leader>. shows recent files, <leader><leader> shows buffers",
            "💡 Tip: In PR review, select lines in visual mode before <leader>gca",
            "💡 Tip: <leader>gsa adds suggestions, <leader>gca adds regular comments",
            "💡 Tip: <C-p> for file finder, <leader>sg for live grep",
            "💡 Tip: After <leader>gca write your comment, then :w to submit",
            "💡 Tip: <leader>g searches for word under cursor with Rg",
            "💡 Tip: <leader>grr resumes a paused PR review session",
            "💡 Tip: <leader>e toggles the file explorer sidebar"
          }

          math.randomseed(os.time())
          local shuffled = {}
          for i, tip in ipairs(tips) do
            shuffled[i] = tip
          end
          for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
          end
          local selected_tips = {shuffled[1], shuffled[2], shuffled[3]}

          return {
            "",
            "Path: " .. cwd,
            "Git Branch: " .. branch,
            "",
            selected_tips[1],
            selected_tips[2],
            selected_tips[3],
          }
        end,
        opts = {
          position = "center",
          hl = "Comment"
        }
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("p", "  GitHub PRs", ":Octo pr list <CR>"),
        dashboard.button("d", "  Diff view", ":lua diffview_picker()<CR>"),
        dashboard.button("g", "  Live grep", ":Telescope live_grep <CR>"),
        dashboard.button("?", "  Show keymaps", ":Telescope keymaps <CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      -- Custom layout with proper padding
      dashboard.config.layout = {
        { type = "padding", val = 10 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        info_section,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
      }

      alpha.setup(dashboard.config)
    end,
  },

  -- GitHub PR Review
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require"octo".setup({
        reviews = {
          auto_show_threads = true,
          focus = "right"
        }
      })
    end,
    cmd = "Octo",
  },

  -- Git diff viewer
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("diffview").setup({
        default_args = {
          DiffviewOpen = { "--imply-local" }
        }
      })
    end,
  },

  -- File tree sidebar
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          hijack_netrw_behavior = "disabled",
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = true,
          },
        },
        window = {
          position = "left",
          width = 35,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
        },
        default_component_configs = {
          git_status = {
            symbols = {
              -- Compatible with Nerd Font Mono
              -- Change types (what changed)
              added     = "+",
              modified  = "~",
              deleted   = "✖",
              renamed   = "➜",
              -- Staging status (hidden)
              untracked = "?",
              ignored   = "",
              unstaged  = "",
              staged    = "",
              conflict  = "!",
            }
          },
        },
      })
    end,
  },
})
