return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "rust_analyzer", "clangd", "lua_ls" },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
      end

      lspconfig.ts_ls.setup({ on_attach = on_attach })
      lspconfig.rust_analyzer.setup({ on_attach = on_attach })
      lspconfig.clangd.setup({ on_attach = on_attach })
      lspconfig.lua_ls.setup({ on_attach = on_attach })
    end,
  },
}
