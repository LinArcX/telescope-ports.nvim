local themes = require("telescope.themes")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

local port = 0

function themes.vscode(opts)
  opts = opts or {}
  local theme_opts = {
    theme = "dropdown",
    results_title = false,
    sorting_strategy = "ascending",
    layout_strategy = "vertical",
    layout_config = {
      anchor = "N",
      prompt_position = "top",
      width = function(_, max_columns, _)
        return math.min(max_columns, 120)
      end,
      height = function(_, _, max_lines)
        return math.min(max_lines, 15)
      end,
    },
  }
  if opts.layout_config and opts.layout_config.prompt_position == "bottom" then
    theme_opts.borderchars = {
      prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      results = { "─", "│", "─", "│", "╭", "╮", "┤", "├" },
      preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    }
  end
  return vim.tbl_deep_extend("force", theme_opts, opts)
end

local function isempty(s)
  return s == nil or s == ""
end

local function split(pString, pPattern)
  local Table = {}
  local fpat = "(.-)" .. pPattern
  local last_end = 1
  local s, e, cap = pString:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(Table, cap)
    end
    last_end = e + 1
    s, e, cap = pString:find(fpat, last_end)
  end
  if last_end <= #pString then
    cap = pString:sub(last_end)
    table.insert(Table, cap)
  end
  return Table
end

local function prepare_output_table()
  local lines = {}
  local changes = vim.api.nvim_command_output(
    ":!sudo -A netstat -antp 2>/dev/null | awk '{print $1 \" \" $4 \" \" $5 \" \" $6 \" \" $7}'  | tail -n +3"
  )

  for change in changes:gmatch("[^\r\n]+") do
    local words = {}
    for i in string.gmatch(change, "%S+") do
      table.insert(words, i)
    end
    table.insert(lines, words)
  end

  table.remove(lines, 1)
  return lines
end

local function on_event(job_id, data, event)
  local has_error = false

  if event == "stderr" then
    local lines = { "" }
    local error_lines = ""
    vim.list_extend(lines, data)

    for i = 1, #lines do
      if not isempty(lines[i]) then
        error_lines = error_lines .. "\n" .. lines[i]
        has_error = true
      end
    end

    if has_error then
      require("notify").notify(error_lines, "ERROR", { title = "ERROR", timeout = 500 })
    else
      local successful_message = string.format("port '%d' killed successfully :)", port)
      require("notify").notify(successful_message, "INFO", { title = "SUCCESS", timeout = 500 })
    end
  end
end

local function kill_port(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  if selection.value == "" then
    return
  end

  port = split(selection.value[5], "/")[1]
  print(port)
  local command = "sudo -A kill -9 " .. port

  vim.fn.jobstart(
    command,
    { on_stderr = on_event, on_stdout = on_event, on_exit = on_event, stdout_buffered = true, stderr_buffered = true }
  )
end

local function show_changes(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Ports",
    finder = finders.new_table({
      results = prepare_output_table(),
      entry_maker = function(entry)
        local columns = vim.o.columns
        local width = conf.width
          or conf.layout_config.width
          or conf.layout_config[conf.layout_strategy].width
          or columns
        local telescope_width
        if width > 1 then
          telescope_width = width
        else
          telescope_width = math.floor(columns * width)
        end
        local protocol_width = 5
        local local_address_width = 20
        local foreign_address_width = 20
        local state_width = 15

        local displayer = entry_display.create({
          separator = " ▏",
          items = {
            { width = protocol_width },
            { width = local_address_width },
            { width = foreign_address_width },
            { width = state_width },
            { width = telescope_width - protocol_width - local_address_width - foreign_address_width - state_width },
            { remaining = true },
          },
        })

        local function make_display()
          return displayer({
            { entry[1] },
            { entry[2] },
            { entry[3] },
            { entry[4] },
            { entry[5] },
          })
        end

        return {
          value = entry,
          display = make_display,
          ordinal = string.format("%s %s %s %s %s", entry[1], entry[2], entry[3], entry[4], entry[5]),
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      map("n", "<c-k>", kill_port)
      map("i", "<c-k>", kill_port)
      return true
    end,
  }):find()
end

local function run()
  show_changes(require("telescope.themes").vscode({}))
end

return require("telescope").register_extension({
  exports = {
    -- Default when to argument is given, i.e. :Telescope changes
    ports = run,
  },
})
