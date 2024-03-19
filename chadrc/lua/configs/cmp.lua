local cmp = require('cmp')

dofile(vim.g.base46_cache .. 'cmp')

local cmp_ui = require('nvconfig').ui.cmp
local cmp_style = cmp_ui.style

local field_arrangement = {
  atom = { 'kind', 'abbr', 'menu' },
  atom_colored = { 'kind', 'abbr', 'menu' },
}

local formatting_style = {
  -- default fields order i.e completion word + item.kind + item.kind icons
  fields = field_arrangement[cmp_style] or { 'abbr', 'kind', 'menu' },

  format = function(_, item)
    local icons = require('nvchad.icons.lspkind')
    local icon = (cmp_ui.icons and icons[item.kind]) or ''

    if cmp_style == 'atom' or cmp_style == 'atom_colored' then
      icon = ' ' .. icon .. ' '
      item.menu = cmp_ui.lspkind_text and '   (' .. item.kind .. ')' or ''
      item.kind = icon
    else
      icon = cmp_ui.lspkind_text and (' ' .. icon .. ' ') or icon
      item.kind = string.format('%s %s', icon, cmp_ui.lspkind_text and item.kind or '')
    end

    return item
  end,
}

local function border(hl_name)
  return {
    { '╭', hl_name },
    { '─', hl_name },
    { '╮', hl_name },
    { '│', hl_name },
    { '╯', hl_name },
    { '─', hl_name },
    { '╰', hl_name },
    { '│', hl_name },
  }
end

local options = {
  completion = {
    completeopt = 'menu,menuone',
  },

  window = {
    completion = {
      side_padding = (cmp_style ~= 'atom' and cmp_style ~= 'atom_colored') and 1 or 0,
      winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None',
      scrollbar = false,
    },
    documentation = {
      border = border('CmpDocBorder'),
      winhighlight = 'Normal:CmpDoc',
    },
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },

  formatting = formatting_style,

  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
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
    end),

    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require('luasnip').expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require('luasnip').jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
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
  },
}

if cmp_style ~= 'atom' and cmp_style ~= 'atom_colored' then options.window.completion.border = border('CmpBorder') end

return options