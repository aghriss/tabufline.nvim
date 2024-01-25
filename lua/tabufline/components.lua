local C = require("tabufline.controls")
local U = require("tabufline.utils")
local api = vim.api
local fn = vim.fn
local M = {}

---- Styling
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
      -- result = result .. ("%" .. i .. "@TbGotoTab@" .. tab_hl .. i .. " ")
      -- result = (
      -- i == fn.tabpagenr()
      -- and result .. "%#TbfLineTabCloseBtn#"
      -- .. "%@TbTabClose@󰅙 %X" -- and result .. "%#TbfLineTabCloseBtn#" .. "%@TbTabClose@󰅙 %X"

      -- ) or result
    end

    -- local new_tabtn = "%#TblineTabNewBtn#" .. "%@TbNewTab@  %X"
    -- local tabstoggleBtn = "%@TbToggleTabs@ %#TBTabTitle# TABS %X"

    -- return vim.g.TbTabsToggled == 1 and tabstoggleBtn:gsub("()", { [36] = " " })
    -- or new_tabtn .. tabstoggleBtn .. result
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
  else
    local icon_hi = U.combine_hl(file_icon.highlight, "TbfLineBufOff")
    mod_flag = (mod_flag ~= "" and "%#TbfLineBufOffModified#" .. mod_flag .. " ")
      or " "
    return icon_hi
      .. file_icon.icon
      .. "%#TbfLineBufOff# "
      .. name
      .. mod_flag
      .. "%#TbfLineBufOff#"
  end
end
-------- components ------------------------------------------------------------
-- - U.getBtnsWidth()
M.list_buffers = function(tabpages_width)
  local buffers = {} -- buffersults
  local available_space = vim.o.columns - tabpages_width
  local current_buf = api.nvim_get_current_buf()
  local has_current = false -- have we seen current buffer yet?

  for _, bufnr in ipairs(vim.t.tabufs) do
    if U.isBufValid(bufnr) then
      if ((#buffers + 1) * 21) > available_space then
        if has_current then
          break
        end

        table.remove(buffers, 1)
      end

      has_current = (bufnr == current_buf and true) or has_current
      table.insert(buffers, styleBufferTab(bufnr))
    end
  end

  vim.g.visibuffers = buffers
  return table.concat(buffers) .. "%#TblineFill#" .. "%=" -- buffers + empty space
end

M.add_nvimtree_pad = function(tabline)
  local nvimtree_padding = "%#NvimTreeNormal#"
  if Tabufline.opts.nvimtree_side == "right" then
    return tabline .. nvimtree_padding
  else
    return nvimtree_padding .. string.rep(" ", U.get_nvimtree_width()) .. tabline
  end
end

M.run = function()
  local modules = M.list_buffers() .. (M.tablist() or "") .. M.buttons()
  return (vim.g.nvimtree_side == "left") and M.CoverNvimTree() .. modules
    or modules .. M.CoverNvimTree()
end

function M.get_filename(name, bufnr)
  -- check for same buffer names under different dirs
  for _, value in ipairs(vim.t.tabufs) do
    if buf_is_valid(value) then
      if
        name == fn.fnamemodify(api.nvim_buf_get_name(value), ":t")
        and value ~= bufnr
      then
        local other = {}
        for match in
          (vim.fs.normalize(api.nvim_buf_get_name(value)) .. "/"):gmatch(
            "(.-)" .. "/"
          )
        do
          table.insert(other, match)
        end

        local current = {}
        for match in
          (vim.fs.normalize(api.nvim_buf_get_name(bufnr)) .. "/"):gmatch(
            "(.-)" .. "/"
          )
        do
          table.insert(current, match)
        end

        name = current[#current]

        for i = #current - 1, 1, -1 do
          local value_current = current[i]
          local other_current = other[i]

          if value_current ~= other_current then
            if (#current - i) < 2 then
              name = value_current .. "/" .. name
            else
              name = value_current .. "/../" .. name
            end
            break
          end
        end
        break
      end
    end
  end

  -- padding around bufname; 24 = bufame length (icon + filename)
  local padding = (24 - #name - 5) / 2
  local maxname_len = 16

  name = (#name > maxname_len and string.sub(name, 1, 14) .. "..") or name
  name = (api.nvim_get_current_buf() == bufnr and "%#TbfLineBufOn# " .. name)
    or ("%#TbfLineBufOff# " .. name)

  return string.rep(" ", padding) .. icon .. name .. string.rep(" ", padding)
end

return M
-- local function add_fileInfo(name, bufnr)
-- local ficon = C.get_file_icon(name)

-- icon = (
-- api.nvim_get_current_buf() == bufnr and new_hl(icon_hl, "TbfLineBufOn") .. " " .. icon
-- or new_hl(icon_hl, "TbfLineBufOff") .. " " .. icon
-- )

-- check for same buffer names under different dirs
-- for _, value in ipairs(vim.t.tabufs) do
-- 	if isBufValid(value) then
-- 		if name == fn.fnamemodify(api.nvim_buf_get_name(value), ":t") and value ~= bufnr then
-- 			local other = {}
-- 			for match in (vim.fs.normalize(api.nvim_buf_get_name(value)) .. "/"):gmatch("(.-)" .. "/") do
-- 				table.insert(other, match)
-- 			end
--
-- 			local current = {}
-- 			for match in (vim.fs.normalize(api.nvim_buf_get_name(bufnr)) .. "/"):gmatch("(.-)" .. "/") do
-- 				table.insert(current, match)
-- 			end
--
-- 			name = current[#current]
--
-- 			for i = #current - 1, 1, -1 do
-- 				local value_current = current[i]
-- 				local other_current = other[i]
--
-- 				if value_current ~= other_current then
-- 					if (#current - i) < 2 then
-- 						name = value_current .. "/" .. name
-- 					else
-- 						name = value_current .. "/../" .. name
-- 					end
-- 					break
-- 				end
-- 			end
-- 			break
-- 		end
-- 	end
-- end
--
-- padding around bufname; 24 = bufame length (icon + filename)
-- local padding = (24 - #name - 5) / 2
-- local maxname_len = 16

-- name = (#name > maxname_len and string.sub(name, 1, 14) .. "..") or name
-- name = (api.nvim_get_current_buf() == bufnr and "%#TbfLineBufOn# " .. name) or ("%#TbfLineBufOff# " .. name)

-- return string.rep(" ", padding) .. icon .. name .. string.rep(" ", padding)
-- end
-- end
-- return M
----------- btn onclick functions ----------------------------------------------
--
-- vim.cmd(
-- 	"function! TbGoToBuf(bufnr,b,c,d) \n execute 'b'..a:bufnr \n endfunction"
-- )
--
-- vim.cmd([[
--    function! TbKillBuf(bufnr,b,c,d)
--         call luaeval('require("tabufline").close_buffer(_A)', a:bufnr)
--   endfunction]])
--
-- vim.cmd("function! TbNewTab(a,b,c,d) \n tabnew \n endfunction")
-- vim.cmd(
-- 	"function! TbGotoTab(tabnr,b,c,d) \n execute a:tabnr ..'tabnext' \n endfunction"
-- )
-- vim.cmd(
-- 	"function! TbTabClose(a,b,c,d) \n lua require('tabufline').closeAllBufs('closeTab') \n endfunction"
-- )
-- vim.cmd(
-- 	"function! TbToggleTabs(a,b,c,d) \n let g:TbTabsToggled = !g:TbTabsToggled | redrawtabline \n endfunction"
-- )
