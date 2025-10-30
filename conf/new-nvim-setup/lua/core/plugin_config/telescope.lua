local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

require('telescope').setup({
  defaults = {
    vimgrep_arguments = {
      "rg", "--color=never", "--no-heading", "--with-filename",
      "--line-number", "--column", "--smart-case"
    },
    file_ignore_patterns = {
      ".*node_modules/.*",
      ".*migrations/.*",
      ".*generated/.*",
      ".*infra/.*"
    },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      }
    }
  },
  pickers = {
    find_files = {
      find_command = {
        "fd", "--type", "f", "--hidden", "--strip-cwd-prefix",
        "--exclude", ".git", "--exclude", "node_modules"
      },
      previewer = false, -- Speed boost
    }
  }
})

-- Load native fzf extension if installed
pcall(function()
  require('telescope').load_extension('fzf')
end)
