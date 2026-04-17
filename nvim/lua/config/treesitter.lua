-- Treesitter configuration (nvim-treesitter `main` branch API).
--
-- The `main` branch is a full rewrite: no `configs.setup { ensure_installed, highlight.enable }`.
-- Instead: call `install()` to fetch parsers, and start highlighting via a FileType autocmd.

local ensure_installed = {
  "bash", "dockerfile", "gitcommit", "gitignore", "go", "javascript",
  "json", "lua", "markdown", "markdown_inline", "powershell", "python",
  "query", "requirements", "rst", "rust", "toml", "tsv", "tsx", "typescript",
  "vim", "vimdoc", "yaml",
}

local ok_ts, ts = pcall(require, "nvim-treesitter")
if ok_ts then
  ts.install(ensure_installed)

  -- Enable highlighting for any buffer whose filetype has an installed parser.
  -- `vim.treesitter.start()` errors when no parser exists, so guard with pcall.
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      pcall(vim.treesitter.start, args.buf)
    end,
  })
else
  vim.notify("nvim-treesitter not installed. Run :Lazy sync to install plugins.", vim.log.levels.WARN)
end

-- Textobjects on `main` drops the `select.keymaps` table -- map manually via select_textobject().
local ok_to, textobjects = pcall(require, "nvim-treesitter-textobjects")
if ok_to then
  textobjects.setup {
    select = {
      lookahead = true,
    },
  }

  local select_to = function(capture)
    return function()
      require("nvim-treesitter-textobjects.select").select_textobject(capture, "textobjects")
    end
  end
  vim.keymap.set({ "x", "o" }, "af", select_to("@function.outer"))
  vim.keymap.set({ "x", "o" }, "if", select_to("@function.inner"))
  vim.keymap.set({ "x", "o" }, "ac", select_to("@class.outer"))
  vim.keymap.set({ "x", "o" }, "ic", select_to("@class.inner"))
end
