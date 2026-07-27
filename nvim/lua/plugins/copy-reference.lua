return {
  "cajames/copy-reference.nvim",
  opts = {}, -- optional configuration
  keys = {
    { "yr", "<cmd>CopyReference file<cr>", mode = { "n", "v" }, desc = "Copy file path" },
    { "<leader>o", "<cmd>CopyReference line<cr>", mode = { "n", "v" }, desc = "Copy file:line reference" },
  },
}
