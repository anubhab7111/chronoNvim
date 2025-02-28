local M = {}

local json = vim.json or { -- Support for older Neovim versions
  encode = vim.fn.json_encode,
  decode = vim.fn.json_decode,
}

local chrono_file = vim.fn.stdpath("data") .. "/ChronoNvim.json" -- Save file

M.start_time = {}
M.total_time = {}
M.timer_active = {}

-- Convert seconds to HH:MM:SS format
local function format_time(seconds)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60
  return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Load saved time data from file safely
function M.load_time_data()
  local file = io.open(chrono_file, "r")
  if file then
    local content = file:read("*a")
    file:close()
    local success, data = pcall(json.decode, content)
    if success and type(data) == "table" then
      M.total_time = data
    else
      M.total_time = {}
    end
  else
    M.total_time = {}
    M.save_time_data() -- Ensure file is created on first run
  end
end

-- Save time data persistently
function M.save_time_data()
  local file = io.open(chrono_file, "w")
  if file then
    local success, encoded = pcall(json.encode, M.total_time)
    if success then
      file:write(encoded)
    else
      print("Error encoding JSON")
    end
    file:close()
  end
end

-- Start tracking time when buffer is entered
function M.start_timer()
  local bufname = vim.fn.expand("%:p") -- Get full file path
  if bufname == "" then return end
  if not M.timer_active[bufname] then
    M.start_time[bufname] = os.time()
    M.timer_active[bufname] = true
    print("⏳ Tracking time for: " .. bufname)
  end
end

-- Stop tracking time and update total time
function M.stop_timer(bufname)
  bufname = bufname or vim.fn.expand("%:p")
  if bufname == "" or not M.timer_active[bufname] then return end
  if not M.start_time[bufname] then return end -- Prevent nil error

  local elapsed = os.time() - M.start_time[bufname]
  M.total_time[bufname] = (M.total_time[bufname] or 0) + elapsed
  M.timer_active[bufname] = false

  M.save_time_data()

  print("⏹️ Stopped Tracking. Total: " .. format_time(M.total_time[bufname]))
end

function M.show_time()
  local bufname = vim.fn.expand("%:p")
  local time_spent = M.total_time[bufname] or 0
  print("⏰ Time on " .. bufname .. ": " .. format_time(time_spent))
end

M.load_time_data()

-- Autocommands to track buffer events
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function() M.start_timer() end,
})
vim.api.nvim_create_autocmd("BufLeave", {
  callback = function()
    if M.start_time[vim.fn.expand("%:p")] then
      M.stop_timer()
    end
  end,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for bufname, _ in pairs(M.timer_active) do
      if M.start_time[bufname] then
        M.stop_timer(bufname)
      end
    end
    M.save_time_data()
  end,
})

-- User command to check time
vim.api.nvim_create_user_command("Chrono", function() M.show_time() end, {})

return M

