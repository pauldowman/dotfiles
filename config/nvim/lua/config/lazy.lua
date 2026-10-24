local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
  local lock = vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n"))
  local commit = lock["lazy.nvim"] and lock["lazy.nvim"].commit
  assert(
    type(commit) == "string" and #commit == 40 and commit:match("^%x+$"),
    "Missing or invalid lazy.nvim commit in " .. lockfile
  )

  local function git(args)
    local output = vim.fn.system(args)
    if vim.v.shell_error ~= 0 then
      vim.fn.delete(lazypath, "rf")
      error("Failed to bootstrap lazy.nvim: " .. output)
    end
  end

  git({
    "git",
    "clone",
    "--filter=blob:none",
    "--no-checkout",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  git({ "git", "-C", lazypath, "checkout", "--detach", commit })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  checker = { enabled = true, notify = false },
  rocks = { enabled = false },
  change_detection = { notify = false },
  install = { colorscheme = { "tokyonight", "gruvbox", "catppuccin" } },
  ui = {
    border = "rounded",
  },
})

