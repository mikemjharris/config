local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

local rubocop_cmd = vim.fn.expand('~/.rbenv/shims/rubocop')

null_ls.setup {
  debug = true,
  -- Show diagnostics as you type
  update_in_insert = true,
  -- Customize diagnostic signs in the gutter
  diagnostics_format = "[#{c}] #{m} (#{s})",
  sources = {
    null_ls.builtins.formatting.prettierd.with({
      env = {
        PRETTIERD_LOCAL_PRETTIER_ONLY = 1,
      },
    }),
    null_ls.builtins.formatting.rubocop.with({
      command = rubocop_cmd,
      args = { "--autocorrect", "-f", "quiet", "--stderr", "--stdin", "$FILENAME" },
      stdin = true,
    }),

    -- Add diagnostics
    null_ls.builtins.diagnostics.rubocop.with({
      command = rubocop_cmd,
      condition = function(utils)
        return utils.root_has_file({ ".rubocop.yml", "~/.rubocop.yml" })
      end,
    }),
  },
  -- Add this to your setup
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          local success, result = pcall(function()
            vim.lsp.buf.format({
              bufnr = bufnr,
              filter = function(client)
                return client.name == "null-ls"
              end,
              timeout_ms = 5000,
            })
          end)
          if not success then
            print("Format error: " .. tostring(result)) -- Debug print
          end
        end,
      })
    end
  end
}
