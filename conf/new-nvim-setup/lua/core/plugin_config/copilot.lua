--highlight gray
--highlight gray guifg=#5c6370
vim.cmd [[highlight CopilotSuggestion ctermfg=8 guifg=white guibg=#5c6370]]

-- Optional: Add keybindings to cycle through Copilot suggestions
vim.api.nvim_set_keymap("i", "<C-,>", '<Plug>(copilot-next)', {})
vim.api.nvim_set_keymap("i", "<C-.>", '<Plug>(copilot-previous)', {})
