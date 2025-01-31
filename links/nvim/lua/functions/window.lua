-- Window resizing
--
-- :resize will first attempt to resize the current window by moving the bottom (or right) border. If that is
-- not possible, it will resize the window by moving the top (or left) border. This variable behavior is
-- pretty annoying, so the following implements a more consistent behavior by expanding the window in the
-- direction of the specified arrow key.

local M = {}

local function too_short(window_number)
  return vim.api.nvim_win_get_height(vim.fn.win_getid(window_number)) <= 2
end

local function too_narrow(window_number)
  return vim.api.nvim_win_get_width(vim.fn.win_getid(window_number)) <= 2
end

-- touches_top_edge returns true if the window touches the top edge of the screen.
function M.touches_top_edge(window_number)
  return vim.fn.winnr 'k' == window_number
end

-- touches_bottom_edge returns true if the window touches the bottom edge of the screen.
function M.touches_bottom_edge(window_number)
  return vim.fn.winnr 'j' == window_number
end

-- touches_left_edge returns true if the window touches the left edge of the screen.
function M.touches_left_edge(window_number)
  return vim.fn.winnr 'h' == window_number
end

-- touches_right_edge returns true if the window touches the right edge of the screen.
function M.touches_right_edge(window_number)
  return vim.fn.winnr 'l' == window_number
end

-- get_window_by_number returns the window handle for the specified window number.
function M.get_window_by_number(win_number)
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_get_number(win) == win_number then
      return win
    end
  end
  return nil
end

-- get_left_window returns the window handle for the window to the left of the current window.
-- It returns nil if there is no window to the left.
function M.get_left_window()
  if M.touches_left_edge(vim.api.nvim_win_get_number(0)) then
    return nil
  end
  return M.get_window_by_number(vim.fn.winnr 'h')
end

-- get_right_window returns the window handle for the window to the right of the current window.
-- It returns nil if there is no window to the right.
function M.get_right_window()
  if M.touches_right_edge(vim.api.nvim_win_get_number(0)) then
    return nil
  end
  return M.get_window_by_number(vim.fn.winnr 'l')
end

-- get_above_window returns the window handle for the window above the current window.
-- It returns nil if there is no window above.
function M.get_above_window()
  if M.touches_top_edge(vim.api.nvim_win_get_number(0)) then
    return nil
  end
  return M.get_window_by_number(vim.fn.winnr 'k')
end

-- get_below_window returns the window handle for the window below the current window.
-- It returns nil if there is no window below.
function M.get_below_window()
  if M.touches_bottom_edge(vim.api.nvim_win_get_number(0)) then
    return nil
  end
  return M.get_window_by_number(vim.fn.winnr 'j')
end

-- expand_up expands the window upwards by one line.
-- If it can't expand the window, it returns false.
function M.expand_up(window_number, depth)
  local current_win_number = window_number or vim.api.nvim_win_get_number(0)
  depth = depth or 1
  local above_win_number = vim.fn.winnr(depth .. 'k')
  if current_win_number == above_win_number then
    -- This window is at the top edge, so it can't be expanded
    return false
  end
  -- If the window above the current window is too small, expand it first
  if too_short(above_win_number) then
    if not M.expand_up(above_win_number, depth + 1) then
      -- The window above can't be expanded, so the current window can't be expanded either
      return false
    end
  end
  vim.cmd(above_win_number .. 'resize -1')
  return true
end

-- expand_down expands the window downwards by one line.
-- If it can't expand the window, it returns false.
function M.expand_down(window_number, depth)
  local current_win_number = window_number or vim.api.nvim_win_get_number(0)
  depth = depth or 1
  local below_win_number = vim.fn.winnr(depth .. 'j')
  if current_win_number == below_win_number then
    -- This window is at the bottom edge, so it can't be expanded
    return false
  end
  -- If the window below the current window is too small, expand it first
  if too_short(below_win_number) then
    if not M.expand_down(below_win_number, depth + 1) then
      -- The window below can't be expanded, so the current window can't be expanded either
      return false
    end
  end
  vim.cmd(current_win_number .. 'resize +1')
  return true
end

-- expand_left expands the window to the left by one column.
-- If it can't expand the window, it returns false.
function M.expand_left(window_number, depth)
  local current_win_number = window_number or vim.api.nvim_win_get_number(0)
  depth = depth or 1
  local left_win_number = vim.fn.winnr(depth .. 'h')
  if current_win_number == left_win_number then
    -- This window is at the left edge, so it can't be expanded
    return false
  end
  -- If the window to the left of the current window is too narrow, expand it first
  if too_narrow(left_win_number) then
    if not M.expand_left(left_win_number, depth + 1) then
      -- The window to the left can't be expanded, so the current window can't be expanded either
      return false
    end
  end
  vim.cmd('vertical ' .. left_win_number .. 'resize -1')
  return true
end

-- expand_right expands the window to the right by one column.
-- If it can't expand the window, it returns false.
function M.expand_right(window_number, depth)
  local current_win_number = window_number or vim.api.nvim_win_get_number(0)
  depth = depth or 1
  local right_win_number = vim.fn.winnr(depth .. 'l')
  if current_win_number == right_win_number then
    -- This window is at the right edge, so it can't be expanded
    return false
  end
  -- If the window to the right of the current window is too narrow, expand it first
  if too_narrow(right_win_number) then
    if not M.expand_right(right_win_number, depth + 1) then
      -- The window to the right can't be expanded, so the current window can't be expanded either
      return false
    end
  end
  vim.cmd('vertical ' .. current_win_number .. 'resize +1')
  return true
end

return M
