return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    keys = {
      { "<leader>um", "<cmd>RenderMarkdown buf_toggle<CR>", desc = "Toggle markdown rendering", ft = "markdown" },
    },
    opts = {
      completions = { lsp = { enabled = true } },
      latex = { enabled = false },
    },
  },
}
