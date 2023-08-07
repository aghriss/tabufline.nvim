local api = vim.api
local fn = vim.fn
local M = {}

M.merge_tb = function(...) return vim.tbl_deep_extend("force", ...) end

M.buf_is_valid = function(bufnr)
	-- vim.bo: Get or set buffer-scoped, if bufnr not indexed, uses current buffer
	-- a buffer is valid if it still exists and is listed (not hidden)
	return api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

M.get_buf_index = function(bufnr)
	for i, value in ipairs(vim.t.tabufs) do
		if value == bufnr then return i end
	end
end

M.get_curbuf_index = function() return M.get_buf_index(api.nvim_get_current_buf()) end

M.get_buf_fname = function(bufnr)
	return fn.fnamemodify(api.nvim_buf_get_name(bufnr), ":t")
end

-- /a/b/c.d -> /a/b
M.get_buf_dirname = function(bufnr)
	return fn.fnamemodify(vim.fs.normalize(api.nvim_buf_get_name(bufnr)), ":p:h")
end

M.combine_hl = function(group1, group2)
	-- new highlight is Tbfline .. group1 .. group2
	-- get the fg color of group1
	local fg = fn.synIDattr(fn.synIDtrans(fn.hlID(group1)), "fg#")
	-- get the bg color of group2
	local bg = fn.synIDattr(fn.synIDtrans(fn.hlID(group2)), "bg#")
	-- create a new highlight group with fg=group1.fg and bg=group2.bg
	api.nvim_set_hl(0, "TbfLine" .. group1 .. group2, { fg = fg, bg = bg })
	return "%#" .. "TbfLine" .. group1 .. group2 .. "#"
end

M.get_tabs = function()
	local number_of_tabs = fn.tabpagenr("$")
	local tabs = {}
	if number_of_tabs > 1 then
		tabs.all = {}
		for i = 1, number_of_tabs, 1 do
			table.insert(tabs.all, vim.t[i].name or i)
			if i == fn.tabpagenr() then tabs.current = i end
		end
	end
	return tabs
end

M.get_file_icon = function(fname)
	local devicons_present, devicons = pcall(require, "nvim-web-devicons")
	local icon, icon_hl
	if devicons_present then
		icon, icon_hl = devicons.get_icon(fname, string.match(fname, "%a+$"))
	end
	if not icon then
		return {
			icon = Tabufline.opts.icons.default_file,
			highlight = "DevIconDefault",
		}
	end
	return { icon = icon, highlight = icon_hl }
end

M.get_buttons_width = function() -- close, theme toggle btn etc
	local width = 6
	if fn.tabpagenr("$") ~= 1 then
		width = width + ((3 * fn.tabpagenr("$")) + 2) + 10
		width = not vim.g.TbTabsToggled and 8 or width
	end
	return width
end

M.get_nvimtree_width = function()
	for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
		if vim.bo[api.nvim_win_get_buf(win)].ft == "NvimTree" then
			return api.nvim_win_get_width(win) + 1
		end
	end
	return 0
end

M.get_nvimtree_pad = function(side)
	-- local nvimtree_padding = "%#NvimTreeNormal#"
	if side == "right" then
		return ""
	else
		return string.rep(" ", M.get_nvimtree_width())
	end
end

-- vim.g.TbTabsToggled = 0

-- M.get_tabs = function()
-- local number_of_tabs =
-- local result = { num_tabs = fn.tabpagenr("$"), current_tab = fn.tabpagenr()}
-- return = { num_tabs = fn.tabpagenr("$"), current_tab = fn.tabpagenr()}
-- if result.num_of_tabs > 1 then
-- for i = 1, result.num_of_tabs, 1 do
-- local tab_hl = ((i == fn.tabpagenr()) and "%#TbLineTabOn# ")
-- or "%#TbLineTabOff# "
-- result = result .. ("%" .. i .. "@TbGotoTab@" .. tab_hl .. i .. " ")
-- result = (
-- i == fn.tabpagenr()
-- and result .. "%#TbLineTabCloseBtn#" .. "%@TbTabClose@󰅙 %X"
-- ) or result
-- end

-- local new_tabtn = "%#TblineTabNewBtn#" .. "%@TbNewTab@  %X"
-- local tabstoggleBtn = "%@TbToggleTabs@ %#TBTabTitle# TABS %X"

-- return vim.g.TbTabsToggled == 1
-- and tabstoggleBtn:gsub("()", { [36] = " " })
-- or new_tabtn .. tabstoggleBtn .. result
-- end
-- end

M.create_button = function(vim_cmd, lua_func, highlight_group, string)
	vim.cmd(
		"function! "
			.. vim_cmd
			.. "(a,b,c,d) \n lua "
			.. lua_func
			.. " \n endfunction"
	)
	return "%@" .. vim_cmd .. "@%#" .. highlight_group .. string .. "%X"
end
return M
