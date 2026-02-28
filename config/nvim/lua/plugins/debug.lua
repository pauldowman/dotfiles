return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "DAP UI" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("nvim-dap-virtual-text").setup({})
      dapui.setup({
        icons = { expanded = "-", collapsed = "+" },
        controls = { icons = { pause = "||", play = ">", step_into = "v", step_over = ">", step_out = "^", step_back = "<", run_last = ">>", terminate = "x", disconnect = "D" } },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim" },
    config = function()
      local mason_registry = require("mason-registry")
      local path
      if mason_registry.is_installed("debugpy") then
        path = mason_registry.get_package("debugpy"):get_install_path() .. "/venv/bin/python"
      else
        path = vim.fn.exepath("python3")
      end
      require("dap-python").setup(path)
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    enabled = vim.fn.executable("go") == 1,
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
    end,
  },
}

