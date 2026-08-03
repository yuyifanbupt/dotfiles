-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = { "*/.venv/*", "*/node_modules/*", "*/dist/*" },
  callback = function()
    vim.bo.modifiable = false
    vim.bo.readonly = true
  end,
})

vim.opt.clipboard = ""
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
