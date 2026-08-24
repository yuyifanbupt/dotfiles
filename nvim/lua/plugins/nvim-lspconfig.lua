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
      clangd = {
        keys = {
          { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
        },
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          "configure.ac", -- AutoTools
          "Makefile",
          "configure.ac",
          "configure.in",
          "config.h.in",
          "meson.build",
          "meson_options.txt",
          "build.ninja",
          ".git",
        },
        capabilities = {
          offsetEncoding = { "utf-16" },
        },
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      },
    },
  },
}
