return {
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {
      view_options = { show_hidden = true },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<Esc>"] = { callback = function() require("oil.actions").close.callback() end, desc = "Close" },
      },
    },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
      { "<leader>e", "<cmd>Oil<CR>", desc = "Explorer (Oil)" },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", desc = "Terminal (float)" },
      { "<leader>th", "<cmd>ToggleTerm size=12 direction=horizontal<CR>", desc = "Terminal (horizontal)" },
      { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<CR>", desc = "Terminal (vertical)" },
    },
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
      shade_terminals = true,
      float_opts = { border = "rounded" },
    },
  },
}

