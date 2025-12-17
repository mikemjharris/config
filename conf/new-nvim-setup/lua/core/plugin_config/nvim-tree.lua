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

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.rb",
  callback = function(args)
    -- Check if the file is empty
    if vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
      -- Insert the frozen string literal comment
      vim.api.nvim_buf_set_lines(args.buf, 0, 0, false, {
        '# frozen_string_literal: true',
        '' -- Add an empty line after the comment
      })
    end
  end
})


local wk = require("which-key")

wk.add({
  { "<C-n>", "<cmd>NvimTreeToggle<CR>",   desc = "Toggle NvimTree",       mode = "n" },
  { "<C-f>", "<cmd>NvimTreeFindFile<CR>", desc = "Find File in NvimTree", mode = "n" },
  { "<C-s>", "<cmd>w<CR>",                desc = "Save File",             mode = "n" },
})
