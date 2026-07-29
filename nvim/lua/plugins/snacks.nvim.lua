return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true,
      ignored = true,
      sources = {
        files = {
          hidden = true,
          ignored = true,
        },
      },
      win = {
        -- input window
        input = {
          keys = {
            -- to close the picker on ESC instead of going to normal mode,
            -- add the following keymap to your config
            -- ["<Esc>"] = { "close", mode = { "n", "i" } },
            ["H"] = { "toggle_hidden", mode = { "n" } },
            ["I"] = { "toggle_ignored", mode = { "n" } },
          },
        },
        -- result list window
        list = {
          keys = {
            ["H"] = "toggle_hidden",
            ["I"] = "toggle_ignored",
          },
        },
      },
    },
  },
}
