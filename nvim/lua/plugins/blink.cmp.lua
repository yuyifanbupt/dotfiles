return {
  "saghen/blink.cmp",
  opts = function()
    local docs = require("blink.cmp.lib.window.docs")
    local original = docs.highlight_with_treesitter

    docs.highlight_with_treesitter = function(buf, ft, first, last)
      if ft == "markdown" then
        local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")

        if ok and parser then
          parser:invalidate(true)
          parser:parse(true)
        end
      end

      return original(buf, ft, first, last)
    end
  end,
}
