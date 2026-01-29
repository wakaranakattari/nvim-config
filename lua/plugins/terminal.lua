return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 15,
        open_mapping = false,
        direction = "horizontal",
        close_on_exit = true,
        auto_scroll = true,
      })

      local opts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap("n", "<leader>z", "<Cmd>ToggleTerm<CR>", opts)
      vim.api.nvim_set_keymap("t", "<leader>z", "<Cmd>ToggleTerm<CR>", opts)
      vim.api.nvim_set_keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", opts)
      vim.api.nvim_set_keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", opts)
      vim.api.nvim_set_keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", opts)
      vim.api.nvim_set_keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", opts)
    end,
  },
}
