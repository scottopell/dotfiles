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

    -- Treesitter textobjects
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
    },
  }
else
  vim.notify("nvim-treesitter not installed. Run :PlugInstall to enable syntax highlighting.", vim.log.levels.WARN)
end

-- Simple helper: notify when auto_install downloads a new parser
local installed_parsers = {}
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
    if not lang then return end

    local parsers = require('nvim-treesitter.parsers')
    if parsers.has_parser(lang) and not installed_parsers[lang] then
      installed_parsers[lang] = true

      -- Check if it's in ensure_installed
      local is_ensured = false
      for _, p in ipairs(ensure_installed) do
        if p == lang then
          is_ensured = true
          break
        end
      end

      if not is_ensured then
        vim.notify(
          string.format(
            'Parser "%s" was auto-installed. Add to ensure_installed in nvim/lua/config/treesitter.lua:4',
            lang
          ),
          vim.log.levels.INFO
        )
      end
    end
  end,
})