local C = require("tabufline.controls")
local U = require("tabufline.utils")
local api = vim.api
local fn = vim.fn
local M = {}

M.list_tabs = function()
  -- local result = { n_tabs = fn.tabpagenr("$"), current_tab = 1 }
  local num_tabpages = fn.tabpagenr("$")
  local result = ""
  local tab_hl
  local tab_name
  if num_tabpages > 1 then
    local current_tabpage = fn.tabpagenr()
    for i = 1, num_tabpages, 1 do
      tab_hl = (
        (i == current_tabpage and "%#TbfLineTabOn# ") or "%#TbfLineTabOff# "
      )
      tab_name = vim.t[U.get_tabpage_id(i)].name or i
      result = result .. tab_hl .. tab_name .. " "
    end
  end
  return result
end

M.buffer_name = function(nr)
  local buf_info = vim.t.tabuf_names[tostring(nr)] or {}
  if not buf_info then
    return ""
  end
  local name = buf_info.name
  local file_icon = U.get_file_icon(name)
  local mod_flag = (vim.bo[nr].modified and Tabufline.opts.icons.modified) or ""
  if buf_info.dirname ~= nil then
    name = buf_info.dirname .. "/" .. name
  end
  name = string.gsub(name, "/%?/", Tabufline.opts.icons.etc)
  -- color close btn for focused / hidden  buffers
  if nr == api.nvim_get_current_buf() then
    mod_flag = (mod_flag ~= "" and "%#TbfLineBufOnModified#" .. mod_flag .. " ")
      or " "
    local icon_hi = U.combine_hl(file_icon.highlight, "TbfLineBufOn")
    return "%#TbfLineBufOnEdge#"
      .. Tabufline.opts.icons.tab_edge.left
      .. icon_hi
      .. file_icon.icon
      .. "%#TbfLineBufOn# "
      .. name
      .. mod_flag
      .. "%#TbfLineBufOnEdge#"
      .. Tabufline.opts.icons.tab_edge.right
      .. " "
  else
    local icon_hi = U.combine_hl(file_icon.highlight, "TbfLineBufOff")
    mod_flag = (mod_flag ~= "" and "%#TbfLineBufOffModified#" .. mod_flag .. " ")
      or " "
    return icon_hi
      .. file_icon.icon
      .. "%#TbfLineBufOff# "
      .. name
      .. mod_flag
      .. "%#TbfLineFill#"
  end
end

return M
