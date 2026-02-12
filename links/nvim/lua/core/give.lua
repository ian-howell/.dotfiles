-- Loud require wrapper for missing modules.

local M = {}

local last_win = nil
local last_buf = nil

local function wrap_lines(lines, max_width)
  local wrapped = {}
  for _, line in ipairs(lines) do
    local remaining = line
    while #remaining > max_width do
      wrapped[#wrapped + 1] = remaining:sub(1, max_width)
      remaining = remaining:sub(max_width + 1)
    end
    wrapped[#wrapped + 1] = remaining
  end
  return wrapped
end

local function loud_require_error(module_name, err)
  local lines = {
    "!!! MODULE LOAD FAILURE !!!",
    string.format("Module: %s", module_name),
    "",
    "Lua error:",
    tostring(err),
    "",
    "Fix it. You broke it. Own it.",
  }

  vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR, {
    title = "require() FAILED",
    timeout = 10000,
  })

  local chunks = {}
  for i, line in ipairs(lines) do
    chunks[#chunks + 1] = { line, "ErrorMsg" }
    if i < #lines then
      chunks[#chunks + 1] = { "\n", "None" }
    end
  end

  vim.api.nvim_echo(chunks, true, {})
  vim.cmd("redraw")

  if last_win and vim.api.nvim_win_is_valid(last_win) then
    vim.api.nvim_win_close(last_win, true)
  end
  if last_buf and vim.api.nvim_buf_is_valid(last_buf) then
    vim.api.nvim_buf_delete(last_buf, { force = true })
  end

  local columns = vim.o.columns
  local lines_count = vim.o.lines
  local max_width = math.max(20, columns - 6)
  local wrapped = wrap_lines(lines, max_width - 4)

  local width = 0
  for _, line in ipairs(wrapped) do
    width = math.max(width, #line)
  end
  width = math.min(max_width, width + 4)

  local height = math.min(lines_count - 4, #wrapped + 2)
  if height < 6 then
    height = math.min(lines_count - 2, #wrapped + 2)
  end

  last_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(last_buf, 0, -1, false, wrapped)
  vim.api.nvim_set_option_value("modifiable", false, { buf = last_buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = last_buf })
  vim.api.nvim_set_option_value("filetype", "give-error", { buf = last_buf })

  last_win = vim.api.nvim_open_win(last_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((lines_count - height) / 2) - 1),
    col = math.max(0, math.floor((columns - width) / 2)),
    style = "minimal",
    border = "double",
    noautocmd = true,
  })
  vim.api.nvim_set_option_value("wrap", true, { win = last_win })
  vim.api.nvim_set_option_value("winhl", "Normal:ErrorMsg,FloatBorder:ErrorMsg", { win = last_win })
end

function M.give(module_name)
  local ok, mod = pcall(require, module_name)
  if ok then
    return mod
  end

  loud_require_error(module_name, mod)
  return nil
end

_G.give = M.give

return M
