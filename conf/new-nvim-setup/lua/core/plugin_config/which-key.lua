vim.o.timeout = true
vim.o.timeoutlen = 300


--require("which-key").setup({})

local wk = require("which-key")
-- As an example, we will create the following mappings:
--  * <leader>ff find files
--  * <leader>fr show recent files
--  * <leader>fb Foobar
-- we'll document:
--  * <leader>fn new file
--  * <leader>fe edit file
-- and hide <leader>1

wk.register({
  f = {
    name = "file",                                                                   -- optional group name
    f = { "<cmd>Telescope find_files<cr>", "Find File" },                            -- create a binding with label
    n = { "New File" },                                                              -- just a label. don't create any mapping
    x = { function() print("This is an example of what you can do") end, "Foobar" }, -- you can also pass functions!
    c = { "<cmd> :let @+=@% <cr>", 'Copy file name' }
  }
}, { prefix = "<leader>" })
