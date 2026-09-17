return {
  "nvim-mini/mini.map",
  version = "*",
  lazy = false,
  keys = {
    { "<leader>mt", "<cmd>lua MiniMap.toggle()<cr>", desc = "Toggle minimap" },
  },
  config = function()
    local map = require("mini.map")
    map.setup({})

    vim.api.nvim_create_autocmd("User", {
      pattern = { "PersistenceLoadPost", "SnacksSessionLoad" },
      callback = function()
        -- Brief delay ensures the session layout is fully settled first
        vim.defer_fn(function()
          map.open()
        end, 50)
      end,
    })
  end,
}
