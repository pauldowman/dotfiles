local group = vim.api.nvim_create_augroup("user_config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "go" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

-- Auto-reload files when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = group,
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Notification when file is changed externally
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = group,
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

