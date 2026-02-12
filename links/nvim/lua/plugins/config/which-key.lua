-- which-key configuration and group labels.

local which_key = give("which-key")
if not which_key then
  return
end

which_key.setup({
  icons = {
    mappings = true,
    separator = "┝",
  },
})
