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

local function find_alternate_file()
  local current_file = vim.fn.expand('%:t') -- :t gets just the tail (filename)
  local target_file

  if string.match(current_file, '_spec.rb$') then
    -- In spec file, look for implementation
    target_file = string.gsub(current_file, '_spec.rb', '.rb')
  else
    -- In implementation, look for spec
    target_file = string.gsub(current_file, '%.rb$', '_spec.rb')
  end

  -- Add the spec/ prefix if searching for a spec file
  if string.match(target_file, '_spec.rb$') then
    target_file = 'spec/' .. target_file
  end

  builtin.find_files({
    default_text = target_file,
    hidden = false,
    no_ignore = false,
  })
end

local wk = require("which-key")
wk.add({
  { "<leader>f",       group = "file" },
  { "<leader>ff",      builtin.find_files,      desc = "Find File",      mode = "n" },
  { "<leader>fg",      builtin.live_grep,       desc = "Live Grep",      mode = "n" },
  { "<leader>fb",      builtin.buffers,         desc = "Buffers",        mode = "n" },
  { "<leader>fh",      builtin.help_tags,       desc = "Help Tags",      mode = "n" },
  { "<leader>fr",      builtin.oldfiles,        desc = "Recent Files",   mode = "n" },
  { "<leader>fc",      "<cmd> :let @+=@% <cr>", desc = 'Copy file name', mode = "n" },
  { "<leader>A",       find_alternate_file,     desc = "Find Test File", mode = "n" },
  { "<C-p>",           builtin.find_files,      desc = "Find File",      mode = "n" },
  { "<leader><space>", builtin.oldfiles,        desc = "Recent Files",   mode = "n" },
})
