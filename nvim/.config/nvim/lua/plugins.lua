local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

return packer.startup(function(use)
  use("wbthomason/packer.nvim")

  use 'wakatime/vim-wakatime'

  -- nvim-treesitter: the frozen `master` branch (old API) only supports Nvim <= 0.11,
  -- while the rewritten `main` branch (new API) requires Nvim >= 0.12.
  local ts_version = vim.version()
  local ts_use_new_api = (ts_version.major > 0) or (ts_version.major == 0 and ts_version.minor >= 12)

  if ts_use_new_api then
    use({
      'nvim-treesitter/nvim-treesitter',
      branch = 'main',
      config = function()
        require('nvim-treesitter').setup {
          install_dir = fn.stdpath('data') .. '/site',
        }
        require('nvim-treesitter').install { "cpp", "c", "lua", "python", "vim", "vimdoc", "query", "nix", "markdown", "markdown_inline" }
        vim.api.nvim_create_autocmd('FileType', {
          pattern = { 'c', 'cpp', 'lua', 'python', 'vim', 'vimdoc', 'query', 'nix', 'markdown' },
          callback = function() vim.treesitter.start() end,
        })
      end,
    })
  else
    use({
      'nvim-treesitter/nvim-treesitter',
      branch = 'master',
      config = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
        require 'nvim-treesitter.configs'.setup {
          ensure_installed = { "cpp", "c", "lua", "python", "vim", "vimdoc", "query", "nix", "markdown", "markdown_inline" },
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          }
        }
      end,
    })
  end

  -- use {
  --   'neovim/nvim-lspconfig',
  --   config = function()
  --     require "setups.lsp".setup()
  --   end,
  --   requires = { 'hrsh7th/cmp-nvim-lsp' }
  -- }
  --
  --
  -- use {
  --   'hrsh7th/nvim-cmp',
  --   config = function()
  --     require "setups.nvim-cmp".setup()
  --   end,
  --   requires = { 'L3MON4D3/LuaSnip' }
  -- }
  -- use { 'hrsh7th/cmp-nvim-lsp' }
  --
  -- use {
  --   "L3MON4D3/LuaSnip",
  --   tag = "v2.3.0",
  --   run = "make install_jsregexp"
  -- }

  use {
    'neoclide/coc.nvim',
    branch = 'release',
    config = function()
      require "setups.coc".setup()
    end
  }

  use({
    'MeanderingProgrammer/markdown.nvim',
    after = { 'nvim-treesitter' },
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }, -- if you prefer nvim-web-devicons
    config = function()
      require('render-markdown').setup({})
    end,
  })

  use {
    "mfussenegger/nvim-dap",
    config = function()
      -- if fails to start with:
      -- Error on launch: Failed to attach to the target process. Timed out trying to get messages from the runInTerminal launcher
      -- echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
      require "setups.dap".setup()
    end
  }
  use {
    "rcarriga/nvim-dap-ui",
    requires = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require "setups.dap-ui".setup()
    end
  }

  use {
    'theHamsta/nvim-dap-virtual-text',
    config = function()
      require("nvim-dap-virtual-text").setup {
        show_stop_reason = false,
      }
    end
  }

  use { 'elkowar/yuck.vim' }
  -- use { 'RaafatTurki/hex.nvim', config = function() require 'hex'.setup() end }

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup {
        options = { theme = "auto" },
        sections = {
          lualine_c = { "filename" } -- [[%{coc#status()}]]
        }
      }
    end
  }

  use({
    "folke/drop.nvim",
    event = "VimEnter",
    config = function()
      require("drop").setup {
        screensaver = 1000 * 60 * 5,
        themes = {
          { theme = "new_year", month = 1, day = 1 },
          { theme = "valentines_day", month = 2, day = 14 },
          { theme = "st_patricks_day", month = 3, day = 17 },
          { theme = "easter", holiday = "easter" },
          { theme = "april_fools", month = 4, day = 1 },
          { theme = "us_independence_day", month = 7, day = 4 },
          { theme = "halloween", month = 10, day = 31 },
          { theme = "us_thanksgiving", holiday = "us_thanksgiving" },
          { theme = "xmas", from = { month = 12, day = 24 }, to = { month = 12, day = 25 } },
          { theme = "leaves", from = { month = 9, day = 1 }, to = { month = 11, day = 30 } },
          { theme = "snow", from = { month = 12, day = 1 }, to = { month = 3, day = 29 } },
          { theme = "spring", from = { month = 3, day = 1 }, to = { month = 5, day = 31 } },
          { theme = "summer", from = { month = 6, day = 1 }, to = { month = 8, day = 31 } },
        },
        filetypes = { --[[ "dashboard", ]] "alpha", "starter" },
      }
    end,
  })

  use { 'numToStr/Comment.nvim',
    config = function() require('Comment').setup() end }

  use { 'kyazdani42/nvim-web-devicons' }

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.x',
    requires = { { 'nvim-lua/plenary.nvim' } },
    config = function()
      require "setups.telescope".setup()
    end
  }

  use {
    "nvim-telescope/telescope-file-browser.nvim",
    requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  }

  use {
    'rmagatti/auto-session',
    config = function()
      require("auto-session").setup {
        log_level = "error",
        auto_session_suppress_dirs = { "~/" }
      }
    end
  }


  use { 'ghassan0/telescope-glyph.nvim' }
  use { 'xiyaowong/telescope-emoji.nvim' }
  use { "smartpde/telescope-recent-files" }
  use { 'nvim-telescope/telescope-project.nvim' }
  use { 'fannheyward/telescope-coc.nvim' }

  use {
    "amitds1997/remote-nvim.nvim",
    tag = "v0.3.9",
    requires = {
      "nvim-lua/plenary.nvim",         -- For standard functions
      "MunifTanjim/nui.nvim",          -- To build the plugin UI
      "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
    },
    config = function()
      require("remote-nvim").setup()
    end
  }

  use { "alexghergh/nvim-tmux-navigation", config = function()
      require'nvim-tmux-navigation'.setup {
        disable_when_zoomed = true, -- defaults to false
        keybindings = {
            left = "<C-Left>",
            down = "<C-Down>",
            up = "<C-Up>",
            right = "<C-Right>",
        }
      }
    end
  }

  use {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
      }
    end
  }

  use {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require("setups.dashboard").setup()
    end,
    requires = { 'nvim-tree/nvim-web-devicons' }
  }

  use { "nvim-tree/nvim-tree.lua",
    config = function()
      require "setups.nvim-tree".setup()
    end
  }

  -- use { "Exafunction/windsurf.vim" }

  use { 'rebelot/kanagawa.nvim' }
  use { 'ellisonleao/gruvbox.nvim',
    config = function()
      require("gruvbox").setup {
        contrast = "hard",
        transparent_mode = true
      }
      vim.o.background = 'dark'
      vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
    end
  }
  use { 'ErichDonGubler/vim-sublime-monokai' }
  use { "folke/tokyonight.nvim" }
  use { 'shaunsingh/nord.nvim' }
  -- use { "catppuccin/nvim", as = "catppuccin",
  --   config = function()
  --     require('catppuccin').setup({ flavour = "mocha" })
  --   end
  -- }

  use { "xiyaowong/transparent.nvim", config = function()
    vim.cmd [[hi CursorLine ctermbg=None guibg=None term=underline gui=underline]]
    require("transparent").setup {
      groups = { -- table: default groups
        'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
        'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
        'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
        'SignColumn', 'CursorLineNr', 'EndOfBuffer', 'NormalSB', 'Pmenu', 'CocInlayHint'
      },
      --exclude_groups={"CursorLine"}
    }
    -- require('transparent').clear_prefix('lualine')
    require('transparent').clear_prefix('Dashboard')
    require('transparent').clear_prefix('CursorLine')
    vim.cmd [[hi CursorLine ctermbg=None guibg=None term=underline gui=underline]]
  end }

  -- use {"3rd/image.nvim", config = function() 
  --   require('image').setup{
  --   }
  -- end }

  use "sindrets/diffview.nvim"

  use { "sphamba/smear-cursor.nvim", config = function()
    require('smear_cursor').setup()
  end }

  -- use 'Exafunction/codeium.vim'

  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end


  vim.cmd("hi CursorLine ctermbg=None guibg=None term=underline gui=underline")
  -- use 'cohama/lexima.vim'
end)
