local vim = vim
local opt = vim.opt

if vim.g.vscode then
   return
end

require("config.lazy")

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.number = true
opt.relativenumber = true
opt.expandtab = true
vim.diagnostic.config({
    virtual_text = true,
})

opt.expandtab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4

opt.autoindent = true
opt.smartindent = true

opt.list = true
opt.listchars = {
    tab = "▸ ",
    trail = "·",
    extends = "▶",
    precedes = "◀",
    nbsp = "␣",
}


vim.o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- vim.keymap.set("n", "<c-P>", require('fzf-lua').files, { desc = "Fzf Files" })
-- vim.keymap.set("n", "<c-r>", require('fzf-lua').lsp_references, { desc = "Fzf References" })

-- vim.keymap.set('n', '<leader>N', <cmd> , { desc = 'NeoTree' })

local telescope_builtin = require('telescope.builtin')
local telescope_themes = require('telescope.themes')

local function find_files_with_hidden_files()
    -- local theme = telescope_themes.get_dropdown({ winblend = 10 })
    telescope_builtin.find_files({ hidden = true })
end

local function live_grep()
    -- local theme = telescope_themes.get_dropdown({ winblend = 10 })
    telescope_builtin.live_grep()
end

vim.keymap.set("n", "<leader>lf", function()
    require("conform").format()
end, { desc = "Format file" })

vim.keymap.set('n', '<leader>f', telescope_builtin.find_files, { desc = 'Telescope find files' })

vim.keymap.set('n', '<leader><leader>f', find_files_with_hidden_files,
    { desc = 'Telescope find files with hidden files' })
vim.keymap.set('n', '<leader>g', live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>b', telescope_builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>th', telescope_builtin.help_tags, { desc = 'Telescope help tags' })

vim.keymap.set('n', 'gi', telescope_builtin.lsp_implementations, { desc = 'Telescope buffers' })
vim.keymap.set('n', 'gd', telescope_builtin.lsp_definitions, { desc = 'Telescope buffers' })
vim.keymap.set('n', 'gc', telescope_builtin.lsp_incoming_calls, { desc = 'Telescope buffers' })
vim.keymap.set('n', 'gr', telescope_builtin.lsp_references, { desc = 'Telescope buffers' })
vim.keymap.set('n', 'go', telescope_builtin.lsp_outgoing_calls, { desc = 'Telescope buffers' })

vim.keymap.set('n', 'gst', telescope_builtin.git_status, { desc = 'Telescope buffers' })

vim.keymap.set('n', 'lds', telescope_builtin.lsp_document_symbols, { desc = 'Telescope buffers' })
vim.keymap.set('n', 'lws', telescope_builtin.lsp_workspace_symbols, { desc = 'Telescope buffers' })

-- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP format' })

local function lsp_attached()
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })     -- Get active clients for the current buffer
    return next(clients) ~= nil                                   -- Returns true if there are any active clients
end
local function goToDefinition()
    if lsp_attached() then
        vim.lsp.buf.definition()
    end
end

vim.keymap.set('n', '<C-N>', function() vim.cmd('Neotree toggle position=left') end, { desc = 'Go to definition' })

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { desc = 'LSP format' })
vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { desc = 'LSP rename' })
vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, { desc = 'LSP hover' })

vim.keymap.set('n', '<leader>xx', function() vim.cmd('Trouble diagnostics toggle win = { type = float } focus=true') end,
    { desc = 'diag' })


vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
        }
    end
    require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })


local api = vim.api
local M = {}
function M.nvim_create_augroups(definitions)
    for group_name, definition in pairs(definitions) do
        api.nvim_command("augroup " .. group_name)
        api.nvim_command("autocmd!")
        for _, def in ipairs(definition) do
            local event, pattern, command = def[1], def[2], def[3]
            if type(command) == "function" then
                api.nvim_create_autocmd(event, {
                    pattern = pattern,
                    group = group_name,
                    callback = command,
                })
            else
                local cmd = table.concat(vim.tbl_flatten({ "autocmd", event, pattern, command }), " ")
                api.nvim_command(cmd)
            end
        end
        api.nvim_command("augroup END")
    end
end

local autoCommands = {
    -- other autocommands
    open_folds = {
        {
            { "BufReadPost", "FileReadPost" },
            "*",
            function()
                vim.schedule(function()
                    vim.cmd("silent! normal! zx")                     -- refresh folds
                    vim.cmd("silent! normal! zR")                     -- open all folds
                end)
            end
        },
    }
}

M.nvim_create_augroups(autoCommands)
