local C = require("tabufline.components")
local Ctrl = require("tabufline.controls")
local M = {}
local function map(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
    t[k] = f(v)
  end
  return t
end
M.run = function()
  Ctrl.remove_invalid()
  local buffers = "%#TbfLineFill#  "
    .. table.concat(map(vim.t.tabufs, C.buffer_name), "")
  local tabs = C.list_tabs()
  local flat_buffers = buffers:gsub("%%#[^#]+#", "")
  local flat_tabs = tabs:gsub("%%#[^#]+#", "")
  local width = vim.fn.winwidth(0)
  local filled_region = 0
  for _ in
    string.gmatch(flat_buffers .. flat_tabs, "([%z\1-\127\194-\244][\128-\191]*)")
  do
    filled_region = filled_region + 1
  end
  Pr({ flat_buffers, string.len(flat_buffers) })
  Pr({ flat_tabs, string.len(flat_tabs) })
  return buffers .. string.rep(" ", width - filled_region) .. tabs
end

return M
