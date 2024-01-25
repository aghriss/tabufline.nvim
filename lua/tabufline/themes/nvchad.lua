local C = require("tabufline.components")
local M = {}

M.run = function()
	return "%#TbLineTabCloseBtn#" .."tabufline" .."%X"
	-- return C.add_nvimtree_pad() .. "%#TbfLineTabCloseBtn#" .. "tabufline %= right %= h"
end

return M
