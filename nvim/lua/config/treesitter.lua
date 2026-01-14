-- Treesitter configuration
-- Parsers to ensure are always installed
local ensure_installed = {
  "bash", "dockerfile", "gitcommit", "gitignore", "go", "javascript",
  "json", "lua", "markdown", "powershell", "python", "query", "requirements",
  "rst", "rust", "toml", "tsv", "tsx", "typescript", "vim", "vimdoc", "yaml"
}

local status, treesitter = pcall(require, 'nvim-treesitter.configs')
if status then
  treesitter.setup {
    ensure_installed = ensure_installed,

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  }
else
  vim.notify("nvim-treesitter not installed. Run :Lazy sync to install plugins.", vim.log.levels.WARN)
end

-- Treesitter textobjects (main branch uses separate setup)
local status_textobjects, textobjects = pcall(require, 'nvim-treesitter-textobjects')
if status_textobjects then
  textobjects.setup {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  }
end