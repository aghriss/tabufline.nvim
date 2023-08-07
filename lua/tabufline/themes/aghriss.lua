local C = require("tabufline.components")
local Ctrl = require("tabufline.controls")
local M = {}
local name = "Ghriss"
local function map(tbl, f)
	local t = {}
	for k, v in pairs(tbl) do
		t[k] = f(v)
	end
	return t
end
M.run = function()
	-- return "%#TbLineTabCloseBtn#" .."tabufline" .."%X"
	-- return C.add_nvimtree_pad(
  Ctrl.remove_invalid()
	return "%#TbfLineFill#   " .. table.concat(map(vim.t.tabufs, C.buffer_name), "")
		.. "%#TbfLineBufOff#"
		.. "%="
		.. name
		.. "%="
		.. "tabs"
end

return M
