return {
  { -- Vim-go
    "fatih/vim-go",
    config = function()
      -- The lsp hover popup is soo much cooler with Noice
      vim.g.go_doc_keywordprg_enabled = 0

      vim.keymap.set("n", "<leader>Ga", "<cmd>GoAlternate<CR>", { desc = "Alternate between test and implementation" })
      vim.keymap.set("n", "<leader>Gt", "", { desc = "Test" })
      vim.keymap.set("n", "<leader>Gtp", "<cmd>GoTest<CR>", { desc = "Run the tests in the current package" })
      vim.keymap.set("n", "<leader>Gtf", "<cmd>GoTestFile<CR>", { desc = "Run the tests in the current file" })
      vim.keymap.set("n", "<leader>Gtt", "<cmd>GoTestFunc<CR>", { desc = "Run the test under the cursor" })
      vim.keymap.set("n", "<leader>Gc", "", { desc = "Coverage" })
      vim.keymap.set("n", "<leader>Gca", "<cmd>GoCoverage<CR>", { desc = "Show test coverage (all in file)" })
      vim.keymap.set("n", "<leader>Gcc", "<cmd>GoCoverageClear<CR>", { desc = "Clear test coverage" })
      vim.keymap.set("n", "<leader>Gct", function()
        -- Cheat and use the function Copilot found from vim-go
        local test = vim.fn["go#util#TestName"]()
        if not test or test == "" then
          vim.notify("No test found under cursor", vim.log.levels.WARN)
          return
        end

        -- Log the test name and command
        local cmd = string.format("GoCoverage -run ^%s$", test)
        print(string.format("[GoTestCoverage] Test name: %s", test))
        vim.cmd(cmd)
      end, { desc = "Show coverage for test under the cursor" })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
