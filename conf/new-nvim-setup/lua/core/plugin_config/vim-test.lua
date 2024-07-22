vim.cmd [[
  let test#strategy = "vimux"
]]

vim.keymap.set('n', '<leader>t', ':TestNearest<CR>')
vim.keymap.set('n', '<leader>T', ':TestFile<CR>')

local wk = require("which-key")

wk.add({
  { "<leader>t", "<cmd>TestNearest<CR>", desc = "Test Nearest", mode = "n" },
  { "<leader>T", "<cmd>TestFile<CR>",    desc = "Test File",    mode = "n" },
})
