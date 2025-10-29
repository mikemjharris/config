require("codecompanion").setup({
  adapters = {
    openai = function()
      return require("codecompanion.adapters").extend("openai", {
        env = {
          api_key = "cmd:gpg --quiet --batch --decrypt ~/.secrets/openai_api_key.gpg",
        },
      })
    end,
  },
  strategies = {
    chat = {
      adapter = "openai",
    },
    inline = {
      adapter = "openai",
    },
  },
  display = {
    action_palette = {
      width = 95,
      height = 10,
      prompt = "Prompt ",                   -- Prompt used for interactive LLM calls
      provider = "default",                 -- Can be "default", "telescope", or "mini_pick". If not specified, the plugin will autodetect installed providers.
      opts = {
        show_default_actions = true,        -- Show the default actions in the action palette?
        show_default_prompt_library = true, -- Show the default prompt library in the action palette?
      },
    },
  },
  extensions = {
    mcphub = {
      callback = "mcphub.extensions.codecompanion",
      opts = {
        make_vars = true,
        make_slash_commands = true,
        show_result_in_chat = true,
      },
    },
    vectorcode = {
      opts = {
        add_tool = false,
      },
    },
  },
})


local wk = require("which-key")

-- Add CodeCompanion keybindings
wk.add({
  { "<leader>c",  group = "CodeCompanion" },
  { "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", desc = "Open Chat",        mode = { "n", "v" } },
  { "<leader>ca", "<cmd>CodeCompanionActions<CR>",     desc = "Show Actions",     mode = { "n", "v" } },
  { "<leader>cd", "<cmd>CodeCompanionChat Add<CR>",    desc = "Add code to chat", mode = "v" },
})

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd("cnoreabbrev cc CodeCompanionChat")
