require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    mermaid = { "mermaid_validator" },
  },
  
  formatters = {
    mermaid_validator = {
      command = "bash",
      args = {
        "-c",
        [[
          # Create temporary file for CLI validation (strip code blocks and styling)
          temp_file=$(mktemp --suffix=.mmd)
          
          # Extract mermaid content and remove problematic styling blocks
          if head -1 "$1" | grep -q '```mermaid'; then
            sed '1d;$d' "$1" | sed '/classDef/d; /class /d' > "$temp_file"
          else
            sed '/classDef/d; /class /d' "$1" > "$temp_file"
          fi
          
          # Validate basic structure (CLI without styling)
          if mmdc --input "$temp_file" --output /tmp/mermaid_test.svg 2>/dev/null; then
            echo "✅ Mermaid structure valid (styling preserved for browser)" >&2
            rm -f /tmp/mermaid_test.svg
          else
            echo "⚠️ Mermaid structure issues detected" >&2
          fi
          
          rm -f "$temp_file"
          cat "$1"  # Return original content unchanged
        ]],
        "$FILENAME"
      },
      stdin = false,
    },
  },
  
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
