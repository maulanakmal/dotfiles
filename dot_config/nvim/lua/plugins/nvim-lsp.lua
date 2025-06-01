lsp_configs = {
    ['pyright'] = {},
    ['gopls'] = {
        settings = {
            gopls = {
                gofumpt = true,
                -- analyses = {
                --     unusedparams = true,
                --     shadow = true,
                --     unreachable = true,
                -- },
                -- staticcheck = true,
                -- usePlaceholders = true,
                -- completeUnimported = true,
                -- codelenses = {
                --     generate = true,
                --     gc_details = true,
                --     test = true,
                --     tidy = true,
                --     upgrade_dependency = true,
                -- },
            }
        }
    },
    ['lua_ls'] = {
        on_init = function(client)
            if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                    return
                end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                    -- Tell the language server which version of Lua you're using
                    -- (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT'
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                        "${3rd}/luv/library"
                        -- "${3rd}/busted/library",
                    }
                    -- -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                    -- library = vim.api.nvim_get_runtime_file("", true)
                }
            })
        end,
        settings = {
            Lua = {}
        }
    },
    ['bashls'] = {},
    ['yamlls'] = {},
    ['nil_ls'] = {},     -- for nix language, no formatter support

    -- protobuf
    -- ['bufls'] = {}, -- protobuf, not working cause 1 folder contains multiple files that has the same symbol name
    -- ['pbls'] = {}, -- protobuf
    -- ['protols'] = {}, -- protobuf
    ['kotlin_language_server'] = {},
}

return {
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
        config = function()
            local mason = require("mason")
            mason.setup()

            local mason_lspconfig = require "mason-lspconfig"
            local lspconfig = require("lspconfig")

            -- Log setup calls
            -- local original_setup = lspconfig.lua_ls.setup
            -- lspconfig.lua_ls.setup = function(config)
            --         print("lua_ls was setup with config:")
            --         print(vim.inspect(config))
            --         return original_setup(config)
            -- end



            local lsp_list = {}
            for ls in pairs(lsp_configs) do
                table.insert(lsp_list, ls)
            end

            mason_lspconfig.setup {
                automatic_enable = false
                -- ensure_installed = lsp_list,
            }
            for ls, config in pairs(lsp_configs) do
                lspconfig[ls].setup(config)
            end

            -- local capabilities = vim.lsp.protocol.make_client_capabilities()
            -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
        end
    }
}
