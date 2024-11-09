local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

local rubocop_cmd = vim.fn.expand('~/.rbenv/shims/rubocop')

null_ls.setup {
  debug = true,
  sources = {
    null_ls.builtins.formatting.prettierd.with({
      env = {
        PRETTIERD_LOCAL_PRETTIER_ONLY = 1,
      },
    }),
    null_ls.builtins.formatting.rubocop.with({
      command = rubocop_cmd,
      args = { "--auto-correct", "-f", "quiet", "--stderr", "--stdin", "$FILENAME" },
      stdin = true,
    }),
  },
  on_attach = function(client, bufnr)
    if client.supports_method 'textDocument/formatting' then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,
            filter = function(client)
              return client.name == "null-ls"
            end,
          })
        end,
      })
    end
  end,
}
