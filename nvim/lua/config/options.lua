-- Mouse mode (scroll, visual select, etc)
vim.opt.mouse = "a"

-- Display line numbers
vim.opt.number = true

-- Better default behavior for where new splits go
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Always show statusline
vim.opt.laststatus = 2

-- Custom statusline
vim.opt.statusline = "[%n] %f%m %= col %c | %b 0x%B | %2p%%"

-- Colors
vim.opt.background = "light"

-- Markdown settings
vim.cmd("autocmd BufRead,BufNewFile *.md,*.markdown setlocal textwidth=80")
vim.cmd("au BufNewFile,BufRead *.markdown,*.mdown,*.mkd,*.mkdn,*.mdwn,*.md set ft=markdown")

-- Tab settings function
function SetTabWidth(width)
  vim.opt.tabstop = width
  vim.opt.softtabstop = width
  vim.opt.shiftwidth = width
  vim.opt.expandtab = true
end

-- Default tabs are 4 spaces
SetTabWidth(4)

-- Except for yaml
vim.cmd("autocmd FileType yaml lua SetTabWidth(2)")

-- Git config files should use tabs
vim.cmd("autocmd BufRead,BufNewFile gitconfig set filetype=gitconfig")
vim.cmd("autocmd FileType gitconfig setlocal noexpandtab tabstop=8 softtabstop=8 shiftwidth=8")

-- Make normally invisible whitespace visible
vim.opt.list = true
vim.opt.listchars = { trail = '·', tab = '»·' }

-- Don't highlight all instances when searching
vim.opt.hlsearch = false

-- Enable async paren matching
vim.g.matchup_matchparen_deferred = 1

-- Enable rust autofmt
vim.g.rustfmt_autosave = 1

-- Use goimports for go formatting
vim.g.go_fmt_command = "goimports"

-- Log file settings
vim.cmd("autocmd BufRead,BufNewFile *.log set nowrap")
vim.cmd("autocmd BufRead,BufNewFile *.log set hls")

-- Highlight current row in active pane
vim.cmd([[
augroup BgHighlight
    autocmd!
    autocmd WinEnter * set cul
    autocmd WinLeave * set nocul
augroup END
]])

-- Trim whitespace on save
local function trim_whitespace()
  local save = vim.fn.winsaveview()
  vim.cmd("keeppatterns %s/\\s\\+$//e")
  vim.fn.winrestview(save)
end

vim.cmd("autocmd BufWritePre * lua trim_whitespace()")