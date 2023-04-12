vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true

-- use spaces for tabs and whatnot
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.cmd [[ set noswapfile ]]

--Line numbers
vim.wo.number = true

-- highlight yanked text for 200ms using the "Visual" highlight group
vim.cmd[[
  augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=200})
  augroup END
]]

-- https://www.jvt.me/posts/2022/03/01/neovim-format-on-save/
-- Format on save
--vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

-- https://blog.kdheepak.com/three-built-in-neovim-features.html
-- In neovim show all subsitutions in a file in split window
vim.cmd [[ set inccommand=split ]]

-- Use the system clipboard
vim.cmd [[ set clipboard=unnamedplus ]]

