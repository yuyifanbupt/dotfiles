return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          {
            "gd",
            function()
              Snacks.picker.lsp_definitions({
                jump = {
                  reuse_win = true,
                  tagstack = true,
                },
                confirm = function(picker, item)
                  picker:close()
                  vim.cmd("edit " .. item.file)
                  vim.api.nvim_win_set_cursor(0, { item.pos[1], item.pos[2] })
                  vim.cmd("normal! zt")
                end,
              })
            end,
            desc = "Goto Definition",
          },
        },
      },
      -- pylsp = {
      --   settings = {
      --     pylsp = {
      --       plugins = {
      --         pycodestyle = {
      --           maxLineLength = 120,
      --         },
      --       },
      --     },
      --   },
      -- },
    },
  },
}
