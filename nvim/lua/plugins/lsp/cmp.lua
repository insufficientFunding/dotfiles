return {
  'hrsh7th/nvim-cmp',
  event = { 'InsertEnter' },
  dependencies = {
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-nvim-lsp',
    -- 'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-path',
    'chrisgrieser/cmp-nerdfont',
    'onsails/lspkind.nvim',
    'hrsh7th/cmp-cmdline',
  },
  opts = require('config.plugins.cmp'),
}
