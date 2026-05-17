local M = {}

local cache = {}

local required_env = {
  "ADO_REVIEW_ORG_URL",
  "ADO_REVIEW_PROJECT",
  "ADO_REVIEW_REPOSITORY_ID",
  "ADO_REVIEW_REPO_NAME",
  "ADO_REVIEW_PR_ID",
  "ADO_REVIEW_PR_URL",
  "ADO_REVIEW_ITERATION_ID",
  "ADO_REVIEW_ITERATION_TARGET_COMMIT",
  "ADO_REVIEW_ITERATION_SOURCE_COMMIT",
}

local function env(name)
  local value = vim.env[name]
  if value == nil or value == "" then
    return nil
  end
  return value
end

local function has_review_env()
  for _, name in ipairs(required_env) do
    if not env(name) then
      return false
    end
  end
  return true
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "ADO PR comment" })
end

local function fail(message)
  notify(message, vim.log.levels.ERROR)
end

local function system_json(args, opts)
  opts = opts or {}
  local result = vim.system(args, { text = true }):wait()
  if result.code ~= 0 then
    local stderr = vim.trim(result.stderr or "")
    return nil, stderr ~= "" and stderr or (opts.error or "command failed")
  end

  local ok, decoded = pcall(vim.json.decode, result.stdout or "")
  if not ok then
    return nil, "could not parse Azure DevOps response"
  end

  return decoded, nil
end

local function az_invoke(args)
  local command = { "az", "devops", "invoke", "--only-show-errors" }
  vim.list_extend(command, args)
  return system_json(command)
end

local function ensure_context()
  if not has_review_env() then
    return nil, "Not in an ADO review session"
  end

  return {
    org_url = env("ADO_REVIEW_ORG_URL"),
    project = env("ADO_REVIEW_PROJECT"),
    repository_id = env("ADO_REVIEW_REPOSITORY_ID"),
    repo_name = env("ADO_REVIEW_REPO_NAME"),
    pr_id = env("ADO_REVIEW_PR_ID"),
    pr_url = env("ADO_REVIEW_PR_URL"),
    iteration_id = env("ADO_REVIEW_ITERATION_ID"),
    iteration_target_commit = env("ADO_REVIEW_ITERATION_TARGET_COMMIT"),
    iteration_source_commit = env("ADO_REVIEW_ITERATION_SOURCE_COMMIT"),
  },
    nil
end

local function route_args(ctx, resource, extra_route_parameters)
  return {
    "--area",
    "git",
    "--resource",
    resource,
    "--route-parameters",
    "project=" .. ctx.project,
    "repositoryId=" .. ctx.repository_id,
    "pullRequestId=" .. ctx.pr_id,
    unpack(extra_route_parameters or {}),
    "--org",
    ctx.org_url,
    "--api-version",
    "7.1",
  }
end

local function latest_iteration(ctx)
  local key = ctx.org_url .. "\0" .. ctx.project .. "\0" .. ctx.repository_id .. "\0" .. ctx.pr_id
  cache[key] = cache[key] or {}
  if cache[key].iteration then
    return cache[key].iteration, nil
  end

  local args = route_args(ctx, "pullRequestIterations")
  vim.list_extend(args, {
    "--query",
    "value[-1].{id:id,sourceRefCommit:sourceRefCommit.commitId,targetRefCommit:targetRefCommit.commitId}",
    "-o",
    "json",
  })

  local data, err = az_invoke(args)
  if err then
    return nil, err
  end
  if not data or not data.id then
    return nil, "could not determine latest PR iteration"
  end

  if
    tostring(data.id) ~= tostring(ctx.iteration_id)
    or data.sourceRefCommit ~= ctx.iteration_source_commit
    or data.targetRefCommit ~= ctx.iteration_target_commit
  then
    return nil, "PR has changed since this review opened; rerun review before commenting"
  end

  cache[key].iteration = data
  return data, nil
end

local function iteration_changes(ctx, iteration_id)
  local key = ctx.org_url
    .. "\0"
    .. ctx.project
    .. "\0"
    .. ctx.repository_id
    .. "\0"
    .. ctx.pr_id
    .. "\0"
    .. iteration_id
  cache[key] = cache[key] or {}
  if cache[key].changes then
    return cache[key].changes, nil
  end

  local args = route_args(ctx, "pullRequestIterationChanges", { "iterationId=" .. tostring(iteration_id) })
  vim.list_extend(args, {
    "--query",
    "changeEntries[].{path:item.path,originalPath:originalPath,changeTrackingId:changeTrackingId,changeType:changeType}",
    "-o",
    "json",
  })

  local data, err = az_invoke(args)
  if err then
    return nil, err
  end

  cache[key].changes = data or {}
  return cache[key].changes, nil
end

local function normalize_path(path)
  if type(path) ~= "string" or path == "" then
    return nil
  end
  if vim.startswith(path, "/") then
    return path
  end
  return "/" .. path
end

local function find_change_tracking_id(changes, path)
  local normalized = normalize_path(path)
  for _, change in ipairs(changes) do
    if normalize_path(change.path) == normalized or normalize_path(change.originalPath) == normalized then
      return change.changeTrackingId
    end
  end
  return nil
end

local function current_session()
  local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
  if not ok then
    return nil, "CodeDiff is not available"
  end

  local session = lifecycle.get_session(vim.api.nvim_get_current_tabpage())
  if not session then
    return nil, "Not in an ADO review session"
  end
  return session, nil
end

local function selection_side_and_path(session)
  local bufnr = vim.api.nvim_get_current_buf()
  if bufnr == session.original_bufnr then
    return "left", normalize_path(session.original_path), nil
  end
  if bufnr == session.modified_bufnr then
    return "right", normalize_path(session.modified_path), nil
  end
  return nil, nil, "Cursor is not in a CodeDiff file pane"
end

local function line_length_chars(bufnr, line)
  local text = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1] or ""
  return vim.fn.strchars(text)
end

local function byte_col_to_char_offset(text, byte_col)
  if byte_col <= 1 then
    return 1
  end
  local prefix = string.sub(text, 1, byte_col - 1)
  return vim.fn.strchars(prefix) + 1
end

local function line_context(line)
  local len = line_length_chars(vim.api.nvim_get_current_buf(), line)
  return {
    start_line = line,
    start_offset = 1,
    end_line = line,
    end_offset = len + 1,
  }
end

local function visual_context()
  local mode = vim.fn.visualmode()
  if mode == "\22" then
    return nil, "Blockwise visual comments are not supported"
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  if mode == "V" then
    return {
      start_line = start_line,
      start_offset = 1,
      end_line = end_line,
      end_offset = line_length_chars(vim.api.nvim_get_current_buf(), end_line) + 1,
    },
      nil
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local start_text = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1] or ""
  local end_text = vim.api.nvim_buf_get_lines(bufnr, end_line - 1, end_line, false)[1] or ""

  return {
    start_line = start_line,
    start_offset = byte_col_to_char_offset(start_text, start_col),
    end_line = end_line,
    end_offset = byte_col_to_char_offset(end_text, end_col) + 1,
  },
    nil
end

local function char_offset_to_byte_index(text, offset)
  return vim.str_byteindex(text, math.max(offset - 1, 0))
end

local function range_text(bufnr, range)
  local lines = vim.api.nvim_buf_get_lines(bufnr, range.start_line - 1, range.end_line, false)
  if #lines == 0 then
    return {}
  end

  if #lines == 1 then
    local start_byte = char_offset_to_byte_index(lines[1], range.start_offset) + 1
    local end_byte = char_offset_to_byte_index(lines[1], range.end_offset)
    return { lines[1]:sub(start_byte, end_byte) }
  end

  local first_start = char_offset_to_byte_index(lines[1], range.start_offset) + 1
  lines[1] = lines[1]:sub(first_start)

  local last = lines[#lines]
  local last_end = char_offset_to_byte_index(last, range.end_offset)
  lines[#lines] = last:sub(1, last_end)

  return lines
end

local function suggestion_body(bufnr, range)
  local lines = { "```suggestion" }
  vim.list_extend(lines, range_text(bufnr, range))
  table.insert(lines, "```")
  return table.concat(lines, "\n")
end

local function make_thread_context(side, file_path, range)
  local point_start = { line = range.start_line, offset = range.start_offset }
  local point_end = { line = range.end_line, offset = range.end_offset }
  local context = { filePath = file_path }

  if side == "left" then
    context.leftFileStart = point_start
    context.leftFileEnd = point_end
    context.rightFileStart = vim.NIL
    context.rightFileEnd = vim.NIL
  else
    context.leftFileStart = vim.NIL
    context.leftFileEnd = vim.NIL
    context.rightFileStart = point_start
    context.rightFileEnd = point_end
  end

  return context
end

local function url_encode(value)
  return (value:gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

local function discussion_url(ctx, file_path, thread_id)
  return string.format("%s?_a=files&path=%s&discussionId=%s", ctx.pr_url, url_encode(file_path), tostring(thread_id))
end

local function post_comment(ctx, comment)
  local payload = {
    comments = {
      {
        parentCommentId = 0,
        content = comment.body,
        commentType = 1,
      },
    },
    status = 1,
    threadContext = make_thread_context(comment.side, comment.file_path, comment.range),
    pullRequestThreadContext = {
      changeTrackingId = comment.change_tracking_id,
      iterationContext = {
        firstComparingIteration = comment.iteration_id,
        secondComparingIteration = comment.iteration_id,
      },
    },
  }

  local payload_file = vim.fn.tempname() .. ".json"
  vim.fn.writefile({ vim.json.encode(payload) }, payload_file)

  local args = route_args(ctx, "pullRequestThreads")
  vim.list_extend(args, {
    "--http-method",
    "POST",
    "--in-file",
    payload_file,
  })

  local data, err = az_invoke(args)
  vim.fn.delete(payload_file)
  if err then
    return nil, "Could not create ADO PR comment: " .. err
  end
  if not data or not data.id then
    return nil, "Could not create ADO PR comment"
  end

  return data, nil
end

local function delete_file(path)
  if path and path ~= "" then
    vim.fn.delete(path)
  end
end

local function open_composer(ctx, comment)
  local width = math.min(100, math.max(60, math.floor(vim.o.columns * 0.7)))
  local height = math.min(24, math.max(8, math.floor(vim.o.lines * 0.35)))
  local row = math.max(0, math.floor((vim.o.lines - height) / 3))
  local col = math.max(0, math.floor((vim.o.columns - width) / 2))
  local title = string.format(
    " ADO PR #%s %s: %s:%d:%d-%d:%d ",
    ctx.pr_id,
    comment.side,
    comment.file_path,
    comment.range.start_line,
    comment.range.start_offset,
    comment.range.end_line,
    comment.range.end_offset
  )

  local temp_file = vim.fn.tempname() .. ".md"
  if comment.initial_body then
    vim.fn.writefile(vim.split(comment.initial_body, "\n", { plain = true }), temp_file)
  else
    vim.fn.writefile({}, temp_file)
  end

  local state = { aborted = false }

  local function open_window(bufnr)
    return vim.api.nvim_open_win(bufnr, true, {
      relative = "editor",
      row = row,
      col = col,
      width = width,
      height = height,
      style = "minimal",
      border = "rounded",
      title = title,
      title_pos = "center",
    })
  end

  local function attach(bufnr, winid)
    vim.bo[bufnr].bufhidden = "wipe"
    vim.bo[bufnr].filetype = "markdown"
    vim.bo[bufnr].swapfile = false

    vim.api.nvim_create_autocmd("WinClosed", {
      pattern = tostring(winid),
      once = true,
      callback = function()
        vim.schedule(function()
          if state.aborted then
            delete_file(temp_file)
            return
          end
          local lines = vim.fn.filereadable(temp_file) == 1 and vim.fn.readfile(temp_file) or {}
          local saved_body = table.concat(lines, "\n")
          local body = vim.trim(saved_body)
          if body == "" then
            delete_file(temp_file)
            return
          end

          comment.body = saved_body
          local created, err = post_comment(ctx, comment)
          if err then
            fail(err)
            return
          end

          delete_file(temp_file)
          notify("Created ADO PR comment: " .. discussion_url(ctx, comment.file_path, created.id))
        end)
      end,
    })
  end

  local bufnr = vim.fn.bufadd(temp_file)
  vim.fn.bufload(bufnr)
  local winid = open_window(bufnr)
  attach(bufnr, winid)

  vim.cmd.startinsert()
end

local function prepare_comment(mode, opts)
  opts = opts or {}
  local ctx, ctx_err = ensure_context()
  if ctx_err then
    fail(ctx_err)
    return
  end

  local session, session_err = current_session()
  if session_err then
    fail(session_err)
    return
  end

  if session.mode ~= "explorer" and session.mode ~= "file" then
    fail("Not in an ADO review session")
    return
  end

  local side, file_path, side_err = selection_side_and_path(session)
  if side_err then
    fail(side_err)
    return
  end
  if not side or not file_path then
    fail("Could not determine PR side for current buffer")
    return
  end

  local range, range_err
  if mode == "visual" then
    range, range_err = visual_context()
  else
    range = line_context(vim.api.nvim_win_get_cursor(0)[1])
  end
  if range_err then
    fail(range_err)
    return
  end

  local initial_body
  if opts.suggestion then
    if side ~= "right" then
      fail("ADO suggestions can only be created from the modified side of a diff")
      return
    end
    initial_body = suggestion_body(vim.api.nvim_get_current_buf(), range)
  end

  local iteration, iteration_err = latest_iteration(ctx)
  if iteration_err then
    fail(iteration_err)
    return
  end

  local changes, changes_err = iteration_changes(ctx, iteration.id)
  if changes_err then
    fail(changes_err)
    return
  end

  local change_tracking_id = find_change_tracking_id(changes, file_path)
  if not change_tracking_id then
    fail("File is not present in latest PR iteration changes: " .. file_path)
    return
  end

  open_composer(ctx, {
    side = side,
    file_path = file_path,
    range = range,
    iteration_id = iteration.id,
    change_tracking_id = change_tracking_id,
    initial_body = initial_body,
  })
end

local function map_buffer(bufnr)
  vim.keymap.set("n", "<leader>gc", function()
    prepare_comment("normal")
  end, { buffer = bufnr, desc = "ADO PR comment" })

  vim.keymap.set("v", "<leader>gc", function()
    vim.cmd.normal({ args = { "\27" }, bang = true })
    prepare_comment("visual")
  end, { buffer = bufnr, desc = "ADO PR comment" })

  vim.keymap.set("n", "<leader>gs", function()
    prepare_comment("normal", { suggestion = true })
  end, { buffer = bufnr, desc = "ADO PR suggestion" })

  vim.keymap.set("v", "<leader>gs", function()
    vim.cmd.normal({ args = { "\27" }, bang = true })
    prepare_comment("visual", { suggestion = true })
  end, { buffer = bufnr, desc = "ADO PR suggestion" })
end

function M.setup(tabpage)
  if not has_review_env() then
    return
  end

  local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
  if not ok then
    return
  end

  local session = lifecycle.get_session(tabpage)
  if not session then
    return
  end

  if session.original_bufnr and vim.api.nvim_buf_is_valid(session.original_bufnr) then
    map_buffer(session.original_bufnr)
  end
  if session.modified_bufnr and vim.api.nvim_buf_is_valid(session.modified_bufnr) then
    map_buffer(session.modified_bufnr)
  end
end

return M
