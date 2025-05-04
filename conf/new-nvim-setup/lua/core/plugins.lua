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

vim.filetype.add({
  extension = {
    codecompanion = "codecompanion"
  }
})

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

  { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim"
    },
  },
  { 'ellisonleao/gruvbox.nvim',                 priority = 1000 }, --colorscheme
  'nvim-tree/nvim-tree.lua',                                       -- file explorer
  'nvim-tree/nvim-web-devicons',                                   -- file explorer icons
  'nvim-lualine/lualine.nvim',                                     -- statusline
  'vim-test/vim-test',                                             --run tests from file
  'lewis6991/gitsigns.nvim',                                       -- git signs gutter and commands
  'preservim/vimux',                                               --link to tmux
  'tpope/vim-fugitive',                                            --git commands
  "EdenEast/nightfox.nvim",                                        -- lazy,<
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
  { "stevearc/conform.nvim", opts = {} },
  {
    'olimorris/persisted.nvim',
    config = true
  },
  {
    "MeanderingProgrammer/render-markdown.nvim", -- Make Markdown buffers look beautiful
    ft = { "markdown", "codecompanion", "Avante" },
    opts = {
      render_modes = true, -- Render in ALL modes
      sign = {
        enabled = false,   -- Turn off in the status column
      },
    },
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = "openai",
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o",             -- your desired model (or use gpt-4o, etc.)
        timeout = 30000,              -- Timeout in milliseconds, increase this for reasoning models
        temperature = 0,
        max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
        --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick",         -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua",              -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua",        -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
    },
  }
}

local opts = {}

require('lazy').setup(plugins, opts)
