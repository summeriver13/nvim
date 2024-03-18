-- # kits/lsp.lua

-- ## mason.nvim

-- [Configuration](https://github.com/williamboman/mason.nvim?tab=readme-ov-file#configuration)

require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

-- ## mason-lspconfig.nvim

-- [Configuration](https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#configuration)

require("mason-lspconfig").setup {
  ensure_installed = {
    "lua_ls", 
  },
}

-- ## lspconfig.nvim

require("lspconfig").lua_ls.setup {
  capabilities = capabilities,
}
