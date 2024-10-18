-- inspiration: https://github.com/ibhagwan/nvim-lua/blob/main/lua/keymaps.lua
local map = vim.keymap.set

-- Fix common typos
vim.cmd([[
    cnoreabbrev W! w!
    cnoreabbrev W1 w!
    cnoreabbrev w1 w!
    cnoreabbrev Q! q!
    cnoreabbrev Q1 q!
    cnoreabbrev q1 q!
    cnoreabbrev Qa! qa!
    cnoreabbrev Qall! qall!
    cnoreabbrev Wa wa
    cnoreabbrev Wq wq
    cnoreabbrev wQ wq
    cnoreabbrev WQ wq
    cnoreabbrev wq1 wq!
    cnoreabbrev Wq1 wq!
    cnoreabbrev wQ1 wq!
    cnoreabbrev WQ1 wq!
    cnoreabbrev W w
    cnoreabbrev Q q
    cnoreabbrev Qa qa
    cnoreabbrev Qall qall
]])

-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':tabprev<CR>')
vim.keymap.set('n', '<c-j>', ':tabnext<CR>')

-- Clear search
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

-- Navigate tabs
map("n", "[t", ":tabprevious<CR>", { desc = "Previous tab" })
map("n", "]t", ":tabnext<CR>", { desc = "Next tab" })
map("n", "[T", ":tabfirst<CR>", { desc = "First tab" })
map("n", "]T", ":tablast<CR>", { desc = "Last tab" })

-- Navigate buffers
map("n", "[b", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", ":bnext<CR>", { desc = "Next buffer" })
map("n", "[B", ":bfirst<CR>", { desc = "First buffer" })
map("n", "]B", ":blast<CR>", { desc = "Last buffer" })

-- Remap Ag to Gg
vim.api.nvim_create_user_command('Gg', function(opts)
  vim.cmd('Ag ' .. opts.args)
end, { nargs = '*', desc = 'Search using Ag (Silver Searcher)' })

vim.keymap.set('n', '<leader>g', ':Ag ', { noremap = true, desc = 'Search using Ag' })
