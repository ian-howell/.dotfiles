return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
      gitbrowse = {
        url_patterns = {
          ["dev%.azure%.com"] = {
            branch = "?version=GB{branch}",
            file = "?path=/{file}&version=GB{branch}&line={line_start}&lineEnd={line_end}&lineStartColumn=1&lineEndColumn=9999&lineStyle=plain&_a=contents",
            permalink = "?path=/{file}&version=GC{commit}&line={line_start}&lineEnd={line_end}&lineStartColumn=1&lineEndColumn=9999&lineStyle=plain&_a=contents",
            commit = "/commit/{commit}",
          },
        },
      },
    },
  },
}
