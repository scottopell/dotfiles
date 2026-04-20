-- Neovide-specific overrides.
--
-- Problem: on macOS, double-clicking a file in Finder (with Neovide already
-- running) forwards the open through `_G.neovide.private.dropfile`, which runs
-- `:tab drop <file>`. When the rightmost window is `buftype=nofile` -- as it
-- is when `no-neck-pain.nvim` is active -- `:help :drop` specifies that "the
-- last window is used if it's empty", so the file replaces the NNP scratch
-- buffer in place instead of opening a new tab.
--
-- Fix: override the dropfile hook to use `:tabedit`, which always creates a
-- new tab. Preserve the "jump to existing tab if the file is already open"
-- behavior that `:tab drop` gives us for free.
--
-- `_G.neovide.private` is not a stability contract; guard with an existence
-- check and notify loudly if Neovide ever renames/removes it.

if not vim.g.neovide then
  return
end

local function override_dropfile()
  if not (_G.neovide and _G.neovide.private and _G.neovide.private.dropfile) then
    vim.notify(
      "neovide.lua: _G.neovide.private.dropfile missing -- Neovide API changed? Finder opens will use upstream behavior.",
      vim.log.levels.WARN
    )
    return
  end

  _G.neovide.private.dropfile = function(filename, _)
    local abs = vim.fn.fnamemodify(filename, ":p")
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) == abs then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
    vim.cmd("tabedit " .. vim.fn.fnameescape(filename))
  end
end

-- Neovide sends its Lua init during UI attach. UIEnter runs once the UI is
-- attached, which is the earliest safe point. Also run immediately in case
-- this module is re-sourced manually after startup.
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = vim.schedule_wrap(override_dropfile),
})
override_dropfile()
