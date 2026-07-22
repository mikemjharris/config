-- nvim-treesitter `main` branch: the plugin only installs parsers + ships queries.
-- Highlighting/folding/injection are provided by Neovim core (0.12+).

local ts = require('nvim-treesitter')

ts.setup {
  install_dir = vim.fn.stdpath('data') .. '/site',
}

-- Parsers we always want available (replaces the old `ensure_installed`).
local parsers = {
  'c', 'lua', 'rust', 'ruby', 'vim', 'vimdoc',
  'javascript', 'typescript', 'tsx',
  'markdown', 'markdown_inline',
  'yaml',
}
ts.install(parsers)

-- Enable core treesitter highlighting for any buffer that has a parser.
-- Replaces `highlight = { enable = true }`; pcall no-ops filetypes without a parser.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter_highlight', { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- Text objects (nvim-treesitter-textobjects `main` branch).
require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true,
  },
}

local select = require('nvim-treesitter-textobjects.select').select_textobject
local textobjects = {
  af = '@function.outer',
  ['if'] = '@function.inner',
  ac = '@class.outer',
  ic = '@class.inner',
  ab = '@block.outer',
  ib = '@block.inner',
}
for lhs, query in pairs(textobjects) do
  vim.keymap.set({ 'x', 'o' }, lhs, function()
    select(query, 'textobjects')
  end, { desc = 'Select ' .. query })
end
