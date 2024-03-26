local function has_words_before()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api
        .nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match('%s')
      == nil
end

return function()
  local cmp = require('cmp')
  local luasnip = require('luasnip')

  local formatting_style = {
    fields = { 'abbr', 'kind' },

    format = function(entry, item)
      local kind = require('lspkind').cmp_format({
        mode = 'symbol_text',
        maxwidth = 50,
        show_labelDetails = true,
        symbol_map = { Copilot = '' },
      })(entry, item)
      kind.kind = item.kind

      return kind
    end,
  }

  local options = {
    completion = {
      completeopt = 'menu,menuone',
    },

    window = {
      completion = {
        winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None',
        scrollbar = true,
      },
      documentation = {
        winhighlight = 'Normal:CmpDoc',
      },
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },

    formatting = formatting_style,

    mapping = {
      ['<C-k>'] = cmp.mapping.scroll_docs(-4),
      ['<C-j>'] = cmp.mapping.scroll_docs(4),
      ['<C-e>'] = cmp.mapping.close(),
      ['<C-Space>'] = cmp.mapping(function(_)
        if cmp.visible() then
          cmp.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          })
        else
          cmp.complete()
        end
      end, { 'i', 'c' }),

      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { 'i', 's', 'c' }),

      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's', 'c' }),
    },
    sources = cmp.config.sources({
      {
        name = 'nvim_lsp',
        entry_filter = function(entry, _)
          return cmp.lsp.CompletionItemKind.Text ~= entry:get_kind()
        end,
      },
      { name = 'luasnip' },
      { name = 'nvim_lua' },
      { name = 'path' },
      { name = 'nerdfont' },
    }),
  }

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      {
        name = 'cmdline',
        option = {
          ignore_cmds = { 'Man', '!' },
        },
      },
    }),
  })

  return options
end
