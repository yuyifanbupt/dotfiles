return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000, -- Load this before other plugins
  config = function()
    require("catppuccin").setup({
      -- your configuration options here
    })
    vim.cmd.colorscheme("catppuccin-nvim")
  end,
}
