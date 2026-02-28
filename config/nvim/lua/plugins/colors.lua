return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("config.theme").pick_default()
    end,
  },
  { "ellisonleao/gruvbox.nvim", priority = 1000 },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        icons_enabled = false,
        globalstatus = true,
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      icons = { mappings = false },
      spec = {
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Hunks" },
        { "<leader>l", group = "LSP" },
        { "<leader>t", group = "Test/Terminal" },
        { "<leader>T", group = "Tabs" },
        { "<leader>u", group = "UI" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      vim.keymap.set("n", "<leader>ut", function()
        require("config.theme").cycle()
      end, { desc = "Cycle theme" })

      vim.keymap.set("n", "<leader>uT", "<cmd>Telescope colorscheme enable_preview=true<CR>", { desc = "Pick theme" })
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      icons = false,
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP refs" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix" },
    },
  },
  {
    "rcarriga/nvim-notify",
    enabled = vim.fn.has("nvim-0.10") == 1,
    lazy = true,
    opts = {
      render = "compact",
      stages = "fade",
    },
  },
  {
    "nvim-tree/nvim-web-devicons",
    enabled = false,
  },
}
