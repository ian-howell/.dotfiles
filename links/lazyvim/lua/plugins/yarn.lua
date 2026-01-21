return {
  "retran/meow.yarn.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  config = function()
    require("meow.yarn").setup({
      mappings = {
        jump = "<CR>",
        toggle = "<Space>",
        expand = nil,
        expand_alt = nil,
        collapse = nil,
        collapse_alt = nil,
        quit = "q",
      },
      preview_context_lines = 30,
      window = {
        width = 0.9,
        height = 0.9,
        border = "rounded",
        preview_height_ratio = 0.5,
      },
    })

    local type_hierarchy_super = function()
      require("meow.yarn").open_tree("type_hierarchy", "supertypes")
    end

    local type_hierarchy_sub = function()
      require("meow.yarn").open_tree("type_hierarchy", "subtypes")
    end

    local call_hierarchy_callers = function()
      require("meow.yarn").open_tree("call_hierarchy", "callers")
    end

    local call_hierarchy_callees = function()
      require("meow.yarn").open_tree("call_hierarchy", "callees")
    end

    vim.keymap.set("n", "<leader>yt", type_hierarchy_sub, { desc = "Yarn: Type Hierarchy (Sub)" })
    vim.keymap.set("n", "<leader>yT", type_hierarchy_super, { desc = "Yarn: Type Hierarchy (Super)" })
    vim.keymap.set("n", "<leader>yC", call_hierarchy_callers, { desc = "Yarn: Call Hierarchy (Callers)" })
    vim.keymap.set("n", "<leader>yc", call_hierarchy_callees, { desc = "Yarn: Call Hierarchy (Callees)" })
  end,
}
