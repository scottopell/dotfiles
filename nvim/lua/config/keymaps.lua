-- Set leader key to comma
vim.g.mapleader = ','

-- Easier mappings for switching panes
vim.keymap.set('n', '<C-J>', '<C-W><C-J>', { noremap = true })
vim.keymap.set('n', '<C-K>', '<C-W><C-K>', { noremap = true })
vim.keymap.set('n', '<C-L>', '<C-W><C-L>', { noremap = true })
vim.keymap.set('n', '<C-H>', '<C-W><C-H>', { noremap = true })

-- Correct :W to :w and :Q to :q (typo corrections)
vim.cmd("cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))")
vim.cmd("cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))")

-- File finder mappings (telescope vs fzf based on luajit availability)
if vim.fn.luaeval('jit and string.find(jit.version, "LuaJIT")') then
  -- Telescope
  vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
  -- Override dirvish's built-in ctrl-p mapping
  vim.cmd("autocmd FileType dirvish nnoremap <buffer><silent> <C-p> <cmd>Telescope find_files<cr>")
else
  -- FZF fallback for non-luajit systems
  vim.keymap.set('n', '<C-p>', '<cmd>FZF<cr>', { noremap = true, silent = true })
  -- Override dirvish's built-in ctrl-p mapping
  vim.cmd("autocmd FileType dirvish nnoremap <buffer><silent> <C-p> <cmd>FZF<cr>")
end

-- Search for word under cursor (WIP - currently searches for 'word' instead of word)
vim.keymap.set('n', '<leader>g', ':Rg <C-r>=expand("<cword>") <cr> <cr>', { noremap = true, silent = true })

-- Clear last highlight pattern on Enter
vim.keymap.set('n', '<CR>', ':let @/ = "" <CR> <CR>', { noremap = true, silent = true })

-- In terminal-mode, map ESC to exit terminal-mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true })