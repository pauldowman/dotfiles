local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all!" })

map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

map("n", "<leader>Tn", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>Tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>To", "<cmd>tabonly<CR>", { desc = "Tab only" })
