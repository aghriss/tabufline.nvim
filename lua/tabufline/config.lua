if not Tabufline then Tabufline = {
  buffers = {},
  opts = {},
} end
return {
  defaults = {
    -- theme = "nvchad",
    theme = "cat",
    lazyload = true,
    max_filename_len = 16,
    show_parent = true,
    filename_sep_l = "|",
    filename_sep_r = "|",
    show_tabs_toggle = true,
    nvimtree_side = "left",
    icons = {
      tab_edge = {left = "", right= ""},
      -- tab_edge = {left = " ", right= ""},
      -- tab_edge = {left = "", right= ""},
      -- tab_edge = { left = " ", right = "" },
      etc = "󰇘",
      modified = "",
      default_file = "󰈚",
      toggle_theme = " ",
      close_tab = "󰅙",
      -- path_fill = "",
      -- path_fill = "",
      -- path_fill = "",
      close_allbufs = "",
      close_buf = "",
      add_tab = "",
    },
  },
}
