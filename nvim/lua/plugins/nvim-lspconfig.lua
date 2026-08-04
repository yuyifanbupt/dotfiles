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
                confirm = function(picker, item, action)
                  local insert = vim.fn.mode():sub(1, 1) == "i"
                  Snacks.picker.actions.jump(picker, item, action)

                  local function align_top()
                    vim.cmd("normal! zt")
                  end
                  if insert then
                    vim.schedule(align_top)
                  else
                    align_top()
                  end
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
