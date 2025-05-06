require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'ayu_light',
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
