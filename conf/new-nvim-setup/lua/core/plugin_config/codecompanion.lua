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
})


local wk = require("which-key")

-- Add CodeCompanion keybindings
wk.add({
  { "<leader>c",  group = "CodeCompanion" },
  { "<leader>cc", "<cmd>CodeCompanionChat<CR>",    desc = "Open Chat",    mode = "n" },
  { "<leader>ca", "<cmd>CodeCompanionActions<CR>", desc = "Show Actions", mode = "n" },
  { "<leader>ci", "<cmd>CodeCompanion<CR>",        desc = "Inline Chat",  mode = "n" },
})
