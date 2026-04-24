-- Reads theme state written by the shell `theme` command and applies
-- gruvbox light/dark live. Re-checks on FocusGained (terminal switch) and
-- ShellCmdPost (`:!theme toggle` from inside nvim). `:Theme` forces re-apply.

local M = {}

local state_file = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state"))
  .. "/theme/current"

local function read_state()
  local f = io.open(state_file, "r")
  if not f then return "dark" end
  local val = f:read("*l")
  f:close()
  return (val == "light") and "light" or "dark"
end

local current = nil

function M.apply(force)
  local mode = read_state()
  if not force and mode == current then return end
  current = mode
  vim.opt.background = mode
  pcall(vim.cmd, "colorscheme gruvbox")
end

function M.setup()
  M.apply(true)
  local group = vim.api.nvim_create_augroup("theme-auto", { clear = true })
  vim.api.nvim_create_autocmd({ "FocusGained", "ShellCmdPost" }, {
    group = group,
    callback = function() M.apply(false) end,
  })
  vim.api.nvim_create_user_command("Theme", function() M.apply(true) end, {
    desc = "Re-read theme state file and apply",
  })
end

return M
