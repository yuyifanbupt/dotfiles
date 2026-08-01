return {
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    config = function()
      require("blame").setup({
        date_format = "%Y-%m-%d",
      })
    end,
    keys = {
      { "<leader>gb", "<cmd>BlameToggle<cr>", mode = { "n" }, desc = "git blame toggle" },
    },
  },
}
