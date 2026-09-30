return {
  setup = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true

    local function my_on_attach(bufnr)
      local api = require "nvim-tree.api"

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end


      -- default mappings
      api.config.mappings.default_on_attach(bufnr)

      -- custom mappings
      vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
      vim.keymap.set('n', 'S', api.node.run.system, opts('Run'))
      vim.keymap.set('n', 's', api.node.open.vertical, opts('Open: vertical'))
      vim.keymap.set('n', 'i', api.node.open.horizontal, opts('Open: horizontal'))
    end

    require("nvim-tree").setup {
      on_attach = my_on_attach,
      view = {
        width = 40,
      },
    }

    vim.g.nvim_tree_follow = 1
    vim.g.nvim_tree_hide_dotfiles = 0
    vim.g.nvim_tree_indent_markers = 1
    vim.g.nvim_tree_auto_open = 1
    vim.g.nvim_tree_auto_close = 0
    vim.g.nvim_tree_disable_netrw = 0
    vim.g.nvim_tree_auto_ignore_ft = { 'startify', 'dashboard' }
    vim.g.nvim_tree_lsp_diagnostics = 1

    local ff = function()
      vim.cmd [[:NvimTreeFindFile]]
    end
    -- custom commands
    vim.api.nvim_create_user_command('NvimTree', ff, {})
    vim.api.nvim_create_user_command('NT', ff, {})
    vim.api.nvim_create_user_command('NN', ff, {})
  end
}
