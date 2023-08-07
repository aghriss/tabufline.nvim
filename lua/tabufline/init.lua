-- TabDeb = true
TabDeb = false
Pr = function(item)
	if TabDeb then print(vim.inspect(item)) end
end
local C = require("tabufline.controls")
local U = require("tabufline.utils")
local config = require("tabufline.config")
local api = vim.api
local M = {}

-- closes all bufs except current one
M.setup = function(opts)
	Pr("setting up tabufline")
	Tabufline.opts = U.merge_tb(config.defaults, opts or Tabufline.opts)
	local listed_bufs = {}

	for _, val in ipairs(api.nvim_list_bufs()) do
		if U.buf_is_valid(val) then table.insert(listed_bufs, val) end
	end
	vim.t.tabufs = listed_bufs

	api.nvim_create_autocmd({ "BufAdd", "BufEnter" }, {
		callback = function(args)
			Pr("Before vim.t.tabufs: " .. vim.inspect(vim.t.tabufs))
			Pr(args)
			Pr("Buf valid:" .. vim.inspect(U.buf_is_valid(args.buf)))
      Pr("Current window" .. api.nvim_get_current_win())
			if U.buf_is_valid(args.buf) then
				C.add_buffer(args.buf)
				-- end
				-- if args.event == "BufAdd" then
				Pr("Delete empty if can")
				C.delete_empty(args.buf)
			end
      C.set_filenames()
			Pr("After vim.t.tabufs: " .. vim.inspect(vim.t.tabufs))
		end,
	})

	api.nvim_create_autocmd({ "BufDelete" }, {
		callback = function(args)
			Pr(args)
			Pr("Before vim.t.tabufs: " .. vim.inspect(vim.t.tabufs))
      Pr("Current window" .. api.nvim_get_current_win())
			C.delete_buffer(args.buf)
			Pr("After vim.t.tabufs: " .. vim.inspect(vim.t.tabufs))
		end,
	})

	-- require("core.utils").load_mappings("tabufline")

	-- if Tabufline.opts.lazyload then
	-- 	-- if a new buffer, new file, read buffer, or entering a new tab, new term
	-- 	api.nvim_create_autocmd(
	-- 		{ "BufNew", "BufNewFile", "BufRead", "TabEnter", "TermOpen" },
	-- 		{
	-- 			-- applies to all files
	-- 			pattern = "*",
	-- 			-- identify this by the autocommand group TabuflineLazyLoad
	-- 			group = api.nvim_create_augroup("TabuflineLazyLoad", {}),
	-- 			-- call this function when the events are detected
	-- 			callback = function()
	-- 				-- if we have more that one buf visible or move than 1 tabpage
	-- 				if
	-- 					#vim.fn.getbufinfo({ buflisted = 1 }) >= 2
	-- 					or #api.nvim_list_tabpages() >= 2
	-- 				then
	-- 					-- show tab page labels, 0: never, 1: if > 1, 2: always
	-- 					vim.opt.showtabline = 2
	-- 					vim.opt.tabline = "%!v:lua.require('tabufline.themes."
	-- 						.. opts.style
	-- 						.. "').run()"
	-- 					-- delete the augroup when the tabline is displayed
	-- 					api.nvim_del_augroup_by_name("TabuflineLazyLoad")
	-- 				end
	-- 			end,
	-- 		}
	-- 	)
	-- els:qe
	-- show tab page labels, 0: never, 1: if > 1, 2: always
	vim.opt.showtabline = 2
	vim.opt.tabline = "%!v:lua.require('tabufline.themes."
		.. opts.theme
		.. "').run()"
	-- end
end

return M
