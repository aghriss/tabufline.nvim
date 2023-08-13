local U = require("tabufline.utils")
local M = {}

M.buttons = function()
  local toggle_themeBtn = "%@TbToggle_theme@%#TbfLineThemeToggleBtn#"
    .. vim.g.toggle_theme_icon
    .. "%X"
  local CloseAllBufsBtn = "%@TbCloseAllBufs@%#TbfLineCloseAllBufsBtn#"
    .. " 󰅖 "
    .. "%X"
  return toggle_themeBtn .. CloseAllBufsBtn
end
function M.theme_toggle_btn(toggle_button)
  return U.create_button(
    "TbToggleTheme",
    "require('base46').toggle_theme()",
    "TbfLineThemeToggleBtn",
    toggle_button
  )
end

function M.close_all_btn()
  return U.create_button(
    "TbCloseAllBufs",
    "require('tabufline.controls').close_all_bufs()",
    "TbfLineCloseAllBufsBtn",
    "󰅖"
  )
end

return M
