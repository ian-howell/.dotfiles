-- Convenience function for adding VSCode keybindings
local function notify(cmd)
    return string.format("<cmd>call VSCodeNotify('%s')<cr>", cmd)
end

-- Same as above, but for visual mode
local function v_notify(cmd)
    return string.format("<cmd>call VSCodeNotifyVisual('%s', 1)<cr>", cmd)
end

-- Set leader key to space
vim.g.mapleader = ' '

-- Only source this file if we're in VSCode
local keymap = vim.api.nvim_set_keymap

-- TODO: figure out how to toggle the fun things in the "explorer". I probably
-- don't need git? But like, the "symbols" thing looks kinda cool...

-- File operations
keymap('n', '<leader>ff', notify('workbench.action.quickOpen'), { noremap = true, silent = true })
keymap('n', '<leader>fr', notify('workbench.action.quickOpenRecent'), { noremap = true, silent = true })

-- Open the explorer
keymap('n', '<leader>ue', notify('workbench.view.explorer'), { noremap = true, silent = true })
-- Open the search view
keymap('n', '<leader>us', notify('workbench.view.search'), { noremap = true, silent = true })
-- Open the source control view
keymap('n', '<leader>ug', notify('workbench.view.scm'), { noremap = true, silent = true })
-- Toggle the sidebar
keymap('n', '<leader>ub', notify('workbench.action.toggleSidebarVisibility'), { noremap = true, silent = true })
-- Toggle the auxiliary sidebar
keymap('n', '<leader>uB', notify('workbench.action.toggleAuxiliaryBar'), { noremap = true, silent = true })
-- Open Cline
-- TODO: Fix this.
keymap('n', '<leader>uc', notify('workbench.action.openCline'), { noremap = true, silent = true })

-- Panels and sidebars
keymap('n', '<leader>up', notify('workbench.action.togglePanel'), { noremap = true, silent = true })
-- Zoom and focus
keymap('n', '<leader>uz', notify('workbench.action.toggleZenMode'), { noremap = true, silent = true })

-- Window/Tab management
-- NOTE: ctrl-hjkl are already bound to navigate between splits in VSCode
-- Split window vertically
keymap('n', '\\', notify('workbench.action.splitEditor'), { noremap = true, silent = true })
-- Split window horizontally
keymap('n', '-', notify('workbench.action.splitEditorOrthogonal'), { noremap = true, silent = true })

-- Code actions
keymap('n', '<leader>ca', notify('editor.action.quickFix'), { noremap = true, silent = true })
keymap('v', '<leader>ca', v_notify('editor.action.quickFix'), { noremap = true, silent = true })
keymap('n', '<leader>cr', notify('editor.action.rename'), { noremap = true, silent = true })
keymap('n', '<leader>cf', notify('editor.action.formatDocument'), { noremap = true, silent = true })
keymap('v', '<leader>cf', v_notify('editor.action.formatSelection'), { noremap = true, silent = true })

-- Go to definition and references
keymap('n', 'gd', notify('editor.action.revealDefinition'), { noremap = true, silent = true })
keymap('n', 'gr', notify('editor.action.goToReferences'), { noremap = true, silent = true })
keymap('n', 'gI', notify('editor.action.goToImplementation'), { noremap = true, silent = true })
keymap('n', 'gy', notify('editor.action.goToTypeDefinition'), { noremap = true, silent = true })
keymap('n', 'K', notify('editor.action.showHover'), { noremap = true, silent = true })

-- Diagnostics
-- jump to next/previous diagnostic
keymap('n', '<leader>]d', notify('editor.action.marker.next'), { noremap = true, silent = true })
keymap('n', '<leader>[d', notify('editor.action.marker.prev'), { noremap = true, silent = true })
-- open the problems panel
keymap('n', '<leader>up', notify('workbench.view.problems'), { noremap = true, silent = true })

-- VSCode specific vim settings
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Clear search highlighting
keymap('n', '<leader>ur', '<cmd>nohlsearch<cr>', { noremap = true, silent = true })
