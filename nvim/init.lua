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

require("config.options")
require("config.keymaps")
require("config.plugins")

-- Set colorscheme after plugins are loaded (protected call)
pcall(vim.cmd, "colorscheme kanagawa-wave")

require("config.lsp")
require("config.treesitter")
require("config.telescope")

-- Auto-open DiffviewOpen -u when opening file named 'd' that doesn't exist
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local args = vim.fn.argv()
    if #args == 1 and args[1] == "d" and vim.fn.filereadable("d") == 0 then
      vim.cmd("DiffviewOpen -u")
    end
  end,
})
