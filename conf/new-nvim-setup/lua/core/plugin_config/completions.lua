local cmp = require("cmp")
require("luasnip.loaders.from_vscode").lazy_load()

-- Add these variables at the top to track completion state
vim.g.cmp_global_enabled = true

local function toggle_completion_buffer()
  local current_buffer = vim.api.nvim_get_current_buf()
  local is_enabled = vim.b[current_buffer].cmp_enabled

  if is_enabled == nil then
    is_enabled = true -- Default to true if not set
  end

  vim.b[current_buffer].cmp_enabled = not is_enabled
  cmp.setup.buffer({ enabled = not is_enabled })

  -- Show notification of current state
  local state = not is_enabled and "enabled" or "disabled"
  vim.notify("Completion " .. state .. " for current buffer", vim.log.levels.INFO)
end

local function toggle_completion_global()
  vim.g.cmp_global_enabled = not vim.g.cmp_global_enabled
  cmp.setup({ enabled = vim.g.cmp_global_enabled })

  -- Show notification of current state
  local state = vim.g.cmp_global_enabled and "enabled" or "disabled"
  vim.notify("Completion " .. state .. " globally", vim.log.levels.INFO)
end



cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- Documentation scrolling
    ['<C-r>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),

    -- Cancel completion
    ['<C-e>'] = cmp.mapping.abort(),

    -- Manual trigger completion
    -- ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate completion menu
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),

    -- -- Tab completion as an alternative to Ctrl-j/k
    -- ['<Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    --
    -- ['<S-Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

  }),

  -- Completion menu appearance
  window = {
    documentation = {
      max_height = 15,
      max_width = 60,
      border = 'rounded',
      winhighlight = 'NormalFloat:Normal,FloatBorder:Normal',
    },
    completion = {
      border = 'rounded',
      winhighlight = 'NormalFloat:Normal,FloatBorder:Normal',
    },
  },

  -- Snippet support
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },

  -- Completion sources in priority order
  sources = {
    { name = 'copilot',  priority = 1000 },  -- AI completions
    { name = 'nvim_lsp', priority = 900 },   -- LSP
    { name = 'luasnip',  priority = 800 },   -- Snippets
    { name = 'buffer',   priority = 500 },   -- Buffer words
  },

  -- Completion behavior
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline({
    -- Navigate the completion menu
    ['<C-j>'] = cmp.mapping.select_prev_item(),
    ['<C-k>'] = cmp.mapping.select_next_item(),
    -- Scroll the documentation window
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    -- Cancel completion
    ['<C-e>'] = cmp.mapping.abort(),
    -- Confirm completion
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    -- Complete with the first item
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' with custom keybindings
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline({
    -- Navigate the completion menu
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Scroll the documentation window
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    -- Cancel completion
    ['<C-e>'] = cmp.mapping.abort(),
    -- Confirm completion
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    -- Complete with the first item
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})


-- -- Add these to your which-key config
-- local wk = require("which-key")
-- wk.add({
--   { "<leader>cb", toggle_completion_buffer, desc = "Toggle buffer completion", mode = "n" },
--   { "<leader>cg", toggle_completion_global, desc = "Toggle buffer completion", mode = "n" },
-- })
