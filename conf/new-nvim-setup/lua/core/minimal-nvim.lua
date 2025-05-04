local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Enable filetype detection and syntax highlighting
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

-- Set basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc"

vim.filetype.add({
  extension = {
    codecompanion = "codecompanion"
  }
})

require("lazy").setup({
  -- Treesitter for syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "MeanderingProgrammer/render-markdown.nvim", -- Make Markdown buffers look beautiful
    ft = { "markdown", "codecompanion" },
    opts = {
      render_modes = true, -- Render in ALL modes
      sign = {
        enabled = false,   -- Turn off in the status column
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim"
    },
  }
  -- Markdown preview (optional)
})

require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "markdown", "markdown_inline", "tsx", "typescript", "lua", "json" },
  highlight = {
    enable = true,
  },
}

require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "openai",
    },
    inline = {
      adapter = "openai",
    },
  },
})
