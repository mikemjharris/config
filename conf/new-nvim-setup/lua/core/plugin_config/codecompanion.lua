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
})
