vim.o.termguicolors = true
--vim.cmd [[ colorscheme tokyonight-day]]
vim.o.background = "light"
vim.cmd [[ colorscheme PaperColorSlimLight ]]

vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#d0eaff' })

vim.opt.signcolumn = 'yes'

-- csvview.nvim column colors (light theme friendly)
local csv_colors = {
  '#2e7d32', -- green
  '#1565c0', -- blue
  '#6a1b9a', -- purple
  '#e65100', -- orange
  '#00838f', -- teal
  '#ad1457', -- pink
  '#4e342e', -- brown
  '#283593', -- indigo
  '#558b2f', -- lime
}
for i, color in ipairs(csv_colors) do
  vim.api.nvim_set_hl(0, 'CsvViewCol' .. (i - 1), { fg = color })
end

-- Auto-enable csvview for CSV files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'csv',
  callback = function()
    require('csvview').enable()
  end,
})
