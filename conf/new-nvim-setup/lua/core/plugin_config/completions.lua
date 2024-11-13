local cmp = require("cmp")
require("luasnip.loaders.from_vscode").lazy_load()

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
    { name = 'supermaven', priority = 1000 }, -- AI completions
    { name = 'nvim_lsp',   priority = 900 },  -- LSP
    { name = 'luasnip',    priority = 800 },  -- Snippets
    { name = 'buffer',     priority = 500 },  -- Buffer words
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
