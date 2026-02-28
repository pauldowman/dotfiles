return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signcolumn = true,
      current_line_blame = true,
      current_line_blame_opts = { delay = 300 },
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Prev hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk")
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>hd", gs.diffthis, "Diff this")
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Ggrep", "GBrowse" },
    keys = {
      { "<leader>gg", "<cmd>Git<CR>", desc = "Git (Fugitive)" },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
    },
    opts = {
      enhanced_diff_hl = true,
      use_icons = false,
    },
  },
}
