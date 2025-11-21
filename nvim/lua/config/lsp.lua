-- Set up LSP keybindings when a language server attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local opts = { noremap=true, silent=true, buffer=bufnr }

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,      opts)
    vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,       opts)
    vim.keymap.set('n', 'gr',         vim.lsp.buf.references,       opts)
    vim.keymap.set('n', 'K',          vim.lsp.buf.hover,            opts)
    vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation,   opts)
    vim.keymap.set('n', '<leader>D',  vim.lsp.buf.type_definition,  opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,           opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action,      opts)
    vim.keymap.set('n', '<leader>e',  vim.diagnostic.open_float,    opts)
    vim.keymap.set('n', '[d',         vim.diagnostic.goto_prev,     opts)
    vim.keymap.set('n', ']d',         vim.diagnostic.goto_next,     opts)
    vim.keymap.set('n', '<leader>q',  vim.diagnostic.setloclist,    opts)
    vim.keymap.set('n', '<leader>f',  vim.lsp.buf.format,           opts)
  end,
})

-- Configure common settings for language servers
local common_config = {
  flags = {
    debounce_text_changes = 150,
  }
}

-- Configure and enable language servers
local servers = { 'ts_ls', 'gopls' }
for _, lsp in ipairs(servers) do
  vim.lsp.config(lsp, common_config)
  vim.lsp.enable(lsp)
end

-- Configure rust-analyzer separately with custom settings
vim.lsp.config('rust_analyzer', {
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    ['rust-analyzer'] = {
      -- Load all cargo features for better symbol coverage
      cargo = {
        allFeatures = true,
      },
    }
  }
})
vim.lsp.enable('rust_analyzer')