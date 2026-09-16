-- A live buffer in a centered reading window, with an opaque backdrop.
local M = {}
local api = vim.api
local sessions = {}
local group = api.nvim_create_augroup("reading-focus", { clear = true })

local function geometry()
  local columns = vim.o.columns
  local height = math.max(1, vim.o.lines - vim.o.cmdheight - 1)
  local width = math.min(130, columns)
  local margin = height > 2 and 1 or 0
  return {
    relative = "editor",
    row = margin,
    col = math.floor((columns - width) / 2),
    width = width,
    height = height - 2 * margin,
  }, {
    relative = "editor",
    row = 0,
    col = 0,
    width = columns,
    height = height,
  }
end

local function view(win)
  if api.nvim_win_is_valid(win) then
    return api.nvim_win_call(win, vim.fn.winsaveview)
  end
end

local function close(session, saved_view, return_to_source)
  if sessions[session.tab] ~= session or session.closing then
    return
  end
  saved_view = saved_view or view(session.win)
  if return_to_source == nil then
    return_to_source = api.nvim_get_current_win() == session.win
  end
  local same_buffer = not api.nvim_win_is_valid(session.win) or api.nvim_win_get_buf(session.win) == session.buf
  session.closing = true
  if api.nvim_win_is_valid(session.win) then
    -- Respect modified buffers if another buffer was opened inside the float.
    local ok, err = pcall(api.nvim_win_close, session.win, false)
    if not ok then
      session.closing = false
      vim.notify(err, vim.log.levels.WARN)
      return
    end
  end
  sessions[session.tab] = nil
  if api.nvim_win_is_valid(session.backdrop) then
    api.nvim_win_close(session.backdrop, true)
  end
  if api.nvim_win_is_valid(session.source) then
    if saved_view and same_buffer and api.nvim_win_get_buf(session.source) == session.buf then
      api.nvim_win_call(session.source, function()
        vim.fn.winrestview(saved_view)
      end)
    end
    if return_to_source and api.nvim_get_current_tabpage() == session.tab then
      api.nvim_set_current_win(session.source)
    end
  end
end

function M.toggle()
  local tab = api.nvim_get_current_tabpage()
  if sessions[tab] then
    close(sessions[tab])
    return
  end

  local source = api.nvim_get_current_win()
  local buf = api.nvim_get_current_buf()
  local saved_view = view(source)
  local reading, backdrop = geometry()
  local background = api.nvim_create_buf(false, true)
  vim.bo[background].bufhidden = "wipe"
  vim.bo[background].modifiable = false
  local function open(buffer, config, zindex, focusable)
    local win = api.nvim_open_win(
      buffer,
      false,
      vim.tbl_extend("force", config, {
        style = "minimal",
        border = "none",
        zindex = zindex,
        focusable = focusable,
        mouse = focusable,
      })
    )
    vim.w[win].reading_focus = true
    vim.wo[win].winhighlight = "Normal:Normal,NormalNC:Normal,NormalFloat:Normal,EndOfBuffer:Normal"
    vim.wo[win].winblend = 0
    vim.wo[win].signcolumn = "no"
    return win
  end

  local back = open(background, backdrop, 1, false)
  local win = open(buf, reading, 2, true)
  sessions[tab] = { tab = tab, source = source, buf = buf, win = win, backdrop = back }
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].colorcolumn = ""
  vim.wo[win].cursorcolumn = false
  vim.wo[win].statuscolumn = ""
  vim.wo[win].winbar = ""
  api.nvim_set_current_win(win)
  vim.fn.winrestview(saved_view)
end

api.nvim_create_autocmd("VimResized", {
  group = group,
  callback = function()
    local reading, backdrop = geometry()
    for _, session in pairs(sessions) do
      if api.nvim_win_is_valid(session.win) and api.nvim_win_is_valid(session.backdrop) then
        api.nvim_win_set_config(session.backdrop, backdrop)
        api.nvim_win_set_config(session.win, reading)
      end
    end
  end,
})

api.nvim_create_autocmd("WinEnter", {
  group = group,
  callback = function()
    local session = sessions[api.nvim_get_current_tabpage()]
    if not session or session.closing or api.nvim_win_get_config(0).relative ~= "" then
      return
    end
    -- Pickers and other popups can take focus. Returning to a regular split
    -- dismisses the backdrop rather than leaving the active cursor hidden.
    vim.schedule(function()
      if
        api.nvim_win_is_valid(session.win)
        and api.nvim_get_current_tabpage() == session.tab
        and api.nvim_win_get_config(0).relative == ""
      then
        close(session, nil, false)
      end
    end)
  end,
})

api.nvim_create_autocmd("WinClosed", {
  group = group,
  callback = function(args)
    local win = tonumber(args.match)
    for _, session in pairs(sessions) do
      if not session.closing and (win == session.win or win == session.backdrop) then
        local saved_view
        if api.nvim_win_is_valid(session.win) and api.nvim_win_get_buf(session.win) == session.buf then
          saved_view = view(session.win)
        end
        local return_to_source = api.nvim_get_current_win() == session.win
        -- Defer companion-window cleanup until Neovim finishes closing this one.
        vim.schedule(function()
          close(session, saved_view, return_to_source)
        end)
      end
    end
  end,
})

api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "TabClosed" }, {
  group = group,
  callback = function(args)
    for _, session in pairs(sessions) do
      if (args.event ~= "TabClosed" and args.buf == session.buf) or not api.nvim_tabpage_is_valid(session.tab) then
        vim.schedule(function()
          close(session)
        end)
      end
    end
  end,
})

api.nvim_create_user_command("FocusToggle", M.toggle, { desc = "Toggle centered reading window" })

return M
