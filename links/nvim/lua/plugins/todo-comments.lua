return {
  { -- Highlight todo, notes, etc in comments
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      -- These patterns match the defaults:
      --     // todo: use lowercase to prevent a highlight here
      -- and also "tagged" variants like:
      --     // todo(username): also use lowercase to prevent a highlight here
      -- search is used for :TodoFzfLua and similar commands
      highlight = {
        pattern = { [[.*<(KEYWORDS)\s*:]], [[.*<(KEYWORDS)\s*\(.*\)\s*:]] },
        after = "bg",
        keyword = "bg",
      },
      search = {
        pattern = { [[.*<(KEYWORDS)\s*:]], [[.*<(KEYWORDS)\s*\(.*\)\s*:]] },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
