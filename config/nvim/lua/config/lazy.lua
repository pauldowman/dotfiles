local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  checker = { enabled = true, notify = false },
  rocks = { enabled = false },
  change_detection = { notify = false },
  install = { colorscheme = { "tokyonight", "gruvbox", "catppuccin" } },
  ui = {
    border = "rounded",
    icons = {
      cmd = ">",
      config = "*",
      event = "~",
      ft = "f",
      init = "i",
      import = "<",
      keys = "k",
      lazy = "L",
      loaded = "+",
      not_loaded = "-",
      plugin = "p",
      runtime = "r",
      require = "R",
      source = "s",
      start = "S",
      task = "T",
      list = { "-", "+", "*" },
    },
  },
})

