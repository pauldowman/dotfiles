local opt = vim.opt

-- Disable unused providers to suppress checkhealth noise
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.inccommand = "split"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.confirm = true
opt.termguicolors = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.completeopt = { "menu", "menuone", "noselect" }
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

