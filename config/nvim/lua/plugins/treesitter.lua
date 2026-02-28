return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").install({
        "bash",
        "comment",
        "diff",
        "dockerfile",
        "git_config",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })

      local group = vim.api.nvim_create_augroup("nvim_treesitter", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
