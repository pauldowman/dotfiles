return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      automatic_enable = false,
      automatic_installation = false,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = function()
      local tools = {
        "bash-language-server",
        "black",
        "codelldb",
        "debugpy",
        "eslint_d",
        "isort",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "prettier",
        "pyright",
        "ruff",
        "shellcheck",
        "shfmt",
        "stylua",
        "taplo",
        "typescript-language-server",
        "yaml-language-server",
      }
      if vim.fn.executable("go") == 1 then
        vim.list_extend(tools, { "delve", "goimports", "gofumpt", "golangci-lint", "gopls" })
      end
      if vim.fn.executable("rustc") == 1 then
        vim.list_extend(tools, { "rust-analyzer" })
      end
      return {
        ensure_installed = tools,
        auto_update = false,
        run_on_start = true,
        start_delay = 3000,
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = true,
        signs = true,
        virtual_text = { spacing = 2, source = "if_many" },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("n", "gd", vim.lsp.buf.definition, "LSP: definition")
          map("n", "gD", vim.lsp.buf.declaration, "LSP: declaration")
          map("n", "gr", vim.lsp.buf.references, "LSP: references")
          map("n", "gi", vim.lsp.buf.implementation, "LSP: implementation")
          map("n", "K", vim.lsp.buf.hover, "LSP: hover")
          map("n", "<leader>lk", vim.lsp.buf.signature_help, "LSP: signature")
          map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: rename")
          map("n", "<leader>la", vim.lsp.buf.code_action, "LSP: code action")
          map("n", "<leader>lf", function()
            require("conform").format({ async = true, lsp_format = "fallback" })
          end, "Format buffer")
          map("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
          map("n", "<leader>lD", vim.diagnostic.setloclist, "Diagnostics list")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
          map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        end,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            hint = { enable = true },
          },
        },
      })

      if vim.fn.executable("go") == 1 then
        vim.lsp.config("gopls", {
          settings = {
            gopls = {
              gofumpt = true,
              staticcheck = true,
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        })
      end

      if vim.fn.executable("rustc") == 1 then
        vim.lsp.config("rust_analyzer", {
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = { command = "clippy" },
            },
          },
        })
      end

      local servers = { "bashls", "jsonls", "lua_ls", "marksman", "pyright", "taplo", "ts_ls", "yamlls" }
      if vim.fn.executable("go") == 1 then
        vim.list_extend(servers, { "gopls" })
      end
      if vim.fn.executable("rustc") == 1 then
        vim.list_extend(servers, { "rust_analyzer" })
      end
      vim.lsp.enable(servers)
    end,
  },
}
