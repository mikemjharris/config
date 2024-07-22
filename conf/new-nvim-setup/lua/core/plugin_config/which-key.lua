vim.o.timeout = true
vim.o.timeoutlen = 300


local builtin = require('telescope.builtin')
local wk = require("which-key")

wk.add({
  { "<leader>f",       group = "file" },
  { "<leader>ff",      builtin.find_files,      desc = "Find File",      mode = "n" },
  { "<leader>fg",      builtin.live_grep,       desc = "Live Grep",      mode = "n" },
  { "<leader>fb",      builtin.buffers,         desc = "Buffers",        mode = "n" },
  { "<leader>fh",      builtin.help_tags,       desc = "Help Tags",      mode = "n" },
  { "<leader>fr",      builtin.oldfiles,        desc = "Recent Files",   mode = "n" },
  { "<leader>fc",      "<cmd> :let @+=@% <cr>", desc = 'Copy file name', mode = "n" },
  { "<C-p>",           builtin.find_files,      desc = "Find File",      mode = "n" },
  { "<leader><space>", builtin.oldfiles,        desc = "Recent Files",   mode = "n" },
})

wk.add({
  { "<C-s>", "<Esc><cmd>w<CR>", desc = "Save File", mode = "i" },
}, { prefix = "<C-", mode = "i" })
