require('persisted').setup({
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved
  command = "VimLeavePre",                                          -- the autocommand for saving the session
  use_git_branch = true,                                            -- create session files based on the branch of the git repository
  branch_separator = "_",                                           -- string used to separate session directory name from branch name
  autosave = true,                                                  -- automatically save session files when exiting Neovim
  autoload = true,                                                  -- automatically load the session for the current directory on Neovim start
  on_autoload_no_session = function()
    vim.notify("No existing session for: " .. vim.fn.getcwd(), vim.log.levels.INFO)
  end,
})

local wk = require("which-key")
wk.add({
  { "<leader>ks", "<cmd>SessionSave<CR>",         desc = "Save session",   mode = "n" },
  { "<leader>kl", "<cmd>SessionLoad<CR>",         desc = "Load session",   mode = "n" },
  { "<leader>kd", "<cmd>SessionDelete<CR>",       desc = "Delete session", mode = "n" },
  { "<leader>kf", "<cmd>Telescope persisted<CR>", desc = "Find sessions",  mode = "n" },
}, { prefix = "" })
