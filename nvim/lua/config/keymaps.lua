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

-- File finder mappings
vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
-- Override dirvish's built-in ctrl-p mapping
vim.cmd("autocmd FileType dirvish nnoremap <buffer><silent> <C-p> <cmd>Telescope find_files<cr>")

-- Search for word under cursor (WIP - currently searches for 'word' instead of word)
vim.keymap.set('n', '<leader>g', ':Rg <C-r>=expand("<cword>") <cr> <cr>', { noremap = true, silent = true })

-- Additional Telescope keybindings (conservative additions)
-- Search by grep (similar to your existing Rg workflow)
vim.keymap.set('n', '<leader>sg', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })
-- Search current word under cursor with telescope
vim.keymap.set('n', '<leader>sw', '<cmd>Telescope grep_string<cr>', { noremap = true, silent = true })
-- Recent files (complementing your existing <C-p> for all files)
vim.keymap.set('n', '<leader>.', '<cmd>Telescope oldfiles<cr>', { noremap = true, silent = true })
-- Search Help
vim.keymap.set('n', '<leader>sh', '<cmd>Telescope help_tags<cr>', { noremap = true, silent = true })
-- Search Diagnostics
vim.keymap.set('n', '<leader>sd', '<cmd>Telescope diagnostics<cr>', { noremap = true, silent = true })
-- Find existing buffers
vim.keymap.set('n', '<leader><leader>', '<cmd>Telescope buffers<cr>', { noremap = true, silent = true })
-- LSP Symbols
vim.keymap.set('n', '<leader>ss', '<cmd>Telescope lsp_document_symbols<cr>', { noremap = true, silent = true, desc = 'Search document symbols' })
vim.keymap.set('n', '<leader>sS', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', { noremap = true, silent = true, desc = 'Search workspace symbols' })

-- Clear last highlight pattern on Enter
vim.keymap.set('n', '<CR>', ':let @/ = "" <CR> <CR>', { noremap = true, silent = true })

-- In terminal-mode, map ESC to exit terminal-mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true })

-- Show all keymaps cheat sheet
vim.keymap.set('n', '<leader>?', '<cmd>Telescope keymaps<cr>', { noremap = true, silent = true, desc = 'Show all keymaps' })

-- Neo-tree file explorer toggle
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<cr>', { noremap = true, silent = true, desc = 'Toggle file explorer' })

-- Markdown checkbox toggle
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set('n', '<leader>c', function()
      local line = vim.api.nvim_get_current_line()
      local new_line
      if line:match('%[x%]') then
        new_line = line:gsub('%[x%]', '[ ]', 1)
      elseif line:match('%[ %]') then
        new_line = line:gsub('%[ %]', '[x]', 1)
      elseif line:match('%[%]') then
        new_line = line:gsub('%[%]', '[x]', 1)
      end
      if new_line then
        vim.api.nvim_set_current_line(new_line)
      end
    end, { buffer = true, desc = 'Toggle markdown checkbox' })
  end
})

-- Octo.nvim GitHub PR Review mappings
-- Workflow: <leader>gpl → select PR → <leader>grs → select lines → <leader>gca/gsa → <leader>grf
vim.keymap.set('n', '<leader>gpl', '<cmd>Octo pr list<cr>', { noremap = true, silent = true, desc = 'List GitHub PRs' })
vim.keymap.set('n', '<leader>grs', '<cmd>Octo review start<cr>', { noremap = true, silent = true, desc = 'Start PR review' })
vim.keymap.set('n', '<leader>grr', '<cmd>Octo review resume<cr>', { noremap = true, silent = true, desc = 'Resume PR review' })
vim.keymap.set('n', '<leader>grf', '<cmd>Octo review submit<cr>', { noremap = true, silent = true, desc = 'Submit PR review' })
vim.keymap.set({'n', 'v'}, '<leader>gca', '<cmd>Octo comment add<cr>', { noremap = true, silent = true, desc = 'Add comment on line/selection' })
vim.keymap.set({'n', 'v'}, '<leader>gsa', '<cmd>Octo suggestion add<cr>', { noremap = true, silent = true, desc = 'Add suggestion on line/selection' })
