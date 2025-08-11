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