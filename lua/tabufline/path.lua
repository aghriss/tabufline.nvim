local M = {}

local function int_to_char(i) return string.char(i + 64) end

local function group_by_first(b_to_s)
  local starts = {}
  for b, s in pairs(b_to_s) do
    if #s == 0 then
      error("empty string in hash_by_first" .. vim.inspect(b_to_s))
    end
    local c = s:sub(1, 1)
    if starts[c] == nil then
      starts[c] = { b }
    else
      table.insert(starts[c], b)
    end
  end
  return starts
end

local function hash_paths(paths, node_to_char, char_to_node)
  local num_nodes = 1
  local buf_hash = {}
  local max_len = 0
  local r
  for buf, path in pairs(paths) do
    r = ""
    path = path .. "/"
    for m in path:gmatch("(.-)/") do
      if m ~= "" then
        if not node_to_char[m] then
          node_to_char[m] = int_to_char(num_nodes)
          char_to_node[int_to_char(num_nodes)] = m
          num_nodes = num_nodes + 1
        end
        r = node_to_char[m] .. r
      end
    end
    buf_hash[buf] = r
    max_len = math.max(#r, max_len)
  end
  for b, h in pairs(buf_hash) do
    buf_hash[b] = h .. string.rep(" ", max_len - #h)
  end
  return buf_hash
end

local function dehash(buf_hash, char_to_node)
  local buf_path = {}
  for b, h in pairs(buf_hash) do
    local rs = h:reverse()
    local p = {}
    for i = 1, #rs do
      if rs:sub(i, i) == "?" then
        table.insert(p, "?")
      else
        table.insert(p, char_to_node[rs:sub(i, i)])
      end
    end
    -- buf_path[b] = "/" .. table.concat(p, "/")
    buf_path[b] = table.concat(p, "/")
  end
  return buf_path
end

local function find_divergence(buf_hash, show_parent)
  local starts = group_by_first(buf_hash)
  local unique = { hash = {}, firsts = {} }
  for fr, bufs in pairs(starts) do
    table.insert(unique.firsts, fr)
    if #bufs == 1 then
      local b = bufs[1]
      unique.hash[b] = fr
    else
      local sub_buf_hash = {}
      for _, bf in ipairs(bufs) do
        sub_buf_hash[bf] = buf_hash[bf]:sub(2)
      end
      local sub_unique = find_divergence(sub_buf_hash)
      local pad = "?"
      -- if one of the group elements reached its end, we keep the last path
      if vim.tbl_contains(sub_unique.firsts, " ") or show_parent then pad = fr end
      -- we add the pad
      for b, u in pairs(sub_unique.hash) do
        if u:sub(1, 1) == " " then
          unique.hash[b] = pad
        else
          unique.hash[b] = pad .. u
        end
        unique.hash[b] = unique.hash[b]:gsub("?+", "?")
      end
    end
  end
  return unique
end

M.reduce_paths = function(paths, show_parent)
  local node_to_char, char_to_node = {}, {}
  local buf_hash = hash_paths(paths, node_to_char, char_to_node)
  local unique = find_divergence(buf_hash, show_parent)
  return dehash(unique.hash, char_to_node)
end

return M
