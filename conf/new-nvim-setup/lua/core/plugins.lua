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

local plugins = {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
  {
    'nvim-telescope/telescope.nvim', -- fuzzy finder
    tag = '0.1.4',
    dependencies = { { 'nvim-lua/plenary.nvim' } }
  },
  { 'ellisonleao/gruvbox.nvim', priority = 1000 }, --colorscheme
  'nvim-tree/nvim-tree.lua',                       -- file explorer
  'nvim-tree/nvim-web-devicons',                   -- file explorer icons
  'nvim-lualine/lualine.nvim',                     -- statusline
  'vim-test/vim-test',                             --run tests from file
  'lewis6991/gitsigns.nvim',                       -- git signs gutter and commands
  'preservim/vimux',                               --link to tmux
  'tpope/vim-fugitive',                            --git commands
  -- completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
  },
  'hrsh7th/cmp-nvim-lsp',
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp"
  },
  'rafamadriz/friendly-snippets',
  'williamboman/mason.nvim',           -- manage lsps etc.
  'neovim/nvim-lspconfig',             --list of lsp server configs
  'williamboman/mason-lspconfig.nvim', --link the two above
  'glepnir/lspsaga.nvim',              -- lsp ui
  'rking/ag.vim',                      -- ag search
  'Chun-Yang/vim-action-ag',           -- ag search word you are on
  'pappasam/papercolor-theme-slim',    -- colorscheme
  'norcalli/nvim-colorizer.lua',       -- see colors in nvim
  {
    'nvimtools/none-ls.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
  },
  'folke/neodev.nvim',
  'folke/which-key.nvim',
  'pwntester/octo.nvim',
  'numToStr/Comment.nvim',
  'ellisonleao/glow.nvim',
  'supermaven-inc/supermaven-nvim',
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  { "stevearc/conform.nvim",    opts = {} }
}

local opts = {}

require('lazy').setup(plugins, opts)
