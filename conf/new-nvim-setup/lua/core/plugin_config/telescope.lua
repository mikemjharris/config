local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      }
    }

  }
})

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
