set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

" https://blog.kdheepak.com/three-built-in-neovim-features.html
" In neovim show all subsitutions in a file in split window
set inccommand=split


" https://blog.kdheepak.com/three-built-in-neovim-features.html
" highlight yanked text
augroup LuaHighlight
  autocmd!
  autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END
