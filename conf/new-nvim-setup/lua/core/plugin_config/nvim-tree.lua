vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  view = {
    adaptive_size = true
  },
  actions = {
    open_file = {
      resize_window = true
    }
  }
})

local wk = require("which-key")

wk.add({
  { "<C-n>", "<cmd>NvimTreeToggle<CR>",   desc = "Toggle NvimTree",       mode = "n" },
  { "<C-f>", "<cmd>NvimTreeFindFile<CR>", desc = "Find File in NvimTree", mode = "n" },
  { "<C-s>", "<cmd>w<CR>",                desc = "Save File",             mode = "n" },
}, { prefix = "<C-" })
