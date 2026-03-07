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

-- Auto-reload files when changed externally (fallback for when file watcher isn't active)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = group,
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Filesystem-based auto-reload using libuv
local watchers = {}

local function watch_file(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)

  -- Only watch regular files that exist
  if file == "" or vim.fn.filereadable(file) ~= 1 then
    return
  end

  -- Don't watch if already watching
  if watchers[bufnr] then
    return
  end

  local fs_event = vim.loop.new_fs_event()
  if not fs_event then
    return
  end

  fs_event:start(file, {}, vim.schedule_wrap(function(err, fname, status)
    if err then
      return
    end

    -- Check if buffer still exists and file still matches
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) == file then
      vim.cmd("checktime " .. bufnr)
    end
  end))

  watchers[bufnr] = fs_event
end

local function unwatch_file(bufnr)
  local watcher = watchers[bufnr]
  if watcher then
    watcher:stop()
    watchers[bufnr] = nil
  end
end

-- Start watching when buffer is loaded
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = group,
  callback = function(args)
    watch_file(args.buf)
  end,
})

-- Stop watching when buffer is unloaded
vim.api.nvim_create_autocmd("BufUnload", {
  group = group,
  callback = function(args)
    unwatch_file(args.buf)
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

