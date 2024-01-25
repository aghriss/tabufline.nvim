local api = vim.api
local U = require("tabufline.utils")
local M = {}

-- local function swap_buf(step)
-- 	-- swap curbuf.idx and curbuf.idx + step
-- 	local bufs = vim.t.tabufs
-- 	-- local curbuf_idx = get_curbuf_index()
--
-- 	for buf_idx, bufnr in ipairs(bufs) do
-- 		if bufnr == vim.api.nvim_get_current_buf() then
-- 			if step < 0 and buf_idx == 1 or step > 0 and buf_idx == #bufs then
-- 				bufs[1], bufs[#bufs] = bufs[#bufs], bufs[1]
-- 			else
-- 				bufs[buf_idx], bufs[buf_idx + step] = bufs[buf_idx + step], bufs[buf_idx]
-- 			end
--
-- 			break
-- 		end
-- 	end
-- 	vim.t.tabufs = bufs
-- 	vim.cmd("redrawtabline")
-- end

-- Buffers are validatec before being added to vim.t.tabufs
-- local filter_valid_bufs = function()
-- 	local bufs = vim.t.tabufs or {}
--
-- 	for i, nr in ipairs(bufs) do
-- 		if not vim.api.nvim_buf_is_valid(nr) then
-- 			table.remove(bufs, i)
-- 		end
-- 	end
-- 	vim.t.tabufs = bufs
-- 	return bufs
-- end
-- closes tab + all of its buffers
--

function M.close_buf(bufnr)
  if vim.bo.buftype == "terminal" then
    vim.cmd(vim.bo.buflisted and "set nobl | enew" or "hide")
  else
    -- if bufnr is nil use curbuf
    bufnr = bufnr or api.nvim_get_current_buf()
    local buf_idx = U.get_buf_index(bufnr)

    local bufhidden = vim.bo.bufhidden

    -- force close floating wins
    if bufhidden == "wipe" then
      vim.cmd("bw")
      return

    -- handle listed bufs
    elseif buf_idx and #vim.t.tabufs > 1 then -- there is more than 1 buffer
      -- move to the left if bufnr is the last, to the right otherwise
      local newbuf_idx = buf_idx == #vim.t.tabufs and -1 or 1
      vim.cmd("b" .. vim.t.tabufs[buf_idx + newbuf_idx])

    -- handle unlisted
    elseif not vim.bo.buflisted then
      -- move to the first buffer and delete bufnr
      vim.cmd("b" .. vim.t.tabufs[1] .. " | bw" .. bufnr)
      return
    else
      vim.cmd("enew")
    end

    if not (bufhidden == "delete") then
      vim.cmd("confirm bd" .. bufnr)
    end
  end
  M.set_all_filenames()
  vim.cmd("redrawtabline")
end

function M.close_other_bufs()
  for _, buf in ipairs(vim.t.tabufs) do
    if buf ~= api.nvim_get_current_buf() then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
  M.set_all_filenames()
  vim.cmd("redrawtabline")
end

function M.close_curbuf()
  M.close_buf() -- api.nvim_get_current_buf())
end

M.close_all_bufs = function(action)
  local bufs = vim.t.tabufs

  if action == "closeTab" then
    vim.cmd("tabclose")
  end

  for _, buf in ipairs(bufs) do
    M.close_buf(buf)
  end

  if action ~= "closeTab" then
    vim.cmd("enew")
  end
end

M.delete_empty = function(new_buf)
  local bufs = vim.t.tabufs
  -- local first_buf = vim.t.tabufs[1]
  for i, bufnr in ipairs(bufs) do
    if bufnr ~= new_buf then
      if
        #api.nvim_buf_get_name(bufnr) == 0
        and not api.nvim_buf_get_option(bufnr, "modified")
      then
        table.remove(bufs, i)
        M.close_buf(bufnr)
      end
    end
  end
  vim.t.tabufs = bufs
end

M.delete_buffer = function(buf)
  for _, tabnr in ipairs(api.nvim_list_tabpages()) do
    local bufs = vim.t[tabnr].tabufs
    if bufs then
      for i, bufnr in ipairs(bufs) do
        if bufnr == buf then
          table.remove(bufs, i)
          vim.t[tabnr].tabufs = bufs
          M.set_filenames(tabnr)
          break
        end
      end
    end
  end
end
M.remove_invalid = function()
  local bufs = vim.t.tabufs
  local flag = false
  for i, bufnr in ipairs(bufs) do
    if not U.buf_is_valid(bufnr) then
      table.remove(bufs, i)
      flag = true
    end
  end
  if flag then
    M.set_all_filenames()
    vim.t.tabufs = bufs
  end
end

-- move buf by number of steps, <0 left, >0 right
local function move_to_buf(step)
  -- jump buffers by step, <0 to the left, > 0 to the right
  -- local bufs = filter _valid_bufs()
  local bufs = vim.t.tabufs
  local cur_buf_idx = U.get_curbuf_index()
  -- idx always between 1 and #bufs, if exceeds, cycle
  local goto_buf_idx = (cur_buf_idx + step - 1) % #bufs + 1
  -- go to the first buffer if current buffer is invalid
  Pr("start move_to")
  Pr(bufs)
  Pr(step)
  Pr(goto_buf_idx)
  Pr(bufs[goto_buf_idx])
  Pr("end move_to")
  local cmd = "b" .. bufs[goto_buf_idx]
  Pr(cmd)
  vim.cmd("b" .. bufs[goto_buf_idx])
end

function M.next_buffer()
  move_to_buf(1)
end

function M.prev_buffer()
  move_to_buf(-1)
end

M.set_filenames = function(tabpage_id)
  local fname
  local fname_to_buf = {}
  local empty_count = 0
  tabpage_id = tabpage_id or U.get_tabpage_id()

  local buf_names = vim.t[tabpage_id].tabuf_names or {}
  -- we want to map fname to buffer
  for _, buf in ipairs(vim.t[tabpage_id].tabufs) do
    fname = U.get_buf_fname(buf)
    if fname == "" then
      fname = "?"
        .. ((empty_count == 0 and "") or ("[" .. tostring(empty_count + 1)) .. "]")
      empty_count = empty_count + 1
    end
    if not buf_names[buf] then
      buf_names[tostring(buf)] = {}
    end
    if not fname_to_buf[fname] then
      fname_to_buf[fname] = {}
    end
    buf_names[tostring(buf)].name = fname
    table.insert(fname_to_buf[fname], buf)
    -- end
  end
  for _, bufs in pairs(fname_to_buf) do
    -- if fname has more than one buffer (duplicate fname)
    if vim.tbl_count(bufs) > 1 then
      -- map fname.buffers to their dirnames
      local buf_to_dir = {}
      for _, buf in ipairs(bufs) do
        buf_to_dir[buf] = U.get_buf_dirname(buf)
      end
      -- We will use tabufline.path to reduce the name
      local reduced_buf_dir = require("tabufline.path").reduce_paths(
        buf_to_dir,
        Tabufline.opts.show_parent
      )
      -- save our results in vim.t.bufnames
      for buf, dir in pairs(reduced_buf_dir) do
        buf_names[tostring(buf)].dirname = dir
      end
    end
  end
  vim.t[tabpage_id].tabuf_names = buf_names
end

M.set_all_filenames = function()
  for _, tabpage_id in ipairs(api.nvim_list_tabpages()) do
    M.set_filenames(tabpage_id)
  end
end

M.add_buffer = function(bufnr)
  local bufs = vim.t.tabufs or {}
  if not U.buf_is_valid(bufnr) then
    return
  end
  if not vim.tbl_contains(bufs, bufnr) then
    table.insert(bufs, bufnr)
  end
  vim.t.tabufs = bufs
  M.set_filenames()
end

return M
