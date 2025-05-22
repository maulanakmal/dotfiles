-- This file can be loaded by calling `lua require('lazy')` from your init.vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"


-- Setup lazy.nvim
require("lazy").setup({
  spec = {

    {
      "rcarriga/nvim-notify",
      config = function()
        vim.notify = require("notify")
      end
    },
    -- import your plugins
    { import = "plugins" },
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
      },
      config = function()
        local neotree = require("neo-tree")
        neotree.setup({
          popup_border_style = "rounded",

          close_if_last_window = false,
          filesystem = {
            follow_current_file = {
              enabled = true,          -- This will find and focus the file in the active buffer every time
              --               -- the current file is changed while the tree is open.
              leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
            },
          },
        })
      end
    },
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-project.nvim',
      },
      config = function()
        local telescope = require('telescope')
        telescope.setup {
          defaults = {
            layout_config = {
              prompt_position = "top", -- Moves the prompt to the top
              -- anchor = "center"
            },
            mappings = {
              i = {
                -- map actions.which_key to <C-h> (default: <C-/>)
                -- actions.which_key shows the mappings for your picker,
                -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                -- ["<C-h>"] = "which_key"
              }
            }
          },

          -- extensions = {
          --   project = {
          --     base_dirs = {
          --       '~/.config/nvim',
          --       -- '~/Work/shopee',
          --     },
          --   },
          -- },

          pickers = {
            find_files = {
            }
          }
        }

        telescope.load_extension('project')
      end,
    },
    -- lazy.nvim
    {
      "folke/noice.nvim",
      event = "VeryLazy",
      opts = {
        -- add any options here
      },
      dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        "rcarriga/nvim-notify",
      },
      config = function()
        require("noice").setup({
          lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
              ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
              ["vim.lsp.util.stylize_markdown"] = true,
              ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
            },
          },
          -- you can enable a preset for easier configuration
          presets = {
            -- bottom_search = true, -- use a classic bottom cmdline for search
            command_palette = true,       -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false,           -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = false,       -- add a border to hover docs and signature help
          },
        })
      end,

    },
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      ---@module "ibl"
      ---@type ibl.config
      opts = {
        exclude = {
          filetypes = {
            "dashboard"
          }
        }
      },
    },
    {
      "ggandor/leap.nvim",
      config = function()
        require('leap').create_default_mappings()
      end
    },
    {
      "nvim-treesitter/nvim-treesitter",
      version = false,
      build = function()
        require("nvim-treesitter.install").update({ with_sync = true })
      end,
      config = function()
        local config = {
          -- A list of parser names, or "all" (the listed parsers MUST always be installed)
          ensure_installed = {
            "c",
            "lua",
            "vim",
            "vimdoc",
            "query",
            "markdown",
            "markdown_inline",
            "go",
            "rust",
            "python",
            "java",
            "kotlin",
            "json",
            "yaml",
            "toml",
            "bash",
            "diff",
          },

          -- Install parsers synchronously (only applied to `ensure_installed`)
          sync_install = false,

          -- Automatically install missing parsers when entering buffer
          -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
          auto_install = true,

          -- List of parsers to ignore installing (or "all")
          -- ignore_install = { "javascript" },

          ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
          -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

          highlight = {
            enable = true,

            -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
            -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
            -- the name of the parser)
            -- list of language that will be disabled
            -- disable = { "c", "rust" },
            -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
            disable = function(lang, buf)
              if lang == 'sql' then
                return true
              end
              local max_filesize = 200 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
          }
        }
        require("nvim-treesitter.configs").setup(config)
      end
    },
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        require('lualine').setup {
          options = {
            theme = 'sonokai'
          }
        }
      end
    },
    {
      'akinsho/toggleterm.nvim',
      version = "*",
      config = function()
        local tt = require('toggleterm')
        tt.setup {
          open_mapping = [[<c-\>]],
          terminal_mappings = true,
          direction = 'float',
          float_opts = {
            -- The border key is *almost* the same as 'nvim_open_win'
            -- see :h nvim_open_win for details on borders however
            -- the 'curved' border is a custom border type
            -- not natively supported but implemented in this plugin.
            -- border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
            border = 'curved',
            -- like `size`, width, height, row, and col can be a number or function which is passed the current terminal
            width = 200,
            height = 50,
            -- row = <value>,
            -- col = <value>,
            -- winblend = 3,
            -- zindex = <value>,
            -- title_pos = 'left' | 'center' | 'right', position of the title of the floating window
          },
        }
      end
    },


    {
      'stevearc/conform.nvim',
      config = function()
        require("conform").setup({
          formatters_by_ft = {
            lua = { "stylua" },
            proto = { "buf" },
            python = { 'black' },
            kotlin = { "ktlint" },
          },
          default_format_opts = {
            lsp_format = "fallback",
          },
        }
        )
      end
    },
    { 'airblade/vim-gitgutter' },
    {
      "kylechui/nvim-surround",
      version = "*", -- Use for stability; omit to use `main` branch for the latest features
      event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({
          -- Configuration here, or leave empty to use defaults
        })
      end
    },
    {
      'RRethy/vim-illuminate',
      config = function()
        -- default configuration
        require('illuminate').configure({
          -- providers: provider used to get references in the buffer, ordered by priority
          providers = {
            'lsp',
            'treesitter',
            'regex',
          },
          -- delay: delay in milliseconds
          delay = 100,
          -- filetype_overrides: filetype specific overrides.
          -- The keys are strings to represent the filetype while the values are tables that
          -- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
          filetype_overrides = {},
          -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
          filetypes_denylist = {
            'dirbuf',
            'dirvish',
            'fugitive',
          },
          -- filetypes_allowlist: filetypes to illuminate, this is overridden by filetypes_denylist
          -- You must set filetypes_denylist = {} to override the defaults to allow filetypes_allowlist to take effect
          filetypes_allowlist = {},
          -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
          -- See `:help mode()` for possible values
          modes_denylist = {},
          -- modes_allowlist: modes to illuminate, this is overridden by modes_denylist
          -- See `:help mode()` for possible values
          modes_allowlist = {},
          -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
          -- Only applies to the 'regex' provider
          -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
          providers_regex_syntax_denylist = {},
          -- providers_regex_syntax_allowlist: syntax to illuminate, this is overridden by providers_regex_syntax_denylist
          -- Only applies to the 'regex' provider
          -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
          providers_regex_syntax_allowlist = {},
          -- under_cursor: whether or not to illuminate under the cursor
          under_cursor = true,
          -- large_file_cutoff: number of lines at which to use large_file_config
          -- The `under_cursor` option is disabled when this cutoff is hit
          large_file_cutoff = nil,
          -- large_file_config: config to use for large files (based on large_file_cutoff).
          -- Supports the same keys passed to .configure
          -- If nil, vim-illuminate will be disabled for large files.
          large_file_overrides = nil,
          -- min_count_to_highlight: minimum number of matches required to perform highlighting
          min_count_to_highlight = 1,
          -- should_enable: a callback that overrides all other settings to
          -- enable/disable illumination. This will be called a lot so don't do
          -- anything expensive in it.
          should_enable = function(bufnr) return true end,
          -- case_insensitive_regex: sets regex case sensitivity
          case_insensitive_regex = false,
        })
      end
    },
    { 'cohama/lexima.vim' },
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {},
    },
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      lazy = true
    },
    { "tpope/vim-fugitive" },
    {
      "olexsmir/gopher.nvim",
      ft = "go",
      -- branch = "develop", -- if you want develop branch
      -- keep in mind, it might break everything
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "mfussenegger/nvim-dap", -- (optional) only if you use `gopher.dap`
      },
      -- (optional) will update plugin's deps on every update
      build = function()
        vim.cmd.GoInstallDeps()
      end,
      ---@type gopher.Config
      opts = {},
    },
    { "sindrets/diffview.nvim" },
    {
      "smoka7/multicursors.nvim",
      event = "VeryLazy",
      dependencies = {
        'nvimtools/hydra.nvim',
      },
      opts = {},
      cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
      keys = {
        {
          mode = { 'v', 'n' },
          '<Leader>m',
          '<cmd>MCstart<cr>',
          desc = 'Create a selection for selected text or word under the cursor',
        },
      },
    },
    {
      'sainnhe/sonokai',
      lazy = false,
      priority = 1000,
      config = function()
        -- Optionally configure and load the colorscheme
        -- directly inside the plugin declaration.
        vim.g.sonokai_enable_italic = true
        vim.cmd.colorscheme('sonokai')
      end
    },
    -- Lazy
    {
      "jackMort/ChatGPT.nvim",
      event = "VeryLazy",
      config = function()
        local home = vim.fn.expand("$HOME")
        require("chatgpt").setup({
          api_key_cmd = "gpg --decrypt " .. home .. "/.openapikey.gpg",
          popup_input = {
            submit = "<CR>"
          }
        })
      end,
      dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "folke/trouble.nvim", -- optional
        "nvim-telescope/telescope.nvim"
      }
    },
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      keys = {
        {
          "<leader>?",
          function()
            require("which-key").show({ global = false })
          end,
          desc = "Buffer Local Keymaps (which-key)",
        },
        -- {
        --   "<c-k>",
        --   "<cmd>ChatGPT<cr>",
        --   desc = "ChatGPT",
        -- },
        {
          "<C-k>",
          function()
            -- Find existing ChatGPT buffer
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_get_name(buf):match("chatgpt%-.*") then
                -- If found, close the ChatGPT window
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  if vim.api.nvim_win_get_buf(win) == buf then
                    vim.api.nvim_win_close(win, true)
                    return
                  end
                end
              end
            end
            -- If no ChatGPT buffer open, open it
            vim.cmd("ChatGPT")
          end,
          desc = "ChatGPT Toggle",
        },

      },
    },
    { "alker0/chezmoi.vim" }
  },

  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "catppuccin-mocha" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})
