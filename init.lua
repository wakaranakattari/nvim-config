vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.termguicolors = true

pcall(function()
  require("custom.live").setup()

  vim.keymap.set("n", "<leader>ls", "<cmd>LiveStart<cr>", { desc = "Start live server" })
  vim.keymap.set("n", "<leader>lx", "<cmd>LiveStop<cr>", { desc = "Stop live server" })
end)

vim.schedule(function()
  pcall(function()
    require("toggleterm").setup()
    vim.keymap.set("n", "<leader>z", "<Cmd>ToggleTerm<CR>", { noremap = true, silent = true })
    vim.keymap.set("t", "<leader>z", "<Cmd>ToggleTerm<CR>", { noremap = true, silent = true })
  end)
end)

require("config.lazy")
require("user.diagnostics")
require("user.suppress")
require("user.disable_lsp_notify")

local function load_commands()
  local ok, mod = pcall(require, "custom.command_palette")

  if ok and mod.setup then
    mod.setup()

    vim.api.nvim_create_user_command("Cmd", function()
      require("custom.command_palette").create_command_selector()
    end, {})

    vim.api.nvim_create_user_command("Project", function()
      require("custom.command_palette").create_project_selector()
    end, {})

    vim.keymap.set("n", "<leader>cp", "<cmd>Cmd<cr>", { desc = "Command palette" })
    vim.keymap.set("n", "<leader>np", "<cmd>Project<cr>", { desc = "New project" })
  end
end

vim.defer_fn(load_commands, 100)
