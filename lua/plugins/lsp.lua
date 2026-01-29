return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPost",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")

      -- Настройка диагностики (общая для всех LSP)
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = true,
        underline = true,
        severity_sort = true,
      })

      -- Ключевые маппинги при подключении LSP
      local on_attach = function(client, bufnr)
        -- Включить completion при наборе
        client.server_capabilities.completionProvider = true

        -- Настройка keymaps
        local opts = { buffer = bufnr, remap = false }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
      end

      -- Настройки для конкретных языков
      local servers = {
        tsserver = {
          on_attach = on_attach,
        },
        rust_analyzer = {
          on_attach = on_attach,
        },
        clangd = {
          on_attach = on_attach,
        },
        lua_ls = {
          on_attach = on_attach,
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
            },
          },
        },
      }

      -- Настройка каждого сервера
      for server, config in pairs(servers) do
        lspconfig[server].setup(config)
      end
    end,
  },
}
