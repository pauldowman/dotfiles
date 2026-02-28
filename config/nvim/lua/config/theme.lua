local M = {}

M.themes = { "tokyonight", "gruvbox", "catppuccin" }
M.index = 1

function M.apply(name)
  local ok, err = pcall(vim.cmd.colorscheme, name)
  if ok then
    return true
  end

  vim.notify(("Failed to load colorscheme %s: %s"):format(name, err), vim.log.levels.WARN)
  return false
end

function M.cycle()
  M.index = (M.index % #M.themes) + 1
  M.apply(M.themes[M.index])
  vim.notify(("Theme: %s"):format(M.themes[M.index]), vim.log.levels.INFO)
end

function M.pick_default()
  for i, theme in ipairs(M.themes) do
    if M.apply(theme) then
      M.index = i
      return
    end
  end
end

return M

