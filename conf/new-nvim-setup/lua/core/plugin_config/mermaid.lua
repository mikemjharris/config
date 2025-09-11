-- Auto-detect mermaid files and set proper filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.mmd", "*.mermaid" },
  callback = function()
    vim.bo.filetype = "mermaid"
  end,
})

-- Set up auto-save and preview refresh for mermaid files
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.mermaid,*.mmd",
  callback = function()
    -- Auto-refresh browser preview on save if running
    if vim.g.mkdp_auto_refresh == 1 and vim.fn.exists(':MarkdownPreview') == 2 then
      vim.cmd("MarkdownPreview")
    end
  end,
})

-- Enable render-markdown and set up keymaps for mermaid files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "mermaid",
  callback = function()
    -- Enable render-markdown if available for in-buffer rendering
    if vim.fn.exists(':RenderMarkdown') == 2 then
      vim.cmd("RenderMarkdown enable")
    end

    -- Set up buffer-local keymaps
    local opts = { buffer = true, silent = false }
    vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<cr>",
      vim.tbl_extend("force", opts, { desc = "Toggle in-buffer rendering" }))
    vim.keymap.set("n", "<leader>mv", "<cmd>MarkdownPreview<cr>",
      vim.tbl_extend("force", opts, { desc = "View mermaid in browser" }))
    vim.keymap.set("n", "<leader>ml", function()
      -- Manual lint current mermaid file
      local filename = vim.fn.expand("%:p")
      if filename == "" then
        vim.notify("❌ No file to lint", vim.log.levels.WARN)
        return
      end

      vim.notify("🔍 Linting mermaid diagram...")
      vim.fn.jobstart({ "mmdc", "--input", filename, "--output", "/tmp/mermaid_lint_test.svg" }, {
        on_exit = function(_, exit_code)
          -- Clean up temp file
          vim.fn.delete("/tmp/mermaid_lint_test.svg")
          if exit_code == 0 then
            vim.notify("✅ Mermaid syntax is valid!", vim.log.levels.INFO)
          else
            vim.notify("❌ Mermaid syntax has errors", vim.log.levels.ERROR)
          end
        end,
        on_stderr = function(_, data)
          if data and #data > 0 then
            local msg = table.concat(data, "\n")
            if msg:match("UnknownDiagramError") then
              vim.notify("❌ Unknown diagram type - check mermaid syntax", vim.log.levels.ERROR)
            elseif msg:match("Error") then
              vim.notify("❌ Syntax error: " .. msg, vim.log.levels.ERROR)
            end
          end
        end,
      })
    end, vim.tbl_extend("force", opts, { desc = "Lint mermaid diagram" }))

    -- Add a command to check conform formatting
    vim.keymap.set("n", "<leader>mf", function()
      vim.notify("🔧 Running mermaid formatter/validator...")
      require("conform").format({ bufnr = 0, async = false })
      vim.notify("✅ Formatter completed - check :messages for details")
    end, vim.tbl_extend("force", opts, { desc = "Format/validate mermaid file" }))

    -- Generate image and open in Chrome
    vim.keymap.set("n", "<leader>mi", function()
      local filename = vim.fn.expand("%:p")
      local basename = vim.fn.expand("%:t:r")

      if filename == "" then
        vim.notify("❌ No file to generate image from", vim.log.levels.WARN)
        return
      end

      vim.notify("🖼️ Generating PNG image...")

      -- Extract mermaid content and generate image
      local commands = {
        "bash", "-c", string.format([[
          cd "%s" && \
          sed -n '/```mermaid/,/```/p' "%s" | sed '1d;$d' > "%s-clean.mmd" && \
          mmdc --input "%s-clean.mmd" --output "%s.png" --width 1920 --height 1080 --backgroundColor white && \
          rm "%s-clean.mmd" && \
          open -a "Google Chrome" "%s.png"
        ]], vim.fn.expand("%:p:h"), filename, basename, basename, basename, basename, basename)
      }

      vim.fn.jobstart(commands, {
        on_exit = function(_, exit_code)
          if exit_code == 0 then
            vim.notify("✅ Image generated and opened in Chrome!", vim.log.levels.INFO)
          else
            vim.notify("❌ Failed to generate image", vim.log.levels.ERROR)
          end
        end,
        on_stderr = function(_, data)
          if data and #data > 0 then
            local msg = table.concat(data, "\n")
            if msg ~= "" then
              vim.notify("⚠️ " .. msg, vim.log.levels.WARN)
            end
          end
        end,
      })
    end, vim.tbl_extend("force", opts, { desc = "Generate PNG and open in Chrome" }))

    -- Copy mermaid code to clipboard
    vim.keymap.set("n", "<leader>mc", function()
      local filename = vim.fn.expand("%:p")

      if filename == "" then
        vim.notify("❌ No file to copy from", vim.log.levels.WARN)
        return
      end

      -- Extract mermaid content
      local extract_cmd = string.format("sed -n '/```mermaid/,/```/p' '%s' | sed '1d;$d'", filename)

      vim.fn.jobstart({ "bash", "-c", extract_cmd }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data and #data > 0 then
            local mermaid_code = table.concat(data, "\n")
            -- Remove empty lines at the end
            mermaid_code = mermaid_code:gsub("\n+$", "")

            if mermaid_code ~= "" then
              -- Copy to system clipboard
              vim.fn.setreg("+", mermaid_code)
              vim.notify("📋 Mermaid code copied to clipboard!", vim.log.levels.INFO)
            else
              vim.notify("❌ No mermaid code found", vim.log.levels.WARN)
            end
          end
        end,
        on_exit = function(_, exit_code)
          if exit_code ~= 0 then
            vim.notify("❌ Failed to extract mermaid code", vim.log.levels.ERROR)
          end
        end,
      })
    end, vim.tbl_extend("force", opts, { desc = "Copy mermaid code to clipboard" }))
  end,
})

