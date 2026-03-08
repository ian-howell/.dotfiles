local ripple_on_save = require("ripple-on-save")

ripple_on_save.setup({
  steps_ms = 10,
  highlight = "Folded",
  only_modified = false,
})

vim.api.nvim_create_user_command("RippleToggle", function()
  local enabled = ripple_on_save.toggle()
  vim.notify("Ripple on save: " .. (enabled and "on" or "off"))
end, { desc = "Toggle ripple on save" })
