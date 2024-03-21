return {

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      --'nvim-treesitter/nvim-treesitter-context',
    },
    build = ':TSUpdate',
    event = 'VeryLazy',

    init = function(plugin)
      require('lazy.core.loader').add_to_rtp(plugin)

      require('nvim-treesitter.query_predicates')
    end,

    config = function()
      local configs = require('nvim-treesitter.configs')

      configs.setup({
        ensure_installed = { 'lua', 'vimdoc', 'vim' },
        sync_install = false,
        highlight = { enable = true },
        indent = {
          enable = true,
          -- disable = { 'lua', 'dart' },
        },
      })
    end,
  },
}
