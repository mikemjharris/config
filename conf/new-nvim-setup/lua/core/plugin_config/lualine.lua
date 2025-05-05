require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'PaperColorSchemeLight',
  },
  sections = {
    lualine_a = {
      {
        'filename',
        path = 1,
      }
    }
  }
}
