local M = {}

M.open = function()
	-- get current word
	-- local currName = vim.fn.expand("<cword>") .. " "
	local currName = "" .. vim.api.nvim_get_current_tabpage() .. ""
	if vim.t.name then
		-- P("Changing name to current name")
		currName = vim.t.name
	end
	local bufnr = vim.api.nvim_create_buf(false, false)
	-- vim.fn.bufload(bufnr)
	-- P(currName)
	local win = require("plenary.popup").create(bufnr, {
		title = "Rename Tab",
		style = "minimal",
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		relative = "editor",
		borderhighlight = "RenamerBorder",
		titlehighlight = "RenamerTitle",
		focusable = true,
		width = 25,
		height = 1,
		-- line = "cursor+2",
		-- col = "cursor-1",
	})
	vim.fn.setline(".", currName)
	-- vim.cmd("$")
	-- vim.fn.setbufline(bufnr, ".", { currName })
	vim.cmd("normal w")
	vim.cmd("startinsert")
	vim.api.nvim_win_set_cursor(win, { 1, #currName })
	local map_opts = { noremap = true, silent = true }
	-- vim.api.nvim_buf_set_keymap(
	-- 0,
	-- "i",
	-- "<Esc>",
	-- "<cmd>stopinsert | q!<CR>",
	-- map_opts
	-- )
	vim.api.nvim_buf_set_keymap(
		0,
		"n",
		"<Esc>",
		"<cmd>stopinsert | q!<CR>",
		map_opts
	)

	vim.api.nvim_buf_set_keymap(
		0,
		"i",
		"<CR>",
		"<cmd>stopinsert | lua P('" .. currName .. "|" .. win .. "')<CR>",
		map_opts
	)
	vim.api.nvim_buf_set_keymap(
		0,
		"n",
		"<CR>",
		"<cmd>stopinsert | lua P('" .. currName .. "|" .. win .. "')<CR>",
		map_opts
	)
	-- vim.api.nvim_buf_set_keymap(
	-- 	0,
	-- 	"i",
	-- 	"<CR>",
	-- 	"<cmd>stopinsert | lua require('aghriss.utils.renamer').apply("
	-- 		.. currName
	-- 		.. ","
	-- 		.. win
	-- 		.. ")<CR>",
	-- 	map_opts
	-- )

	-- vim.api.nvim_buf_set_keymap(
	-- 	0,
	-- 	"n",
	-- 	"<CR>",
	-- 	"<cmd>stopinsert | lua require('aghriss.utils.renamer').apply("
	-- 		.. currName
	-- 		.. ","
	-- 		.. win
	-- 		.. ")<CR>",
	-- 	map_opts
	-- )
end

M.apply = function(curr, win)
	local newName = vim.trim(vim.fn.getline("."))
	vim.api.nvim_win_close(win, true)

	if #newName > 0 and newName ~= curr then
		local params = vim.lsp.util.make_position_params()
		params.newName = newName

		vim.lsp.buf_request(0, "textDocument/rename", params)
	end
end

return M
