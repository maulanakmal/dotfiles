local conform = require("conform")
local telescope_builtin = require('telescope.builtin')
local telescope_themes = require('telescope.themes')
keymaps = {
    global = {
        ["<leader>lf"] = { "n", function() conform.format() end, "Format (Conform, LSP)" },
        ["<leader>f"] = { "n", telescope_builtin.find_files, "Find Files" },
        ["<leader>g"] = { "n", telescope_builtin.live_grep, "Live Grep" },

        ["gi"] = {},
        ["gd"] = {},
        ["gc"] = {},
        ["gr"] = {},
        ["go"] = {},
    },
    telescope = {

    },

}
