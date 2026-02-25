-- go.nvim configuration

local go = give("go")
local groups = give("core.autocmds")

go.setup({
  goimports = "goimports",
  gofmt = "goimports",
  lsp_cfg = true,
  lsp_keymaps = false,
  lsp_codelens = true,
  dap_debug = true,
  dap_debug_keymap = false,
  textobjects = false,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Format Go files with goimports",
  group = groups.on_save,
  pattern = "*.go",
  callback = function()
    give("go.format").goimports()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Go.nvim keymaps",
  group = vim.api.nvim_create_augroup("go-maps", { clear = true }),
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function()
    local maps = {
      { "<leader>G?", "<cmd>GoCheat<CR>", "Show a Go cheat sheet in a new buffer" },
      { "<leader>Gp", "<cmd>GoProject<CR>", "Set up go.nvim project configuration" },
      { "<leader>Gh", "<cmd>GoDoc<CR>", "Show Go documentation for the symbol under the cursor" },
      { "<leader>Ghb", "<cmd>GoDocBrowser<CR>", "Open Go documentation for the symbol in a browser" },
      { "<leader>Gli", "<cmd>GoListImports<CR>", "List imports for the current Go file" },
      { "<leader>Gz", "<cmd>GoToggleInlay<CR>", "Toggle Go inlay hints" },

      { "<leader>Ga", "<cmd>GoAlt<CR>", "Open the alternate test/source file" },
      { "<leader>Gac", "<cmd>GoAlt!<CR>", "Create and open the alternate test/source file" },
      { "<leader>Gas", "<cmd>GoAltS<CR>", "Open the alternate file in a horizontal split" },
      { "<leader>Gasc", "<cmd>GoAltS!<CR>", "Create and open the alternate file in a split" },
      { "<leader>Gav", "<cmd>GoAltV<CR>", "Open the alternate file in a vertical split" },
      { "<leader>Gavc", "<cmd>GoAltV!<CR>", "Create and open the alternate file in a vertical split" },

      { "<leader>Gb", "<cmd>GoBuild<CR>", "Build the current Go package" },
      { "<leader>Gbd", "<cmd>GoBuild -g<CR>", "Build with debug flags" },
      { "<leader>Gg", "<cmd>GoGenerate<CR>", "Run go generate in the current package" },
      { "<leader>Gr", "<cmd>GoRun<CR>", "Run the current Go package" },
      { "<leader>Grf", "<cmd>GoRun -F<CR>", "Run the current Go package in a float" },
      { "<leader>Gm", "<cmd>GoMake<CR>", "Run go.nvim async make" },
      { "<leader>Gk", "<cmd>GoStop<CR>", "Stop the last go.nvim job" },
      { "<leader>Gxg", "<cmd>GoGet<CR>", "Run go get for the package under the cursor" },
      { "<leader>Gxt", "<cmd>GoTool<CR>", "Run a go tool subcommand" },
      { "<leader>GxT", "<cmd>GoTermClose<CR>", "Close the go.nvim floating terminal" },

      { "<leader>Gff", "<cmd>GoFmt<CR>", "Format the current buffer" },
      { "<leader>Gfi", "<cmd>GoImports<CR>", "Format and organize imports with goimports" },
      { "<leader>GfI", "<cmd>GoImport<CR>", "Run the legacy GoImport command" },
      { "<leader>Gfc", "<cmd>GoCodeLenAct<CR>", "Run the gopls codelens action" },

      { "<leader>Gvv", "<cmd>GoVet<CR>", "Run go vet on the current package" },
      { "<leader>Gvl", "<cmd>GoLint<CR>", "Run golangci-lint for the current package" },

      { "<leader>Gcc", "<cmd>GoCoverage<CR>", "Run test coverage for the current package" },
      { "<leader>Gct", "<cmd>GoCoverage -t<CR>", "Toggle coverage signs" },
      { "<leader>Gcr", "<cmd>GoCoverage -r<CR>", "Remove coverage signs from this buffer" },
      { "<leader>GcR", "<cmd>GoCoverage -R<CR>", "Remove coverage signs from all buffers" },
      { "<leader>Gcm", "<cmd>GoCoverage -m<CR>", "Show coverage metrics per function" },
      { "<leader>Gcf", "<cmd>GoCoverage -f<CR>", "Load a coverage profile file" },
      { "<leader>Gcp", "<cmd>GoCoverage -p<CR>", "Run coverage for the current package only" },

      { "<leader>Gtt", "<cmd>GoTest<CR>", "Run go test for all packages" },
      { "<leader>GtV", "<cmd>GoTest -v<CR>", "Run go test in verbose mode" },
      { "<leader>Gtn", "<cmd>GoTest -n<CR>", "Run the nearest test" },
      { "<leader>Gtf", "<cmd>GoTest -f<CR>", "Run tests in the current file" },
      { "<leader>Gtp", "<cmd>GoTest -p<CR>", "Run tests in the current package" },
      { "<leader>Gtx", "<cmd>GoTest -count=1<CR>", "Run tests without cached results" },
      { "<leader>Gts", "<cmd>GoTestSum<CR>", "Run tests with gotestsum" },
      { "<leader>Gtw", "<cmd>GoTestSum -w<CR>", "Run gotestsum in watch mode" },
      { "<leader>GtF", "<cmd>GoTestFunc<CR>", "Run tests for the function under the cursor" },
      { "<leader>GtS", "<cmd>GoTestSubCase<CR>", "Run the nearest table test case" },
      { "<leader>GtT", "<cmd>GoTestFile<CR>", "Run tests for the current file" },
      { "<leader>GtP", "<cmd>GoTestPkg<CR>", "Run tests for the current package" },
      { "<leader>Gta", "<cmd>GoAddTest<CR>", "Generate a test for the current function" },
      { "<leader>GtE", "<cmd>GoAddExpTest<CR>", "Generate tests for exported functions" },
      { "<leader>GtA", "<cmd>GoAddAllTest<CR>", "Generate tests for all functions" },

      { "<leader>Gxc", "<cmd>GoCmt<CR>", "Generate Go doc comments for the symbol" },
      { "<leader>Gxr", "<cmd>GoRename<CR>", "Rename the symbol under the cursor" },
      { "<leader>Gxi", "<cmd>GoIfErr<CR>", "Insert an if err != nil block" },
      { "<leader>Gxf", "<cmd>GoFillStruct<CR>", "Fill struct literal fields" },
      { "<leader>GxS", "<cmd>GoFillSwitch<CR>", "Fill switch cases" },
      { "<leader>Gxp", "<cmd>GoFixPlurals<CR>", "Fix plural function arguments" },
      { "<leader>GxR", "<cmd>GoGenReturn<CR>", "Generate return values for the call under the cursor" },
      { "<leader>GxM", "<cmd>Gomvp<CR>", "Rename a Go module path" },

      { "<leader>Gtg", "<cmd>GoAddTag<CR>", "Add struct tags" },
      { "<leader>Gte", "<cmd>GoEnum<CR>", "Generate a Go enum" },
      { "<leader>Gtr", "<cmd>GoRmTag<CR>", "Remove struct tags" },
      { "<leader>Gtc", "<cmd>GoClearTag<CR>", "Clear all struct tags" },
      { "<leader>Gtm", "<cmd>GoModifyTag<CR>", "Modify struct tags" },

      { "<leader>Gii", "<cmd>GoImpl<CR>", "Generate method stubs for an interface" },
      { "<leader>GiI", "<cmd>GoImplements<CR>", "Jump to interface implementations via gopls" },
      { "<leader>Gic", "<cmd>GoCodeAction<CR>", "Run a Go code action" },
      { "<leader>Gil", "<cmd>GoCodeLenAct<CR>", "Run the gopls codelens action" },
      { "<leader>Gip", "<cmd>GoPkgOutline<CR>", "Show symbols in the current package" },
      { "<leader>GiP", "<cmd>GoPkgSymbols<CR>", "List package symbols" },
      { "<leader>Gig", "<cmd>GoGCDetails<CR>", "Show gopls GC details" },
      { "<leader>GiL", "<cmd>GoListImports<CR>", "List imports for the current Go file" },

      { "<leader>GMt", "<cmd>GoModTidy<CR>", "Run go mod tidy" },
      { "<leader>GMi", "<cmd>GoModInit<CR>", "Run go mod init" },
      { "<leader>GMd", "<cmd>GoModDnld<CR>", "Run go mod download" },
      { "<leader>GMg", "<cmd>GoModGraph<CR>", "Show the go mod dependency graph" },
      { "<leader>GMv", "<cmd>GoModVendor<CR>", "Create a vendor directory" },
      { "<leader>GMy", "<cmd>GoModWhy<CR>", "Explain why a module is needed" },

      { "<leader>GUa", "<cmd>GoInstallBinaries<CR>", "Install all go.nvim tools" },
      { "<leader>GUu", "<cmd>GoUpdateBinaries<CR>", "Update all go.nvim tools" },
      { "<leader>GUb", "<cmd>GoInstallBinary<CR>", "Install a specific Go tool" },
      { "<leader>GUU", "<cmd>GoUpdateBinary<CR>", "Update a specific Go tool" },

      { "<leader>Gdd", "<cmd>GoDebug<CR>", "Start a Go debug session" },
      { "<leader>GdR", "<cmd>GoDebug -R<CR>", "Restart the Go debug session" },
      { "<leader>Gdp", "<cmd>GoDebug -p<CR>", "Debug the current package tests" },
      { "<leader>Gdn", "<cmd>GoDebug -n<CR>", "Debug the nearest test" },
      { "<leader>Gdt", "<cmd>GoDebug -t<CR>", "Debug the current test file" },
      { "<leader>Gds", "<cmd>GoDbgStop<CR>", "Stop the Go debug session" },
      { "<leader>Gdc", "<cmd>GoDbgContinue<CR>", "Continue the Go debug session" },
      { "<leader>Gdb", "<cmd>GoBreakToggle<CR>", "Toggle a breakpoint" },
      { "<leader>GdB", "<cmd>BreakCondition<CR>", "Set a conditional breakpoint" },
      { "<leader>Gdl", "<cmd>LogPoint<CR>", "Add a log point breakpoint" },
      { "<leader>GdL", "<cmd>GoBreakLoad<CR>", "Load saved breakpoints" },
      { "<leader>GdS", "<cmd>GoBreakSave<CR>", "Save current breakpoints" },
      { "<leader>Gdk", "<cmd>GoDbgKeys<CR>", "Show debug keymaps" },
      { "<leader>GdF", "<cmd>DapUiFloat<CR>", "Open a floating DAP UI window" },
      { "<leader>GdT", "<cmd>DapUiToggle<CR>", "Toggle the DAP UI" },
      { "<leader>Gdr", "<cmd>ReplRun<CR>", "Run the last DAP REPL command" },
      { "<leader>GdO", "<cmd>ReplOpen<CR>", "Open the DAP REPL" },
      { "<leader>GdE", "<cmd>ReplToggle<CR>", "Toggle the DAP REPL" },
      { "<leader>GdX", "<cmd>DapStop<CR>", "Stop the DAP session" },
      { "<leader>GdY", "<cmd>DapRerun<CR>", "Rerun the last DAP session" },
      { "<leader>GdC", "<cmd>GoCreateLaunch<CR>", "Create a launch.json config" },
      { "<leader>GdG", "<cmd>GoDbgConfig<CR>", "Open the launch.json config" },

      { "<leader>Ge", "<cmd>GoEnv<CR>", "Load environment variables for Go debugging" },
      { "<leader>Gj", "<cmd>GoJson2Struct<CR>", "Convert JSON to a Go struct" },
      { "<leader>Gn", "<cmd>GoNew<CR>", "Create a new Go file from a template" },
      { "<leader>Gw", "<cmd>GoWork<CR>", "Manage go.work workspace settings" },

      { "<leader>GXm", "<cmd>GoMockGen<CR>", "Generate mocks with mockgen" },
      { "<leader>GXv", "<cmd>GoVulnCheck<CR>", "Run govulncheck" },

      { "<leader>Gkg", "<cmd>Ginkgo<CR>", "Run a ginkgo command" },
      { "<leader>Gkf", "<cmd>GinkgoFile<CR>", "Run ginkgo for the current file" },
      { "<leader>GkF", "<cmd>GinkgoFunc<CR>", "Run ginkgo for the current function" },
    }

    for _, map in ipairs(maps) do
      vim.keymap.set("n", map[1], map[2], { desc = map[3], buffer = true, silent = true })
    end
  end,
})
