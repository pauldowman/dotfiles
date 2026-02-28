return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
      "fredrikaverpil/neotest-golang",
      "rouge8/neotest-rust",
      "marilari88/neotest-vitest",
    },
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Test nearest" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test file" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug test" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Test output" },
    },
    config = function()
      local function python_path()
        local cwd = vim.uv.cwd()
        local candidates = {
          cwd .. "/.venv/bin/python",
          cwd .. "/venv/bin/python",
        }
        for _, path in ipairs(candidates) do
          if vim.uv.fs_stat(path) then
            return path
          end
        end
        return vim.fn.exepath("python3")
      end

      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            python = python_path,
            dap = { justMyCode = false },
          }),
          require("neotest-golang")({
            dap_go_enabled = true,
          }),
          require("neotest-rust")({}),
          require("neotest-vitest")({
            is_test_file = function(file_path)
              return file_path:match("%.test%.[jt]sx?$") ~= nil or file_path:match("%.spec%.[jt]sx?$") ~= nil
            end,
          }),
        },
        discovery = { enabled = true },
        output = { open_on_run = false },
        summary = { animated = false },
      })
    end,
  },
}

